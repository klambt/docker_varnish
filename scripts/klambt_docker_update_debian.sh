#!/bin/bash
echo ' '

if [ "$UPDATE_DEBIAN" = 1 ]; then
    echo '#############################################'
    echo '#         UPDATING Debian Packages          #'
    echo '#                                           #'
    echo '#  This can be disabled during build with:  #'
    echo '#  -e "UPDATE_DEBIAN=0"                     #'
    echo '#                                           #'
    echo '#############################################'

    apt-get update
    apt-get upgrade -y

else 
    echo '#############################################'
    echo '#       NOT updating Debian Packages        #'
    echo '#                                           #'
    echo '#  This can be enable during build with:    #'
    echo '#  -e "UPDATE_DEBIAN=1"                     #'
    echo '#                                           #'
    echo '#############################################'
fi
echo ' '