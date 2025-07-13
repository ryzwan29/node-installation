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
wget https://go.dev/dl/go1.23.9.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.9.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc
clear

# Download Safrochaind Binary
git clone https://github.com/Safrochain-Org/safrochain-node.git
cd safrochain-node
make install
sudo cp ~/go/bin/safrochaind /usr/local/bin/
clear

# Setting Node
read -p "Input your Moniker" SAFRO_MONIKER
read -p "Input your Port" SAFRO_PORT

# Install Node
safrochaind init $SAFRO_MONIKER --chain-id safro-testnet-1

# Download Genesis
FILEID=1nSPXDq4vsH4D5NI5e1rUpgbR8-kl_M0Z
FILENAME=$HOME/.safrochain/config/genesis.json
CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
"https://docs.google.com/uc?export=download&id=$FILEID" -O- | \
sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
wget --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=${CONFIRM}&id=${FILEID}" \
-O ${FILENAME}
rm -f /tmp/cookies.txt

# Download Addrbook
FILEID=1dUBQ2XGOUhrZK3Xjf20KrgZprbZpaChq
FILENAME=$HOME/.safrochain/config/addrbook.json
CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
"https://docs.google.com/uc?export=download&id=$FILEID" -O- | \
sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
wget --load-cookies /tmp/cookies.txt \
"https://docs.google.com/uc?export=download&confirm=${CONFIRM}&id=${FILEID}" \
-O ${FILENAME}
rm -f /tmp/cookies.txt

# Configure Seed
sed -i -e "s|^seeds *=.*|seeds = \"2242a526e7841e7e8a551aabc4614e6cd612e7fb@88.99.211.113:26656,642dfd491b8bfc0b842c71c01a12ee1122f3dafe@46.62.140.103:26656\"|" \
-e "s|^persistent_peers *=.*|persistent_peers = \"2242a526e7841e7e8a551aabc4614e6cd612e7fb@88.99.211.113:26656,642dfd491b8bfc0b842c71c01a12ee1122f3dafe@46.62.140.103:26656\"|" \
-e "s|^pex *=.*|pex = false|" $HOME/.safrochain/config/config.toml

# Customize Prunning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "20"|' \
  $HOME/.safrochain/config/app.toml

# Set Minimum Gas and Disable Indexer
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.075usaf\"|" $HOME/.safrochain/config/app.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.safrochain/config/config.toml

# Enable API, gRPC, RPC
# === [api] ===
sed -i '/\[api\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.safrochain/config/app.toml
sed -i '/\[api\]/,/^\[/{s/^swagger *=.*/swagger = true/}' $HOME/.safrochain/config/app.toml
sed -i '/\[api\]/,/^\[/{s|^address *=.*|address = "tcp://0.0.0.0:'"${SAFRO_PORT}"'17"|}' $HOME/.safrochain/config/app.toml
sed -i '/\[api\]/,/^\[/{s/^enabled-unsafe-cors *=.*/enabled-unsafe-cors = true/}' $HOME/.safrochain/config/app.toml
# === [grpc] ===
sed -i '/\[grpc\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.safrochain/config/app.toml
sed -i '/\[grpc\]/,/^\[/{s|^address *=.*|address = "0.0.0.0:'"${SAFRO_PORT}"'90"|}' $HOME/.safrochain/config/app.toml
# === [grpc-web] ===
sed -i '/\[grpc-web\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.safrochain/config/app.toml
# === [rpc] ===
sed -i '/\[rpc\]/,/^\[/{s/^enable *=.*/enable = true/}' $HOME/.safrochain/config/config.toml
sed -i '/\[rpc\]/,/^\[/{s|^laddr *=.*|laddr = "tcp://0.0.0.0:'"${SAFRO_PORT}"'657"|}' $HOME/.safrochain/config/config.toml

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${SAFRO_PORT}317%g;
s%:8080%:${SAFRO_PORT}080%g;
s%:9090%:${SAFRO_PORT}090%g;
s%:9091%:${SAFRO_PORT}091%g;
s%:8545%:${SAFRO_PORT}545%g;
s%:8546%:${SAFRO_PORT}546%g;
s%:6065%:${SAFRO_PORT}065%g" $HOME/.safrochain/config/app.toml

# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${SAFRO_PORT}658%g;
s%:26657%:${SAFRO_PORT}657%g;
s%:6060%:${SAFRO_PORT}060%g;
s%:26656%:${SAFRO_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${SAFRO_PORT}656\"%;
s%:26660%:${SAFRO_PORT}660%g" $HOME/.safrochain/config/config.toml

# Create Service
tee /etc/systemd/system/safrochaind.service > /dev/null <<EOF
[Unit]
Description=Safrochain testnet node
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/local/bin/safrochaind start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# Enable Service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable safrochaind.service

# Download Snapshot
sudo systemctl stop safrochaind
cp $HOME/.safrochain/data/priv_validator_state.json $HOME/.safrochain/priv_validator_state.json.backup
safrochaind tendermint unsafe-reset-all --home $HOME/.safrochain --keep-addr-book
python3.12 -m venv gdown
source gdown/bin/activate
pip install gdown
gdown https://drive.google.com/uc?id=1FaIm4hn6uI4YTkMsoOuyy1-U3AuQS1AV -O safrochain-snapshot.tar.lz4
deactivate
rm -rf gdown/
lz4 -dc safrochain-snapshot.tar.lz4 | tar -xf - -C $HOME/.safrochain/data
mv $HOME/.safrochain/priv_validator_state.json.backup $HOME/.safrochain/data/priv_validator_state.json

# Start Service
sudo systemctl restart safrochaind

# Create Endpoint Domain

