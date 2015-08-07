#!/bin/bash

CONTAINER="mirror"
source ~/.openstackrc

Setup_container() {
    apt-get install -y python-dev

    # Python 3.4 is not supported
    pip2 install python-keystoneclient
    pip2 install python-swiftclient

    swift post ${CONTAINER}
    swift upload ${CONTAINER} apaxy
    swift post --header "X-Container-Meta-Web-Listings: true" ${CONTAINER}
    swift post --header "X-Container-Read: .r:*,.rlistings" ${CONTAINER}
}

Build_apaxy4runabove() {
    wget https://github.com/AdamWhitcroft/Apaxy/archive/master.zip
    unzip master.zip

    cat ./Apaxy-master/apaxy/htaccess.txt \
    | sed -n 's;^\s*AddIcon /{FOLDERNAME}/theme/icons/\(\S\+ \.[^.].*\)$;\1;p' \
    | while read ICON; do
        IMAGE="${ICON%% *}"
        # Loop through extensions one-by-one
        echo "${ICON#* }" | grep -o "\.\S\+" \
            | while read EXT; do
                # Print CSS
                echo "td.colname a[href$=\"${EXT}\"]:before { background-image: url(icons/${IMAGE}); }"
            done
    done >> ./Apaxy-master/apaxy/theme/style.css

    # FIXME Add: html bg / @adamwhitcroft / th rules / td rules / additional PNG-s+rules

    swift upload $CONTAINER} ./Apaxy-master/apaxy/theme/icons --object-name=apaxy/icons
    swift upload $CONTAINER} ./Apaxy-master/apaxy/theme/style.css --object-name=apaxy/style.css
    swift post --header "X-Container-Meta-Web-Listings-CSS: /apaxy/style.css" ${CONTAINER}
}
