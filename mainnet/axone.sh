#!/bin/bash
clear
echo -e "\033[1;32m
██████╗ ██╗   ██  ███████╗  ███████╗  ███████╗  
██╔══██╗ ██╗ ██║  ██║   ██║ ██║   ██║ ██║   ██║
██████╔╝  ████║   ██║   ██║ ██║   ██║ ██║   ██║
██╔══██╗   ██╔╝   ██║   ██║ ██║   ██║ ██║   ██║
██║  ██║   ██║    ███████║  ███████║  ███████║
╚═╝  ╚═╝   ╚═╝    ╚══════╝  ╚══════╝  ╚══════╝
\033[0m"
echo -e "\033[1;34m======================================================\033[1;34m"
echo -e "\033[1;34m@Ryddd | Testnet, Node Validator, Blockchain Developer\033[1;34m"

sleep 4

# Update & Install dependencies
echo -e "\033[0;32mUpdating and Installing dependencies...\033[0m"
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates apt-transport-https zlib1g-dev software-properties-common libncurses5-dev libgdbm-dev libnss3-dev curl git wget make jq build-essential pkg-config lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4 expect
clear 

# Install Python
echo -e "\033[0;32mInstall Python3 and Pip3...\033[0m"
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.12 python3.12-venv python3-pip

# Install Go
wget https://go.dev/dl/go1.23.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.3.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc

# Download Binary
git clone https://github.com/axone-protocol/axoned.git
cd axoned
make install
cp $HOME/go/bin/axoned /usr/local/bin
axoned version

# Setting Node
read -p "Input your Moniker" AXONE_MONIKER
read -p "Input your Port" AXONE_PORT

# Install Node
axoned init $AXONE_MONIKER --chain-id axone-1

# Download Genesis
FILEID=1fQEvltNIO9Wep8IwJimXzQnO9Csurkch
FILENAME=$HOME/.axoned/config/genesis.json
CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
"https://docs.google.com/uc?export=download&id=$FILEID" -O- | \
sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
wget --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=${CONFIRM}&id=${FILEID}" \
-O ${FILENAME}
rm -f /tmp/cookies.txt

# Download Addrbook
FILEID=1Rujfo88zdAEp0iWtYOVYc7klosf10YTs
FILENAME=$HOME/.axoned/config/addrbook.json
CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
"https://docs.google.com/uc?export=download&id=$FILEID" -O- | \
sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
wget --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=${CONFIRM}&id=${FILEID}" \
-O ${FILENAME}
rm -f /tmp/cookies.txt

# Customize Prunning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
  $HOME/.axoned/config/app.toml

# Set Minimum Gas and Disable Indexer
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.001uaxone\"|" $HOME/.axoned/config/app.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.axoned/config/config.toml

# Enable API, gRPC, RPC
# === [api] ===
sed -i '/\[api\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.axoned/config/app.toml
sed -i '/\[api\]/,/^\[/{s/^swagger *=.*/swagger = true/}' $HOME/.axoned/config/app.toml
sed -i '/\[api\]/,/^\[/{s|^address *=.*|address = "tcp://0.0.0.0:'"${AXONE_PORT}"'17"|}' $HOME/.axoned/config/app.toml
sed -i '/\[api\]/,/^\[/{s/^enabled-unsafe-cors *=.*/enabled-unsafe-cors = true/}' $HOME/.axoned/config/app.toml
# === [grpc] ===
sed -i '/\[grpc\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.axoned/config/app.toml
sed -i '/\[grpc\]/,/^\[/{s|^address *=.*|address = "0.0.0.0:'"${AXONE_PORT}"'90"|}' $HOME/.axoned/config/app.toml
# === [grpc-web] ===
sed -i '/\[grpc-web\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.axoned/config/app.toml
# === [rpc] ===
sed -i '/\[rpc\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.axoned/config/config.toml
sed -i '/\[rpc\]/,/^\[/{s|^laddr *=.*|laddr = "tcp://0.0.0.0:'"${AXONE_PORT}"'657"|}' $HOME/.axoned/config/config.toml

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${AXONE_PORT}17%g;
s%:8080%:${AXONE_PORT}080%g;
s%:9090%:${AXONE_PORT}090%g;
s%:9091%:${AXONE_PORT}091%g;
s%:8545%:${AXONE_PORT}545%g;
s%:8546%:${AXONE_PORT}546%g;
s%:6065%:${AXONE_PORT}065%g" $HOME/.axoned/config/app.toml

# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${AXONE_PORT}658%g;
s%:26657%:${AXONE_PORT}657%g;
s%:6060%:${AXONE_PORT}060%g;
s%:26656%:${AXONE_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${AXONE_PORT}656\"%;
s%:26660%:${AXONE_PORT}660%g" $HOME/.axoned/config/config.toml

# Create Service
tee /etc/systemd/system/axoned.service > /dev/null <<EOF
[Unit]
Description=Axone Mainnet node
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/local/bin/axoned start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# Enable Service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable axoned.service

# Download Snapshot
sudo systemctl stop axoned
cp $HOME/.axoned/data/priv_validator_state.json $HOME/.axoned/priv_validator_state.json.backup
axoned tendermint unsafe-reset-all --home $HOME/.axoned --keep-addr-book
python3 -m venv gdown
source gdown/bin/activate
pip3 install gdown
gdown https://drive.google.com/uc?id=1AWUW6FdjCjhecat2yBxDsUHzusWVawMg -O axone-snapshot.tar.lz4
deactivate
rm -rf gdown/
lz4 -dc axone-snapshot.tar.lz4 | tar -xf - -C $HOME/.axoned/data
mv $HOME/.axoned/priv_validator_state.json.backup $HOME/.axoned/data/priv_validator_state.json

# Start Service
sudo systemctl restart axoned

# Create Endpoint Domain
read -p "Input Your Domain: (e.g provewithryd.xyz)" DOMAIN
SSL_PATH="/etc/letsencrypt/live/$DOMAIN"
DOMAIN_RPC="rpc-axone.$DOMAIN"
DOMAIN_GRPC="grpc-axone.$DOMAIN"
DOMAIN_API="rpc-axone.$DOMAIN"

# Create Endpoint Domain
# === [RPC] ===
sudo tee /etc/nginx/sites-available/$DOMAIN_RPC.conf > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN_RPC;
    return 301 https://\$host\$request_uri;
}
server {
    listen 443 ssl;
    server_name $DOMAIN_RPC;

    ssl_certificate $SSL_PATH/fullchain.pem;
    ssl_certificate_key $SSL_PATH/privkey.pem;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!MD5;

    add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS';
    add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range';

    location / {
        proxy_pass http://0.0.0.0:${AXONE_PORT}657;

        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Max-Age 3600;
        add_header Access-Control-Expose-Headers Content-Length;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# === gRPC Endpoint ===
sudo tee /etc/nginx/sites-available/$DOMAIN_GRPC.conf > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN_GRPC;
    return 301 https://\$host\$request_uri;
}
server {
    listen 443 ssl;
    server_name $DOMAIN_GRPC;

    ssl_certificate $SSL_PATH/fullchain.pem;
    ssl_certificate_key $SSL_PATH/privkey.pem;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        if (\$request_method = OPTIONS) {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Length' 0;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            return 204;
        }

        proxy_pass http://0.0.0.0:${AXONE_PORT}90;

        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Max-Age' 3600;
        add_header 'Access-Control-Expose-Headers' 'Content-Length';

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# === API Endpoint ===
sudo tee /etc/nginx/sites-available/$DOMAIN_API.conf > /dev/null <<EOF
server {
    listen 443 ssl http2;
    server_name $DOMAIN_API;

    ssl_certificate $SSL_PATH/fullchain.pem;
    ssl_certificate_key $SSL_PATH/privkey.pem;

    location / {
        proxy_pass http://0.0.0.0:${AXONE_PORT}17;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        proxy_hide_header Access-Control-Allow-Origin;

        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Length' always;

        if (\$request_method = OPTIONS) {
            add_header 'Content-Length' 0;
            add_header 'Content-Type' 'text/plain; charset=UTF-8';
            return 204;
        }
    }
}
EOF

# Enable all
sudo ln -sf /etc/nginx/sites-available/$DOMAIN_RPC.conf /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/$DOMAIN_GRPC.conf /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/$DOMAIN_API.conf /etc/nginx/sites-enabled/

# Reload NGINX
sudo nginx -t && sudo systemctl reload nginx

echo -e "\n✅ Access your endpoints:"
echo " - RPC : https://$DOMAIN_RPC"
echo " - gRPC: https://$DOMAIN_GRPC"
echo " - API : https://$DOMAIN_API"
