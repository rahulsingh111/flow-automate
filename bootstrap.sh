#!/bin/bash
exec > /var/log/bootstrap.log 2>&1

APP_DIR="/home/ubuntu/app"
APP_REPO="https://bitbucket.org/divyam-singal/node_dummy_app.git"

echo "Updating system and installing dependencies..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y nginx git curl gnupg ca-certificates

echo "Installing Node.js"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
sudo apt-get install -y nodejs

echo "Installing PM2"
sudo npm install -g pm2

echo "Installing MongoDB"
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb.gpg
echo "deb [signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" > /etc/apt/sources.list.d/mongodb.list
sudo apt-get update -y && sudo apt-get install -y mongodb-org
sudo systemctl enable --now mongod
echo "MongoDB status: $(sudo systemctl is-active mongod)"

echo "Cloning app"
rm -rf $APP_DIR
sudo -u ubuntu git clone $APP_REPO $APP_DIR
cd $APP_DIR && sudo -u ubuntu npm install

echo "Creating .env"
sudo -u ubuntu bash -c "cat > $APP_DIR/.env << ENV
MONGO_URI=mongodb://127.0.0.1:27017/mydb
MONGO_DATABASE=mydb
PORT=3000
ENV"

echo "Starting app"
sudo -u ubuntu pm2 start $APP_DIR/server.js --name my-app
sudo -u ubuntu pm2 save
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
systemctl enable pm2-ubuntu
echo "App status: $(sudo -u ubuntu pm2 list)"

echo "Configuring Nginx"
cat > /etc/nginx/sites-available/default << 'NGINX'
server {
    listen 80;
    location / {
        proxy_pass http://127.0.0.1:3000;
    }
}
NGINX
nginx -t && systemctl restart nginx && systemctl enable nginx
