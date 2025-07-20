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

# Download Binary
wget https://github.com/xos-labs/node/releases/download/v0.5.2/node_0.5.2_Linux_amd64.tar.gz
tar -xzf node_0.5.2_Linux_amd64.tar.gz
cp bin/xosd /usr/local/bin/
chmod +x /usr/local/bin/xosd
xosd version

# Setting Node
read -p "Input your Moniker" XOS_MONIKER
read -p "Input your Port" XOS_PORT

# Install Node
xosd init $XOS_MONIKER --chain-id xos_1267-1

# Download Genesis
FILEID=1SHdCHf8fQFptV8zGJmvNs4otGx0eBkht
FILENAME=$HOME/.xosd/config/genesis.json
CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
"https://docs.google.com/uc?export=download&id=$FILEID" -O- | \
sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
wget --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=${CONFIRM}&id=${FILEID}" \
-O ${FILENAME}
rm -f /tmp/cookies.txt

# Download Addrbook
FILEID=1OEztauAmg2vQoCzhEMLKcNaPTBLKvOrW
FILENAME=$HOME/.xosd/config/addrbook.json
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
  $HOME/.xosd/config/app.toml

# Set Minimum Gas and Disable Indexer
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.xosd/config/config.toml

# Enable API, gRPC, RPC
# === [api] ===
sed -i '/\[api\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.xosd/config/app.toml
sed -i '/\[api\]/,/^\[/{s/^swagger *=.*/swagger = true/}' $HOME/.xosd/config/app.toml
#sed -i '/\[api\]/,/^\[/{s|^address *=.*|address = "tcp://0.0.0.0:'"${XOS_PORT}"'17"|}' $HOME/.xosd/config/app.toml
#sed -i '/\[api\]/,/^\[/{s/^enabled-unsafe-cors *=.*/enabled-unsafe-cors = true/}' $HOME/.xosd/config/app.toml
# === [grpc] ===
sed -i '/\[grpc\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.xosd/config/app.toml
#sed -i '/\[grpc\]/,/^\[/{s|^address *=.*|address = "0.0.0.0:'"${XOS_PORT}"'90"|}' $HOME/.xosd/config/app.toml
# === [grpc-web] ===
sed -i '/\[grpc-web\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.xosd/config/app.toml
# === [rpc] ===
sed -i '/\[rpc\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.xosd/config/config.toml
#sed -i '/\[rpc\]/,/^\[/{s|^laddr *=.*|laddr = "tcp://0.0.0.0:'"${XOS_PORT}"'657"|}' $HOME/.xosd/config/config.toml

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${XOS_PORT}317%g;
s%:8080%:${XOS_PORT}080%g;
s%:9090%:${XOS_PORT}090%g;
s%:9091%:${XOS_PORT}091%g;
s%:8545%:${XOS_PORT}545%g;
s%:8546%:${XOS_PORT}546%g;
s%:6065%:${XOS_PORT}065%g" $HOME/.xosd/config/app.toml

# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${XOS_PORT}658%g;
s%:26657%:${XOS_PORT}657%g;
s%:6060%:${XOS_PORT}060%g;
s%:26656%:${XOS_PORT}656%g;
s%:26660%:${XOS_PORT}660%g" $HOME/.xosd/config/config.toml
## s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${XOS_PORT}656\"%;

# Create Service
tee /etc/systemd/system/xosd.service > /dev/null <<EOF
[Unit]
Description=XOS testnet node
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/local/bin/xosd start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# Enable Service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable xosd.service

# Download Snapshot
sudo systemctl stop xosd
cp $HOME/.xosd/data/priv_validator_state.json $HOME/.xosd/priv_validator_state.json.backup
xosd tendermint unsafe-reset-all --home $HOME/.xosd --keep-addr-book
python3 -m venv gdown
source gdown/bin/activate
pip3 install gdown
gdown https://drive.google.com/uc?id=1zA36x0nSKS17gVQrpPvGT-QUHBhjdQ8k -O xos-snapshot.tar.lz4
deactivate
rm -rf gdown/
lz4 -dc xos-snapshot.tar.lz4 | tar -xf - -C $HOME/.xosd/data
mv $HOME/.xosd/priv_validator_state.json.backup $HOME/.xosd/data/priv_validator_state.json

# Start Service
sudo systemctl restart xosd

# Create Endpoint Domain
read -p "Input Your Domain: (e.g provewithryd.xyz) " DOMAIN
SSL_PATH="/etc/letsencrypt/live/$DOMAIN"
DOMAIN_RPC="testnet-rpc-xos.$DOMAIN"
DOMAIN_GRPC="testnet-grpc-xos.$DOMAIN"
DOMAIN_API="testnet-api-xos.$DOMAIN"
DOMAIN_EVM="testnet-evm-xos.$DOMAIN"
DOMAIN_WSS="testnet-wss-xos.$DOMAIN"

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
        proxy_pass http://127.0.0.1:${XOS_PORT}657;

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

        proxy_pass http://127.0.0.1:${XOS_PORT}090;

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
        proxy_pass http://127.0.0.1:${XOS_PORT}317;
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

# === [EVM RPC]
sudo tee /etc/nginx/sites-available/$DOMAIN_EVM.conf > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN_EVM;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl;

    server_name $DOMAIN_EVM;

    ssl_certificate $SSL_PATH/fullchain.pem;
    ssl_certificate_key $SSL_PATH/privkey.pem;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 5m;
    ssl_ecdh_curve secp384r1;
    ssl_stapling on;
    ssl_stapling_verify on;

    add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS';
    add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range';

    location / {
        proxy_pass http://127.0.0.1:${XOS_PORT}545;

        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Max-Age 3600;
        add_header Access-Control-Expose-Headers Content-Length;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# === [WSS RPC] ===
sudo tee /etc/nginx/sites-available/$DOMAIN_WSS.conf > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN_WSS;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN_WSS;

    ssl_certificate $SSL_PATH/fullchain.pem;
    ssl_certificate_key $SSL_PATH/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 5m;
    ssl_ecdh_curve secp384r1;

    ssl_stapling on;
    ssl_stapling_verify on;

    add_header Access-Control-Allow-Origin * always;
    add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
    add_header Access-Control-Allow-Headers 'Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range' always;
    add_header Access-Control-Expose-Headers Content-Length always;

    location / {
        proxy_pass http://127.0.0.1:${XOS_PORT}546;
        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_read_timeout 86400;
    }
}
EOF


# Enable all
sudo ln -sf /etc/nginx/sites-available/$DOMAIN_RPC.conf /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/$DOMAIN_GRPC.conf /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/$DOMAIN_API.conf /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/$DOMAIN_EVM.conf /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/$DOMAIN_WSS.conf /etc/nginx/sites-enabled/

# Reload NGINX
sudo nginx -t && sudo systemctl reload nginx

echo -e "\n✅ Access your endpoints:"
echo " - RPC : https://$DOMAIN_RPC"
echo " - gRPC: https://$DOMAIN_GRPC"
echo " - API : https://$DOMAIN_API"
echo " - EVM : https://$DOMAIN_EVM"
echo " - WSS : https://$DOMAIN_WSS"
