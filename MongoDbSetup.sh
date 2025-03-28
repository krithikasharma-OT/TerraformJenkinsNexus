#!/bin/bash

echo "Installing Mongodb..."
sudo apt-get install -y gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

sudo systemctl start mongod
sudo systemctl enable mongod

sudo sed -i 's/\(bindIp:\) 127.0.0.1/\1 0.0.0.0/' /etc/mongod.conf
sudo sed -i '/^#security:/c\security:\n  authorization: enabled' /etc/mongod.conf


MONGO_HOST="localhost"  
MONGO_PORT="27017"
MONGO_DB_NAME="YelpDB"
MONGO_ADMIN_DB="MyDb"
MONGO_USERNAME="Jenkins"
MONGO_PASSWORD="jenkins123"

mongosh --host $MONGO_HOST --port $MONGO_PORT <<EOF
use $MONGO_ADMIN_DB;
db.createUser({
    user: "$MONGO_USERNAME",
    pwd: "$MONGO_PASSWORD",
    roles: [{ role: "readWrite", db: "$MONGO_DB_NAME" }]
});
EOF


sudo systemctl restart mongod
