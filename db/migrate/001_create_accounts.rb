Sequel.migration do
  up do
    create_table :accounts do
      primary_key :id
      String :name
      String :nickname
      String :email
      String :role
      String :uid
      String :provider
    end
  end

  down do
    drop_table :accounts
  end
end
