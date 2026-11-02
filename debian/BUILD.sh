#Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#SPDX-License-Identifier: BSD-3-Clause-Clear

#!/usr/bin/env bash
set -euo pipefail

# ===== Configurable parameters =====
REPO_URL="https://github.com/qca/sigma-dut.git"
BRANCH="master"
COMMIT_ID="a7859766c2bc60bcbc5d6271617141e6853fea8a"
TARGET_ROOT="$PWD/workspace/sources"
TARGET_DIR="$TARGET_ROOT/sigma-dut"

# ===== Source debian directory =====
SOURCE_DEBIAN_DIR="$PWD/workspace/layers/meta-qti-wlan/recipes-connectivity/wlan-sigma-dut/debian"

echo "==> Checking dependencies and inputs..."
command -v git >/dev/null 2>&1 || { echo "Error: git not found, please install it first."; exit 1; }
if [ ! -d "$SOURCE_DEBIAN_DIR" ]; then
  echo "Error: debian/ directory not found in current directory: $SOURCE_DEBIAN_DIR"
  exit 1
fi

echo "==> Preparing target directory: $TARGET_ROOT"
mkdir -p "$TARGET_ROOT"

# If an old directory exists, clean it to ensure a clean working copy
if [ -d "$TARGET_DIR" ]; then
  echo "==> Found existing directory $TARGET_DIR, deleting..."
  rm -rf "$TARGET_DIR"*
fi

echo "==> Cloning repository (branch: $BRANCH) to $TARGET_DIR"
git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$TARGET_DIR"

echo "==> Switching to repository directory and checking out specified commit: $COMMIT_ID"
cd "$TARGET_DIR"
git checkout "$COMMIT_ID"
# Verify that the commit exists and is successfully checked out
if ! git rev-parse --verify "$COMMIT_ID^{commit}" >/dev/null; then
    echo "Error: Commit $COMMIT_ID not found."
    exit 1
fi

# If the repository already contains debian/, replace it with the current directory's debian/ as needed
if [ -d "debian" ]; then
  echo "==> Target repository already contains debian/, replacing it with current directory's debian/..."
  rm -rf "debian"
fi

echo "==> Copying debian/ from current directory to repository root..."
# Target structure: $TARGET_DIR/debian/ (exactly the same as the debian in current directory)
cp -a "$SOURCE_DEBIAN_DIR" "./"

echo "==> Starting build: dpkg-buildpackage -us -uc -tc"
# Note: build artifacts (.deb/.dsc etc.) will be generated in $TARGET_ROOT (one level above the source directory)
# For parallel build, consider: DEB_BUILD_OPTIONS="parallel=$(nproc)" dpkg-buildpackage ...
if ! dpkg-buildpackage -us -uc -tc; then
    echo "Error: Build failed."
    exit 1
fi

mkdir -p ../deb/sigma-dut

mv ../sigma-dut_* ../deb/sigma-dut/
mv ../sigma-dut-* ../deb/sigma-dut/

echo "==> Done!"
echo "Repository path: $TARGET_DIR"
echo "Current HEAD: $(git rev-parse HEAD)"
echo "debian directory copied to: $TARGET_DIR/debian"
echo "Build output directory: $TARGET_ROOT"
