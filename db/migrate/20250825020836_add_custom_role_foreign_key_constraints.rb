class AddCustomRoleForeignKeyConstraints < ActiveRecord::Migration[7.1]
  def change
    # Add foreign key constraints for data integrity
    
    # Custom roles must belong to an account
    add_foreign_key :custom_roles, :accounts, on_delete: :cascade
    
    # Account users with custom roles must reference valid custom roles
    add_foreign_key :account_users, :custom_roles, on_delete: :nullify
    
    # Add additional indexes for performance optimization
    add_index :custom_roles, [:account_id, :name], unique: true, name: 'index_custom_roles_unique_name_per_account'
    
    # Add database-level constraint to ensure permissions array is not empty
    add_check_constraint :custom_roles, 
                        "array_length(permissions, 1) > 0", 
                        name: 'check_custom_roles_has_permissions'
    
    # Add constraint to ensure name is not empty after trimming whitespace
    add_check_constraint :custom_roles, 
                        "length(trim(name)) > 0", 
                        name: 'check_custom_roles_name_not_empty'
  end
end
