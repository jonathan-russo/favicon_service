#!/usr/bin/env bash

echo "$(date) Packer Bake start"

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

# Install relevant Python Version
PYTHON_VERSION="3.12"
echo "$(date) Installing Python Version: ${PYTHON_VERSION}"
pyenv install ${PYTHON_VERSION}
echo "$(date) Done installing Python"
pyenv global "$(ls /opt/pyenv/versions/)"
