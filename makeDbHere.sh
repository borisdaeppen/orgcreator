#!/bin/sh

# put new source in package tree
echo "copy source to package tree"
rm debian/usr/bin/*
rm -Rf debian/opt/orgcreator/lib
cp orgcreator.pl debian/usr/bin/orgcreator
cp orgcreator_gui.sh debian/usr/bin/orgcreator_gui
cp -R lib debian/opt/orgcreator/

# update md5sums file of dep-tree
echo "update md5sums file"
rm debian/DEBIAN/md5sums
for i in $( find debian/opt/ debian/usr/ -type f ); do
        md5sum $i | sed -e "s/debian//g" >> debian/DEBIAN/md5sums
done

# create deb package
echo "build package"
dpkg-deb --build debian orgcreator_\
$( grep Version debian/DEBIAN/control | cut -d" " -f2 )_\
$( grep Architecture debian/DEBIAN/control | cut -d" " -f2 )\
.deb

