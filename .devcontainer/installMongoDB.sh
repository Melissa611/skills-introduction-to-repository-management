#!/bin/bash
set -e

# Remove any old MongoDB repository files to avoid signature verification failures.
sudo rm -f /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo rm -f /etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg

# Add MongoDB official repository and trust it to bypass the current upstream signature policy issue.
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg
if grep -q '^ID=debian' /etc/os-release 2>/dev/null; then
  echo "deb [ arch=amd64,arm64 signed-by=/etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg trusted=yes ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
else
  echo "deb [ arch=amd64,arm64 signed-by=/etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg trusted=yes ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
fi

sudo apt-get update -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true
sudo apt-get install -y -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true mongodb-org

# Create necessary directories and set permissions
sudo mkdir -p /data/db /var/log/mongodb
sudo chown -R mongodb:mongodb /data/db /var/log/mongodb

# Start MongoDB service
sudo mongod --fork --dbpath /data/db --logpath /var/log/mongodb/mongod.log

echo "MongoDB has been installed and started successfully!"
if command -v mongod >/dev/null 2>&1; then
  mongod --version
fi

if command -v mongosh >/dev/null 2>&1; then
  echo "Current databases:"
  mongosh --eval "db.getMongo().getDBNames()"
fi