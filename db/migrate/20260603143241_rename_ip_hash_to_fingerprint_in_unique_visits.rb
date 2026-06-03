class RenameIpHashToFingerprintInUniqueVisits < ActiveRecord::Migration[8.1]
  def change
    # Safe for DBs created from old schema (has ip_hash) or already at new schema (has fingerprint, e.g. from db:schema:load)
    if column_exists?(:unique_visits, :ip_hash)
      rename_column :unique_visits, :ip_hash, :fingerprint
    end

    # Ensure the unique index exists under the (new) name. Rename old index if present.
    old_index = "index_unique_visits_on_ip_hash_and_visited_on"
    new_index = "index_unique_visits_on_fingerprint_and_visited_on"

    if index_exists?(:unique_visits, [:ip_hash, :visited_on], name: old_index)
      rename_index :unique_visits, old_index, new_index
    elsif index_exists?(:unique_visits, [:fingerprint, :visited_on], name: new_index)
      # already correct
    else
      # Make sure we have the unique constraint (covers edge cases)
      add_index :unique_visits, [:fingerprint, :visited_on], unique: true, name: new_index
    end

    # The visited_on index is unaffected
  end
end
