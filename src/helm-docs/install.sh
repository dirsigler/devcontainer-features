#!/bin/bash
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

 DEBIAN_FRONTEND=noninteractive

# Update and install necessary tools
if command -v apt-get &> /dev/null; then
    apt-get update && apt-get install -y \
        curl \
        wget
elif command -v yum &> /dev/null; then
    yum install -y \
        curl \
        wget
else
    echo "Neither apt-get nor yum found. Exiting."
    exit 1
fi

# Detect the system architecture
ARCH=$(uname -m)

# Map the architecture to the GitHub asset name
case "$ARCH" in
    x86_64)
        ARCH_SUFFIX="x86_64"
        ;;
    aarch64)
        ARCH_SUFFIX="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Detect the package manager and set the package extension
if command -v dpkg &> /dev/null; then
    PACKAGE_MANAGER="dpkg"
    PACKAGE_EXT="deb"
elif command -v rpm &> /dev/null; then
    PACKAGE_MANAGER="rpm"
    PACKAGE_EXT="rpm"
else
    echo "Neither dpkg nor rpm found. Exiting."
    exit 1
fi

# Download the latest package for the detected architecture from GitHub
curl -s https://api.github.com/repos/norwoodj/helm-docs/releases/latest \
    | grep "browser_download_url.*${ARCH_SUFFIX}.${PACKAGE_EXT}" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi -

# Find the downloaded package file
package_file=$(ls | grep "helm-docs.*${ARCH_SUFFIX}.${PACKAGE_EXT}")

# Install the package
if [ -n "$package_file" ]; then
    if [ "$PACKAGE_MANAGER" == "dpkg" ]; then
        dpkg -i "$package_file"
        # Resolve dependencies if needed
        apt-get install -f
    elif [ "$PACKAGE_MANAGER" == "rpm" ]; then
        rpm -ivh "$package_file"
    fi
else
    echo "Failed to find the downloaded package file."
    exit 1
fi
