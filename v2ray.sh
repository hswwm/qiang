echo 'input domain'
read your_domain
echo 'input email'
read your_email
your_uuid=`dd37327b-6e87-471e-9f8f-a957ae444eba`

sudo echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" \
    | sudo tee -a /etc/apt/sources.list.d/caddy-fury.list
sudo apt update
sudo apt install caddy 
curl -L -s https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh -o go.sh
sudo chmod +x ./go.sh
sudo ./go.sh 

sudo mkdir /ray
sudo mkdir /var/log/caddy
sudo touch /var/log/caddy/caddy.log
sudo chown -R caddy:caddy /var/log/caddy
sudo chown -R root:caddy /etc/caddy
sudo mkdir /etc/ssl/caddy
sudo chown -R caddy:root /etc/ssl/caddy
sudo chmod 0770 /etc/ssl/caddy
sudo mkdir /var/www
sudo mkdir /var/www/${your_domain}
sudo touch /var/www/${your_domain}/index.html
sudo chown -R caddy:caddy /var/www
sudo touch /etc/caddy/Caddyfile

cat > /etc/caddy/Caddyfile <<-EOF
${your_domain}
log {
output file /var/log/caddy/caddy.log
}
tls ${your_email}
root * /var/www/${your_domain}
file_server
@websockets {
header Connection Upgrade
header Upgrade websocket
}
reverse_proxy @websockets --from /ray --to 127.0.0.1:2589
EOF

sudo cat > /var/www/${your_domain}/index.html <<-EOF
<h>working...</h>
EOF

cat > /usr/local/etc/v2ray/config.json <<-EOF
{
  "inbounds": [
    {
      "port": 2589,
      "listen":"127.0.0.1",
      "protocol": "vmess",
      "settings": {  
        "clients": [
          {
            "id": "${your_uuid}",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/ray"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

sudo systemctl enable caddy.service
sudo systemctl enable v2ray.service
sudo caddy run --config /etc/caddy/Caddyfile
sudo systemctl start v2ray.service

#wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
#sudo chmod +x bbr.sh
#sudo ./bbr.sh

echo 'your uuid:'
echo ${your_uuid}
