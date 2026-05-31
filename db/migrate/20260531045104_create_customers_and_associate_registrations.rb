class CreateCustomersAndAssociateRegistrations < ActiveRecord::Migration[8.1]
  def up
    create_table :customers do |t|
      t.string :company_name, null: false
      t.text :company_address
      t.string :company_phone
      t.string :finance_name, null: false
      t.string :finance_email, null: false

      t.timestamps
    end

    add_index :customers, :finance_email, unique: true
    add_column :registrations, :customer_id, :bigint

    # Data migration: Link all past registrations to customers
    # We do reset_column_information to ensure ActiveRecord detects new fields
    say "Migrating existing registrations to customers..."
    
    # We define a temporary class to avoid model dependency issues
    execute <<-SQL
      DO $$
      DECLARE
        r RECORD;
        cust_id BIGINT;
      BEGIN
        FOR r IN SELECT DISTINCT finance_email, finance_name, company_name, company_phone, company_address FROM registrations LOOP
          -- Check if customer already created
          SELECT id INTO cust_id FROM customers WHERE LOWER(finance_email) = LOWER(r.finance_email);
          
          IF cust_id IS NULL THEN
            INSERT INTO customers (company_name, company_address, company_phone, finance_name, finance_email, created_at, updated_at)
            VALUES (r.company_name, r.company_address, r.company_phone, r.finance_name, r.finance_email, NOW(), NOW())
            RETURNING id INTO cust_id;
          END IF;
          
          UPDATE registrations SET customer_id = cust_id WHERE finance_email = r.finance_email;
        END LOOP;
      END $$;
    SQL

    add_foreign_key :registrations, :customers
    add_index :registrations, :customer_id
  end

  def down
    remove_index :registrations, :customer_id if index_exists?(:registrations, :customer_id)
    remove_foreign_key :registrations, :customers if foreign_key_exists?(:registrations, :customers)
    remove_column :registrations, :customer_id
    drop_table :customers
  end
end
