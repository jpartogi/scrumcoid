# Fly.io Deployment Guide (Legacy Postgres + Mailtrap)

This app is configured for Fly.io using:

- **Legacy Postgres app**: `scrumcoid-db` (your production database)
- Mailtrap for transactional email (password resets via Devise)
- Single database for Solid Cache + Solid Queue + Solid Cable
- Thruster + Puma (via the existing Dockerfile)
- Optional object storage via Tigris or Cloudflare R2

### New Developer Experience Improvements

- **`bin/fly-setup`** — One-command initial infrastructure setup
- **GitHub Actions** — Automatic deploys on push to main (`.github/workflows/deploy.yml`)
- **Tigris / R2 ready** — Easy migration path from volume-based storage to object storage

## Prerequisites

- [Fly CLI](https://fly.io/docs/hands-on/install-flyctl/) installed and logged in (`fly auth login`)
- A Mailtrap account (https://mailtrap.io) — create an inbox and note the SMTP credentials

## 1. Launch the Fly App

```bash
fly launch --dockerfile Dockerfile
```

- Choose a region close to your users.
- **Do NOT** let it create a Postgres database during launch (we'll do the legacy one manually).
- It will detect the Dockerfile.

Answer "No" when asked about Postgres and Redis during the wizard.

## 2. Create a Legacy Fly Postgres Database

Your production Postgres app is `scrumcoid-db`.

```bash
fly postgres create --name scrumcoid-db --region sjc --vm-size shared-cpu-1x --initial-cluster-size 1
```

If you have already created it, you can skip this step.

## 3. Attach the Database

Attach your production Postgres app (`scrumcoid-db`) to the main app:

```bash
fly postgres attach scrumcoid-db --app scrumcoid
```

This sets the `DATABASE_URL` secret automatically.

## 4. Create a Volume for Active Storage

Course logos are stored via Active Storage on disk. Without a volume they will disappear on every deploy.

```bash
fly volumes create storage --app scrumcoid --size 1 --region sjc
```

The `fly.toml` already has the mount configured at `/rails/storage`.

## 5. Set Mailtrap Secrets

Get your SMTP credentials from Mailtrap (Inbox → SMTP settings).

Use `live.smtp.mailtrap.io` for real inboxes or `sandbox.smtp.mailtrap.io` for testing.

```bash
fly secrets set \
  MAILTRAP_USERNAME="your_username" \
  MAILTRAP_PASSWORD="your_password" \
  --app scrumcoid
```

### Using the example env file

We provide a safe template:

```bash
cp .env.fly.example .env.fly
# Edit .env.fly with your real values (never commit it)
```

Then set the secrets from it (example):

```bash
fly secrets set \
  MAILTRAP_USERNAME="$(grep MAILTRAP_USERNAME .env.fly | cut -d= -f2)" \
  MAILTRAP_PASSWORD="$(grep MAILTRAP_PASSWORD .env.fly | cut -d= -f2)" \
  APP_HOST="$(grep APP_HOST .env.fly | cut -d= -f2)" \
  MAILER_FROM="$(grep MAILER_FROM .env.fly | cut -d= -f2)" \
  --app scrumcoid
```

## 6. (Optional but Recommended) Custom Domain + Verified Sender in Mailtrap

This greatly improves email deliverability for password resets.

1. Add your domain in Fly:
   ```bash
   fly certs create yourdomain.com --app scrumcoid
   fly certs create www.yourdomain.com --app scrumcoid
   ```

2. In Mailtrap, go to your inbox → **Domain Verification** (or Sending Domains) and verify `yourdomain.com`.

3. Update the runtime secrets:
   ```bash
   fly secrets set \
     APP_HOST="yourdomain.com" \
     MAILER_FROM="ScrumAI Training <no-reply@yourdomain.com>" \
     --app scrumcoid
   ```

4. Redeploy so the new `APP_HOST` takes effect in mailer links:
   ```bash
   fly deploy
   ```

Now password reset links will use your real domain and emails will come from your verified address.

## 7. (Optional) Set Other Required Secrets

Stripe (if using payments):

```bash
fly secrets set \
  STRIPE_SECRET_KEY="sk_live_..." \
  STRIPE_WEBHOOK_SECRET="whsec_..." \
  --app scrumcoid
```

Rails master key (Fly usually injects it automatically from `config/master.key` on first deploy).

## 8. Deploy

```bash
fly deploy
```

The `release_command` in `fly.toml` will run `bin/rails db:prepare`.

## 9. Useful Fly Commands

```bash
# View logs
fly logs --app scrumcoid

# Open Rails console
fly ssh console --app scrumcoid -C "bin/rails console"

# Run migrations manually if needed
fly ssh console --app scrumcoid -C "bin/rails db:migrate"

# Connect to your production Postgres (scrumcoid-db)
fly postgres connect --app scrumcoid-db

# Scale
fly scale count 2 --app scrumcoid

# View status
fly status --app scrumcoid
fly volumes list --app scrumcoid
```

## Important Notes

### Database

- We deliberately use **one database** for everything (primary + cache + queue + cable).
- All Solid* tables are created in the main `scrumcoid_production` database.
- This makes the classic "legacy" Fly Postgres experience much simpler.

If you ever want to split them later, you can re-enable the commented sections in `config/database.yml` and create the extra databases manually.

### Active Storage

Uploaded course logos live on the volume. Back them up periodically:

```bash
fly sftp get /rails/storage/... local-backup/ --app scrumcoid
```

For serious production, consider moving to S3-compatible storage using **Tigris** (Fly's native storage) or Cloudflare R2. See the "Object Storage (Tigris / R2)" section below.

### Mailtrap Limits

Mailtrap has sending limits on free/sandbox plans. For real customer emails in production, either:

- Upgrade Mailtrap, or
- Switch to a real transactional provider (Resend, Postmark, SendGrid, Amazon SES, etc.) by updating the SMTP settings in `config/environments/production.rb`.

### Custom Domain + SSL

```bash
fly certs create scrumcoid.com --app scrumcoid
fly certs create www.scrumcoid.com --app scrumcoid
```

Then update `APP_HOST` and `MAILER_FROM` secrets.

### Dedicated Solid Queue Worker Process (Recommended at Scale)

By default the app runs Solid Queue inside the web process (`SOLID_QUEUE_IN_PUMA=true`). This is fine for low-to-medium traffic.

**When to split:**
- You have many enrollments, background Stripe processing, or future scheduled jobs
- You want to scale web and workers independently

**How to enable a dedicated worker:**

1. Edit `fly.toml` and uncomment the `[processes]` section near the bottom.

2. Set the environment variable:
   ```bash
   fly secrets set SOLID_QUEUE_IN_PUMA=false --app scrumcoid
   ```

3. Deploy:
   ```bash
   fly deploy
   ```

4. Scale the processes separately:
   ```bash
   fly scale count app=2 worker=1 --app scrumcoid
   ```

### Object Storage – Tigris (Recommended) or Cloudflare R2

Instead of using a persistent volume for Active Storage (course logos), you can use object storage. This is more scalable and doesn't require managing volumes.

#### Option A: Fly Tigris (Easiest on Fly)

1. Create a Tigris bucket:
   ```bash
   fly storage create --app scrumcoid
   ```

2. Switch the storage service:
   ```bash
   fly secrets set ACTIVE_STORAGE_SERVICE=tigris --app scrumcoid
   ```

3. Deploy:
   ```bash
   fly deploy
   ```

Tigris credentials are automatically injected by Fly.

#### Option B: Cloudflare R2

1. Create a bucket in Cloudflare R2.
2. Generate an API token with R2 read/write permissions.
3. Set the secrets:
   ```bash
   fly secrets set \
     R2_ACCESS_KEY_ID="..." \
     R2_SECRET_ACCESS_KEY="..." \
     R2_ACCOUNT_ID="..." \
     R2_BUCKET="scrumcoid-production" \
     ACTIVE_STORAGE_SERVICE=r2 \
     --app scrumcoid
   ```

4. Deploy.

You can also store R2 credentials in `config/credentials/production.yml` if preferred.

**Migration note**: Moving from local disk to object storage later will require copying existing files (or re-uploading course logos).

### GitHub Actions CI/CD

A deployment workflow is included at `.github/workflows/deploy.yml`.

- Runs the test suite on every push
- Deploys automatically on pushes to `main`/`master`
- Uses `flyctl deploy --remote-only`

**Required GitHub secret**:
- `FLY_API_TOKEN` → Create one at https://fly.io/user/personal_access_tokens (with "Apps" scope)

After adding the secret, every push to main will trigger a deployment.

### Automated Setup Script

Instead of running the individual `fly` commands manually, you can use the helper script:

```bash
./bin/fly-setup
```

It will:
- Create the Fly app
- Provision a legacy Postgres database
- Attach the database
- Create the required volume
- Prompt for Mailtrap credentials
- Optionally set custom domain settings
- Optionally trigger the first deploy

This is the fastest way to get a new environment running.
You can give the worker machines more resources if needed:
```bash
fly machine list --app scrumcoid
fly machine update <worker-machine-id> --vm-size performance-1x --memory 2048
```

The worker process runs `bundle exec rake solid_queue:start` and only processes jobs (no web server).

## Troubleshooting

**"We're sorry, but something went wrong" + no logs?**
Check that `RAILS_MASTER_KEY` is available. During first deploy Fly should copy it.

**Active Storage images 404 after deploy?**
The volume was not attached at deploy time, or the machine restarted without the volume. Check `fly volumes list`.

**Emails not sending?**
- Verify `MAILTRAP_USERNAME` / `MAILTRAP_PASSWORD` are set (`fly secrets list`)
- Check logs for SMTP errors
- Make sure `APP_HOST` matches the domain in your Mailtrap inbox settings (for SPF/DKIM if using custom domain)

**Migrations failing?**
Connect to the DB and check that the user has `CREATE DATABASE` rights if you ever re-enable multi-DB mode. With the current single-DB setup this should not happen.

## One-time Setup Checklist

**Recommended:** Use the automated script:

```bash
./bin/fly-setup
```

**Manual checklist** (if you prefer full control):

- [ ] `fly launch --dockerfile Dockerfile` (or let `bin/fly-setup` do it)
- [ ] `fly postgres create --name scrumcoid-db` (or verify it exists)
- [ ] `fly postgres attach scrumcoid-db --app scrumcoid`
- [ ] `fly volumes create storage`
- [ ] `fly secrets set` for Mailtrap + domain settings
- [ ] (Optional) Set up GitHub Actions: Add `FLY_API_TOKEN` secret to your repo
- [ ] `fly deploy` (or let the script do it)
- [ ] Test password reset emails
- [ ] Upload a course logo (verifies storage)
- [ ] (Future) Consider switching to Tigris: `fly storage create` + `ACTIVE_STORAGE_SERVICE=tigris`

---

Happy deploying!
