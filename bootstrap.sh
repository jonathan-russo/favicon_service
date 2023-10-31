#!/usr/bin/env bash

apt -y update
export DEBIAN_FRONTEND=noninteractive
apt -y install build-essential curl git \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev


echo "$(date) Installing pyenv"
git clone https://github.com/pyenv/pyenv.git /opt/pyenv

## pyenv .bashrc config
cat << 'EOF' > /etc/profile.d/python.sh
export PYENV_ROOT="/opt/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init - --no-rehash)"
fi
EOF

source /etc/profile.d/python.sh

echo "$(date) Installing latest version of Python 3.12"
pyenv install 3.12
echo "$(date) Done installing Python 3.12"

pyenv global "$(ls /opt/pyenv/versions/)"

# Install application