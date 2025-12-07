require 'rails_helper'

RSpec.describe "FactoryBot Debug", type: :model do
  it "can create an administrador" do
    admin = FactoryBot.build(:administrador)
    puts "Admin built: #{admin.inspect}"
    expect(admin.valid?).to be true
    
    if admin.save
      puts "Admin saved successfully!"
    else
      puts "Admin save errors: #{admin.errors.full_messages}"
    end
  end
end