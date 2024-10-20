resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 20
  engine              = "sqlserver-express"  # Use "sqlserver-express" for SQL Server Express
  engine_version      = "15.00"               # You can specify the desired version
  instance_class      = "db.t3.micro"         # The instance class can be adjusted as needed
  db_name             = "logdata"
  username            = "admin"
  password            = "Sakaravi#charlie"
  publicly_accessible  = true
  skip_final_snapshot  = true

  # Remove backup retention settings
  backup_retention_period = 0  # No backups
  deletion_protection      = false  # Allow instance deletion

  # Optional: Disable minor version upgrades if you want complete control
  auto_minor_version_upgrade = false 

  tags = {
    Name = "logdata-database"
  }
}

# Output the database name within the module
output "db_name" {
  value = aws_db_instance.rds_instance.db_name
}
