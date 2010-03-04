#!/bin/sh

# Copyright 2010 Boris Daeppen <boris_daeppen@bluewin.ch>
# 
# This file is part of orgcreator.
# 
# orgcreator is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# orgcreator is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with orgcreator.  If not, see <http://www.gnu.org/licenses/>.

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
Conflicts: orgcreatorx
Maintainer: Boris Däppen <boris_daeppen@bluewin.ch>
Description: Create a company organigram out of your OrangeHRM sources.
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
Conflicts: orgcreatorgtk
Maintainer: Boris Däppen <boris_daeppen@bluewin.ch>
Description: Create a company organigram out of your OrangeHRM sources.
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
fakeroot dpkg-deb --build debian \
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

