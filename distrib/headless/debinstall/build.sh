
#!/usr/bin/env bash

# IMPORTANT 
# Protect agaisnt mispelling a var and rm -rf /
set -u
set -e

SRC=/tmp/maracuya-jukebox-deb-src
DIST=/tmp/maracuya-jukebox-deb-dist
SYSROOT=${SRC}/sysroot
DEBIAN=${SRC}/DEBIAN

rm -rf ${DIST}
mkdir -p ${DIST}/

rm -rf ${SRC}
rsync -a deb-src/ ${SRC}/
mkdir -p ${SYSROOT}/opt/

rsync -a ../../../maracuya/ ${SYSROOT}/opt/maracuya/maracuya-jukebox/ --delete

pushd ${SYSROOT}/opt/maracuya-jukebox/
npm install --production
popd

find ${SRC}/ -type d -exec chmod 0755 {} \;
find ${SRC}/ -type f -exec chmod go-w {} \;
chown -R root:root ${SRC}/

let SIZE=`du -s ${SYSROOT} | sed s'/\s\+.*//'`+8
pushd ${SYSROOT}/
tar czf ${DIST}/data.tar.gz [a-z]*
popd

sed s"/\$SIZE/${SIZE}/" -i ${DEBIAN}/control
sed s"/\$VERSION/0.1.4/" -i ${DEBIAN}/control
sed s"/\$ARCH/arm/" -i ${DEBIAN}/control

pushd ${DEBIAN}
tar czf ${DIST}/control.tar.gz *
popd

pushd ${DIST}/
echo 2.0 > ./debian-binary

find ${DIST}/ -type d -exec chmod 0755 {} \;
find ${DIST}/ -type f -exec chmod go-w {} \;
chown -R root:root ${DIST}/
ar r ${DIST}/hellonode-1.deb debian-binary control.tar.gz data.tar.gz
popd
rsync -a ${DIST}/hellonode-1.deb ./