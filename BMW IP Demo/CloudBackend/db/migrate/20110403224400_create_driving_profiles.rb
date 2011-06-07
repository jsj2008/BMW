class CreateDrivingProfiles < ActiveRecord::Migration
  def self.up
    create_table :driving_profiles do |t|
      t.integer :id
      t.string :user_name
      t.integer :mileage
      t.integer :redlight_count
      t.float :mpg
      t.integer :carma_points

      t.timestamps
    end
  end

  def self.down
    drop_table :driving_profiles
  end
end
