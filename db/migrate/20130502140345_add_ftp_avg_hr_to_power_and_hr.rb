class AddFtpAvgHrToPowerAndHr < ActiveRecord::Migration
  def change
    add_column :power_zones, :ftp, :integer, :default => 175
    add_column :hr_zones, :lt_hr, :integer, :default => 155
  end
end
