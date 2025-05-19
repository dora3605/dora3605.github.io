#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Starting repository update...${NC}"

# Check if dpkg-scanpackages is installed
if ! command -v dpkg-scanpackages &> /dev/null; then
    echo -e "${RED}Error: dpkg-scanpackages is not installed. Please install dpkg-dev package.${NC}"
    exit 1
fi

# Create necessary directories if they don't exist
mkdir -p debs Packages

# Scan debs directory and create Packages file
echo -e "${GREEN}Scanning packages...${NC}"
dpkg-scanpackages debs /dev/null > Packages/Packages

# Compress Packages file
echo -e "${GREEN}Compressing Packages file...${NC}"
gzip -c Packages/Packages > Packages/Packages.gz
bzip2 -c Packages/Packages > Packages/Packages.bz2

# Update Release file
echo -e "${GREEN}Updating Release file...${NC}"
echo "Origin: Custom Sileo Repository" > Release
echo "Label: Custom Sileo Repository" >> Release
echo "Suite: stable" >> Release
echo "Version: 1.0" >> Release
echo "Codename: ios" >> Release
echo "Architectures: iphoneos-arm iphoneos-arm64" >> Release
echo "Components: main" >> Release
echo "Description: Custom repository for Sileo packages" >> Release
echo "" >> Release
echo "Date: $(date -R)" >> Release
echo "MD5Sum:" >> Release
echo " $(md5 Packages/Packages | cut -d' ' -f4) $(stat -f%z Packages/Packages) Packages" >> Release
echo " $(md5 Packages/Packages.gz | cut -d' ' -f4) $(stat -f%z Packages/Packages.gz) Packages.gz" >> Release
echo " $(md5 Packages/Packages.bz2 | cut -d' ' -f4) $(stat -f%z Packages/Packages.bz2) Packages.bz2" >> Release
echo "SHA256:" >> Release
echo " $(shasum -a 256 Packages/Packages | cut -d' ' -f1) $(stat -f%z Packages/Packages) Packages" >> Release
echo " $(shasum -a 256 Packages/Packages.gz | cut -d' ' -f1) $(stat -f%z Packages/Packages.gz) Packages.gz" >> Release
echo " $(shasum -a 256 Packages/Packages.bz2 | cut -d' ' -f1) $(stat -f%z Packages/Packages.bz2) Packages.bz2" >> Release

echo -e "${GREEN}Repository update completed!${NC}" 