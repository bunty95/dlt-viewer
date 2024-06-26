#!/usr/bin/env bash
set -ex

SRC_DIR=$(pwd)
BUILD_DIR="${SRC_DIR}/build"
INSTALL_DIR="${BUILD_DIR}/install"
APP_DIR_NAME="DLTViewer.app"
APP_DIR_NAME_ZIP="DLTViewer.zip"
PATH_APP="${INSTALL_DIR}/${APP_DIR_NAME}"
PATH_ZIP="${INSTALL_DIR}/${APP_DIR_NAME_ZIP}"


echo Check Path for .app and .zip

echo "App path := ${PATH_APP}"
echo "Zip path := ${PATH_ZIP}"

rm -rf "${INSTALL_DIR}"
rm -rf "${SRC_DIR}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

if [[ $(uname -m) == 'arm64' ]]; then
  Qt5_DIR="/opt/homebrew/opt/qt@5"
  echo "Build with cmake $(uname -m) $Qt5_DIR"
  qmake ../BuildDltViewer.pro
#  cmake ..
else
  Qt5_DIR="/usr/local/opt/qt"
  echo "Build with qmake $(uname -m) $Qt5_DIR"
  qmake ../BuildDltViewer.pro
#  make
fi

#make

echo Cleanup
rm -rf "${INSTALL_DIR}"
rm -rf "${SRC_DIR}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

echo Build with CMake
# Installation paths configuration creates proper macOS Application bundle structure
# https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html
cmake -G Ninja \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
  -DCMAKE_PREFIX_PATH=${Qt5_DIR}/lib/cmake \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=12.7 \
  -DCMAKE_BUILD_TYPE=Release \
  -DDLT_USE_QT_RPATH=ON \
  -DDLT_PARSER=OFF \
  -DDLT_APP_DIR_NAME=${APP_DIR_NAME} \
  -DDLT_LIBRARY_INSTALLATION_PATH="${APP_DIR_NAME}/Contents/Frameworks" \
  -DDLT_EXECUTABLE_INSTALLATION_PATH="${APP_DIR_NAME}/Contents/MacOS" \
  -DDLT_RESOURCE_INSTALLATION_PATH="${APP_DIR_NAME}/Contents/Resources" \
  -DDLT_PLUGIN_INSTALLATION_PATH="${APP_DIR_NAME}/Contents/MacOS/plugins" \
  "${SRC_DIR}"
cmake --build "${BUILD_DIR}"

# See src/cmake/Darwin.cmake and scripts/darwin/package.cmake
#
# CPack macOS "Bundle generator" and "DragNDrop Generator" are NOT used. Their functionality is replaced by macdeployqt.
# - https://cmake.org/cmake/help/latest/cpack_gen/bundle.html
# - https://cmake.org/cmake/help/latest/module/CPackDMG.html
#
# External CPack generator calls "cmake --install" and "macdeployqt"
# - https://doc.qt.io/qt-5/macos-deployment.html
#
# CMake install takes care of proper macOs Application bundle setup. Each CMake target has a pre-configured path in bundle.
# macdeployqt copies all used QT5 Frameworks into bundle and patches RPATH in project binaries.
cpack -G External

cd "${BUILD_DIR}"
FULL_VERSION=$(cat "${BUILD_DIR}/full_version.txt")
echo "FULL_VERSION=${FULL_VERSION}"

echo Codesign using certificate with secrets from github
codesign --timestamp --options=runtime -s "${APPLE_CERTIFICATE}" -v ${INSTALL_DIR}/${APP_DIR_NAME} --deep
ditto -c -k --keepParent ${PATH_APP} ${PATH_ZIP}
xcrun notarytool submit --apple-id "${APPLE_ID}" --team-id "${TEAM_ID}" --password "${APP_PASSWORD}" ${PATH_ZIP}
xcrun stapler staple ${PATH_APP}


mkdir -p dist
cp ../scripts/darwin/install.md dist
tar -czvf "dist/DLTViewer-${FULL_VERSION}.tgz" -C ${INSTALL_DIR} .
