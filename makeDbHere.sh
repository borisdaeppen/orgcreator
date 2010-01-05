#!/bin/sh

#empty old data
echo "delete old data"
rm debian/usr/bin/*
rm -Rf debian/opt/orgcreator/lib

if [ $1 == 'gtk' ] ; then
    echo "preparing for GTK-package"
    echo "creating control file"

    echo "Package: orgcreatorgtk
Version: 0.1
Section: utils
Priority: extra
Architecture: all
Depends: bash, graphviz, perl, libgtk2-perl
Maintainer: Boris Däppen <boris_daeppen@bluewin.ch>
Description: Create a company organigram out of your orangeHRM sources.
" > debian/DEBIAN/control
    # put new source in package tree
    echo "copy source tree to package"
    cp orgcreatorgtk.pl debian/usr/bin/orgcreator_gui
elif [ $1 == 'x' ] ; then
    echo "preparing for xdialog package"
    echo "creating control file"

    echo "Package: orgcreatorx
Version: 0.1
Section: utils
Priority: extra
Architecture: all
Depends: bash, graphviz, perl, xdialog
Maintainer: Boris Däppen <boris_daeppen@bluewin.ch>
Description: Create a company organigram out of your orangeHRM sources.
" > debian/DEBIAN/control
    # put new source in package tree
    echo "copy source tree to package"
    cp orgcreatorx.sh debian/usr/bin/orgcreator_gui
else
    echo "give 'gtk' or 'x' as an argument! ABORTING"
    exit 1
fi

# put new source in package tree
cp orgcreator.pl debian/usr/bin/orgcreator
cp -R lib debian/opt/orgcreator/

# update md5sums file of dep-tree
echo "update md5sums file"
rm debian/DEBIAN/md5sums
for i in $( find debian/opt/ debian/usr/ -type f ); do
        md5sum $i | sed -e "s/debian//g" >> debian/DEBIAN/md5sums
done

# create deb package
echo "build package"
dpkg-deb --build debian \
$( grep Package debian/DEBIAN/control | cut -d" " -f2 )_\
$( grep Version debian/DEBIAN/control | cut -d" " -f2 )_\
$( grep Architecture debian/DEBIAN/control | cut -d" " -f2 )\
.deb

echo "deleting control file"
rm debian/DEBIAN/control
rm debian/DEBIAN/md5sums

#empty old data
echo "delete old data"
rm debian/usr/bin/*
rm -Rf debian/opt/orgcreator/lib

