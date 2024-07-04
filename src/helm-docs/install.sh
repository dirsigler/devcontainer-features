#!/bin/sh
set -e

echo "Activating feature 'helm-docs'"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

apt-get update && apt-get install -y \
    curl \
    wget \
    git

# Download the latest x86_64.deb package from GitHub
curl -s https://api.github.com/repos/norwoodj/helm-docs/releases/latest \
    | grep "browser_download_url.*x86_64.deb" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi -

# Find the downloaded .deb file
deb_file=$(ls | grep "helm-docs.*x86_64.deb")

# Install the .deb package
if [ -n "$deb_file" ]; then
    dpkg -i "$deb_file"
    # Resolve dependencies if needed
    apt-get install -f
else
    echo "Failed to find the downloaded .deb file."
    exit 1
fi

rm -rf /var/lib/apt/lists/*
