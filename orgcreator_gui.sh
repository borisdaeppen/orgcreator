#!/bin/bash

# to avoid a known bug I need to export this variable
# see https://bugs.launchpad.net/ubuntu/+source/libcanberra/+bug/368175
export XDIALOG_NO_GMSGS=1

Xdialog --backtitle "Change Options" --title "orgcreator" \
        --checklist "Below you see all available options with their default value.\nChoose those you whish to change." 30 61 6 \
        "platform"  "[mysql]" off \
        "database"  "[orangehrm]" on \
        "host"      "[localhost]" off \
        "port"      "[3306]" off \
        "user"      "[root]" on \
        "pw"        "[123]" on \
        "file"      "[company_organigram]" off \
        "module"    "[dot,[txt,simple]]" off 2> /tmp/checklist.tmp.$$

retval=$?

choice=`cat /tmp/checklist.tmp.$$`
rm -f /tmp/checklist.tmp.$$
case $retval in
  0)
    echo "'$choice' chosen."
    ;;
  1)
    echo "Cancel pressed."
    exit 1
    ;;
  255)
    echo "Box closed."
    exit 1
    ;;
esac

arguments=""
for arg in $( echo "$choice" | sed "s/\//\n/g" ); do

    Xdialog --title "orgcreator" \
            --inputbox "please enter your value for the option '$arg'" 18 45 2> /tmp/inputbox.tmp.$$

    retval=$?
    input=`cat /tmp/inputbox.tmp.$$`
    rm -f /tmp/inputbox.tmp.$$

    case $retval in
      0)
        echo "Input string is '$input'"
        arguments="$arguments --$arg $input"
        ;;
      1)
        echo "Cancel pressed.";;
      255)
        echo "Box closed.";;
    esac

done

Xdialog --wrap --title "orgcreator"\
        --yesno "The following command will be run: orgcreator $arguments. Ok?" 0 0

case $? in
  0)
    echo "Yes chosen."
    /usr/bin/orgcreator $arguments
    ;;
  1)
    echo "No chosen."
    exit 1
    ;;
  255)
    echo "Box closed."
    exit 1
    ;;
esac
