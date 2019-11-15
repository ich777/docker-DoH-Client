#!/bin/bash
CUR_V="$(find ${DATA_DIR} -name dohinstalled-* | cut -d '-' -f 2,3)"
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking if DoH-Client is installed---"
if [ ! -f ${DATA_DIR}/doh-client/doh-client ]; then
	echo "---DoH-Client not installed, installing---"
    cd ${DATA_DIR}
    if wget ${GO_DL_URL} ; then
		echo "---Sucessfully downloaded Golang---"
    else
		echo "---Something went wrong, can't download Golang, putting server in sleep mode---"
		sleep infinity
    fi
    tar xzf go*
    export GOROOT=/DoH/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
    if [ ! -d ${DATA_DIR}/gopath ]; then
    	mkdir gopath
    fi
    export GOPATH=/DoH/gopath/
	if wget https://github.com/m13253/dns-over-https/archive/v${DoH_V}.tar.gz ; then
    	echo "---Sucessfully downloaded DoH---"
    else
    	echo "---Something went wrong, can't download DoH, putting server in sleep mode---"
        sleep infinity
    fi
	tar xzf v${DoH_V}.tar.gz
	touch dohinstalled-${DoH_V}
    CUR_V=${DoH_V}
	rm *.tar.gz
	cd ${DATA_DIR}/dns-over-https-${DoH_V}
	make
	mv ${DATA_DIR}/dns-over-https-${DoH_V}/doh-client/ ${DATA_DIR}
   	rm ${DATA_DIR}/doh-client/doh-client.conf
	cd ${DATA_DIR}
	rm -R ${DATA_DIR}/dns-over-https-${DoH_V} ${DATA_DIR}/go ${DATA_DIR}/gopath
else
	echo "---DoH-Client found!---"
fi

echo "---Version Check---"
if [ "${DoH_V}" != "$CUR_V" ]; then
	echo "---Version missmatch v${CUR_V} installed, installing v${DoH_V}---"
    rm ${DATA_DIR}/dohinstalled-${CUR_V}
	cd ${DATA_DIR}
    if wget ${GO_DL_URL} ; then
		echo "---Sucessfully downloaded Golang---"
    else
		echo "---Something went wrong, can't download Golang, putting server in sleep mode---"
		sleep infinity
    fi
    tar xzf go*
    export GOROOT=/DoH/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
    if [ ! -d ${DATA_DIR}/gopath ]; then
    	mkdir gopath
    fi
    export GOPATH=/DoH/gopath/
	if wget https://github.com/m13253/dns-over-https/archive/v${DoH_V}.tar.gz ; then
    	echo "---Sucessfully downloaded DoH---"
    else
    	echo "---Something went wrong, can't download DoH, putting server in sleep mode---"
        sleep infinity
    fi
	tar xzf v${DoH_V}.tar.gz
	touch dohinstalled-${DoH_V}
	rm *.tar.gz
	cd ${DATA_DIR}/dns-over-https-${DoH_V}
	make
    rm -R ${DATA_DIR}/doh-client
	mv ${DATA_DIR}/dns-over-https-${DoH_V}/doh-client/ ${DATA_DIR}
    rm ${DATA_DIR}/doh-client/doh-client.conf
	cd ${DATA_DIR}
	rm -R ${DATA_DIR}/dns-over-https-${DoH_V} ${DATA_DIR}/go ${DATA_DIR}/gopath
elif [ "${DoH_V}" == "$CUR_V" ]; then
	echo "---Versions match! Installed: v$CUR_V | Preferred: v${DoH_V}---"
fi


if [ ! -f ${DATA_DIR}/doh-client.conf ]; then
	cd ${DATA_DIR}
	if wget -qO doh-client.conf "https://raw.githubusercontent.com/ich777/docker-DoH-Client/master/config/doh-client.conf" --show-progress ; then
		echo "---Sucessfully downloaded configuration file 'doh-client.conf' located in the root directory of the container---"
	else
		echo "---Something went wrong, can't download 'doh-client.conf', putting server in sleep mode---"
		sleep infinity
	fi
fi

echo "---Preparing Server---"
find ${DATA_DIR} -name ".*" -exec rm -R -f {} \;
chmod -R 777 ${DATA_DIR}

echo "---Starting Server---"
cd ${DATA_DIR}/doh-client
${DATA_DIR}/doh-client/doh-client -conf ${DATA_DIR}/doh-client.conf