#!/usr/bin/env bash

echo "$(date) Bootstrap start"

# Install Dependencies
apt -y update
export DEBIAN_FRONTEND=noninteractive # If not present Timezone package will propmpt for user input 
apt -y install build-essential curl git systemctl awscli \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install PyEnv so we can install any Python version(not limited to what Ubuntu 20.04 has avaible in the repos)
echo "$(date) Installing pyenv"
git clone https://github.com/pyenv/pyenv.git /opt/pyenv
cat << 'EOF' > /etc/profile.d/python.sh
export PYENV_ROOT="/opt/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init - --no-rehash)"
fi
EOF
source /etc/profile.d/python.sh

# Pull down application 
echo "$(date) Downloading application"
DDG_ROOT_DIR=/opt/DDG
mkdir -p ${DDG_ROOT_DIR} && cd ${DDG_ROOT_DIR}
aws s3 cp s3://deploy-production-favicon/favicon_service.tar.gz favicon_service.tar.gz
tar xzf favicon_service.tar.gz
SERVICE_DIR=${DDG_ROOT_DIR}/favicon_service
cd ${SERVICE_DIR}

# Add service user and change service dir ownership
useradd favicon
chown -R favicon ${SERVICE_DIR}

# Install relevant Python Version
PYTHON_VERSION=$(cat .python-version)
echo "$(date) Installing Python Version: ${PYTHON_VERSION}"
pyenv install ${PYTHON_VERSION}
echo "$(date) Done installing Python"
pyenv global "$(ls /opt/pyenv/versions/)"

# Setup Service
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

cat << EOF > /etc/systemd/system/favicon.service
[Unit]
Description=Favicon Service daemon
After=network.target

[Service]
User=favicon
Group=www-data
WorkingDirectory=${SERVICE_DIR}
EnvironmentFile=${SERVICE_DIR}/configs/production.env
ExecStart=${SERVICE_DIR}/.venv/bin/gunicorn favicon_service.wsgi

[Install]
WantedBy=multi-user.target
EOF

# Run Service
echo "$(date) Starting service"
systemctl enable favicon
systemctl start favicon

echo "$(date) Bootstrap finish"

