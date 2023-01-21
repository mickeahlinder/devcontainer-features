#!/usr/bin/env bash

VERSION=${VERSION:-undefined}

set -e

echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

# Clean up
rm -rf /var/lib/apt/lists/*

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Install curl, apt-transport-https, ca-certificates, git if missing
check_packages wget ca-certificates

# Install tfenv
echo "Downloading tfenv..."

filename="v${VERSION}.tar.gz"

mkdir -p /tmp/tfenv
pushd /tmp/tfenv
wget https://github.com/tfutils/tfenv/archive/refs/tags/${filename}
exit_code=$?
set -e
if [ "$exit_code" != "0" ]; then
    echo "(!) tfenv version ${VERSION} failed to download. Try again later of a diffrent version."
else
    mkdir $_REMOTE_USER_HOME/.tfenv
    tar -zxvf ${filename} -C $_REMOTE_USER_HOME/.tfenv

    echo 'export PATH="$HOME/.tfenv/tfenv-'"${VERSION}"'/bin:$PATH"' >> $_REMOTE_USER_HOME/.bash_profile
fi

popd
rm -rf /tmp/tfenv

# Clean up
rm -rf /var/lib/apt/lists/*