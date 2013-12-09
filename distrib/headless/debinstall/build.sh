
#!/usr/bin/env bash

# IMPORTANT 
# Protect agaisnt mispelling a var and rm -rf /
set -u
set -e

NODE_VERSION=`node -v`

ARCH=`dpkg --print-architecture`

VERSION=$1

APP_NAME=maracuya-jukebox-${VERSION}-${ARCH}
SRC=/tmp/${APP_NAME}
SYSROOT=${SRC}/
DEBIAN=${SRC}/DEBIAN

echo "Building Maracuya Jukebox for arch: $ARCH, version: $VERSION"

rm -rf ${SRC}
rsync -a deb-src/DEBIAN ${SRC}/
rsync -a deb-src/sysroot/* ${SRC}/
mkdir -p ${SYSROOT}/opt/maracuya/maracuya-jukebox/

rsync -a ../../../maracuya/ ${SYSROOT}/opt/maracuya/maracuya-jukebox/ --delete

pushd ${SYSROOT}/opt/maracuya/maracuya-jukebox/
npm install --production
find . -name *.o | xargs rm
popd

let SIZE=`du -s ${SYSROOT} | sed s'/\s\+.*//'`+8

sed s"/\$SIZE/${SIZE}/" -i ${DEBIAN}/control
sed s"/\$VERSION/${VERSION}/" -i ${DEBIAN}/control
sed s"/\$ARCH/${ARCH}/" -i ${DEBIAN}/control
sed s"/\@NODE_VERSION/${NODE_VERSION}/" -i ${DEBIAN}/preinst

chmod 755 ${DEBIAN}/*
 
pushd /tmp/${APP_NAME}
echo 2.0 > ${DEBIAN}/debian-binary
popd

fakeroot dpkg-deb --build /tmp/${APP_NAME}

rsync -a /tmp/${APP_NAME}.deb ./

