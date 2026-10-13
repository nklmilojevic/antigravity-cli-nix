#!/usr/bin/env bash

set -euo pipefail

PACKAGE_FILE="package.nix"
MANIFEST_BASE_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests"

# Manifest platform -> nix system
declare -A PLATFORMS=(
    ["linux_amd64"]="x86_64-linux"
    ["linux_arm64"]="aarch64-linux"
    ["darwin_amd64"]="x86_64-darwin"
    ["darwin_arm64"]="aarch64-darwin"
)

usage() {
    echo "Usage: $0 [--check | --latest-version | --update]"
    echo ""
    echo "Options:"
    echo "  --check           Check if a new version is available"
    echo "  --latest-version  Print the latest available version"
    echo "  --update          Update package.nix to the latest version"
    exit 1
}

get_current_version() {
    grep 'version = ' "$PACKAGE_FILE" | head -1 | cut -d'"' -f2
}

fetch_manifest() {
    curl -fsSL "$MANIFEST_BASE_URL/$1.json"
}

get_latest_version() {
    fetch_manifest darwin_arm64 | jq -r .version
}

update_platform() {
    local nix_system="$1"
    local url="$2"
    local sha512="$3"
    local file="$4"

    awk -v target_system="$nix_system" -v url="$url" -v hash="$sha512" '
        $0 ~ "\"" target_system "\" = \\{" { in_block = 1 }
        in_block && /url = / { sub(/url = "[^"]*"/, "url = \"" url "\"") }
        in_block && /sha512 = / {
            sub(/sha512 = "[^"]*"/, "sha512 = \"" hash "\"")
            in_block = 0
        }
        { print }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

if [ $# -eq 0 ]; then
    usage
fi

case "$1" in
    --latest-version)
        get_latest_version
        exit 0
        ;;
    --check)
        CURRENT_VERSION=$(get_current_version)
        LATEST_VERSION=$(get_latest_version)

        echo "Current version: $CURRENT_VERSION"
        echo "Latest version:  $LATEST_VERSION"

        if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
            echo "Already up to date!"
            exit 0
        else
            echo "New version available: $LATEST_VERSION"
            echo "Run './scripts/update.sh --update' to update"
            exit 1
        fi
        ;;
    --update) ;;
    *) usage ;;
esac

VERSION=""

for platform in "${!PLATFORMS[@]}"; do
    nix_system="${PLATFORMS[$platform]}"
    echo "Fetching manifest for $platform ($nix_system)..."
    MANIFEST=$(fetch_manifest "$platform")

    PLATFORM_VERSION=$(echo "$MANIFEST" | jq -r .version)
    URL=$(echo "$MANIFEST" | jq -r .url)
    SHA512=$(echo "$MANIFEST" | jq -r .sha512)

    if [ -z "$URL" ] || [ "$URL" = "null" ] || [ -z "$SHA512" ] || [ "$SHA512" = "null" ]; then
        echo "Error: Malformed manifest for $platform"
        exit 1
    fi

    if [ -n "$VERSION" ] && [ "$VERSION" != "$PLATFORM_VERSION" ]; then
        echo "Error: Version mismatch across platforms ($VERSION vs $PLATFORM_VERSION for $platform)"
        exit 1
    fi
    VERSION="$PLATFORM_VERSION"

    update_platform "$nix_system" "$URL" "$SHA512" "$PACKAGE_FILE"
    echo "  $nix_system: $URL"
done

echo ""
echo "Updating version to $VERSION..."
sed -i.bak 's/version = "[^"]*"/version = "'"$VERSION"'"/' "$PACKAGE_FILE"
rm -f "${PACKAGE_FILE}.bak"

echo "Testing build..."
if nix build --no-link; then
    echo "Build successful!"
    echo ""
    echo "Version $VERSION has been successfully updated."
else
    echo "Build failed. Please check the error messages above."
    exit 1
fi
