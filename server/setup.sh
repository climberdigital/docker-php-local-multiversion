#!/bin/bash

if [ -d "local" ]; then
  echo "Error: Directory 'local' already exists."
  exit 1
fi

# Example using a here-document to execute a block of commands
bash << EOF
echo "Copying defaults into a gitignored local directory..."
cp -r ./default ./local
mv ./local/aliases-template.sh ./local/aliases.sh && mv ./local/docker-compose-template.yml ./docker-compose.yml
mkdir ./local/nginx/sites-enabled
mkdir ./local/nginx/certs
echo "Cleaning up redundant files..."
rm ./local/nginx/virtual-host-https-template.conf && rm ./local/nginx/virtual-host-template.conf
echo "Setup complete!"
EOF
