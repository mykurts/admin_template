# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def create_admins
  admin = Account::Administrator.where(
  first_name: "Admin",
  last_name: "Test",
  email: "admin@email.com"
  ).first_or_initialize

  admin.password= "password"
  admin.save
end

create_admins