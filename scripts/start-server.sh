#!/bin/bash
ARCH="armv7"
CUR_V="$(find ${DATA_DIR} -name DoH-Client-v*-$ARCH.tar.gz | cut -d '-' -f 3,4 | cut -d 'v' -f2 | sed 's/\.tar\.gz//g')"
LAT_V="$(wget -qO- https://github.com/ich777/versions/raw/master/DoH | grep FORK | cut -d '=' -f2)"
if [ -z "$LAT_V" ]; then
	LAT_V="$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/m13253/dns-over-https/tags | jq -r '.[0].name' | cut -c2-)"
fi
if [ -z "$LAT_V" ]; then
	if [ ! -z "$CUR_V" ]; then
		echo "---Can't get latest version of DoH-Client falling back to v$CUR_V---"
		LAT_V="$CUR_V"
	else
		echo "---Something went wrong, can't get latest version of DoH, putting container into sleep mode---"
		sleep infinity
	fi
fi

echo "---Version Check---"
if [ -z "$CUR_V" ]; then
	echo "---DoH-Client not installed, installing---"
    cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/DoH-Client-v$LAT_V-$ARCH.tar.gz https://github.com/ich777/dns-over-https/releases/download/$LAT_V/DoH-Client-v$LAT_V-$ARCH.tar.gz ; then
    	echo "---Sucessfully downloaded DoH---"
    else
    	echo "---Something went wrong, can't download DoH, putting container in sleep mode---"
        sleep infinity
    fi
	if [ ! -d ${DATA_DIR}/doh-client ]; then
		mkdir ${DATA_DIR}/doh-client
	fi
	tar -C ${DATA_DIR}/doh-client -xzf ${DATA_DIR}/DoH-Client-v$LAT_V-$ARCH.tar.gz
elif [ "$CUR_V" != "$LAT_V" ]; then
	echo "---Version missmatch, installed v$CUR_V, downloading and installing latest v$LAT_V...---"
    cd ${DATA_DIR}
	rm -R ${DATA_DIR}/doh-client ${DATA_DIR}/DoH-Client-v$CUR_V-$ARCH.tar.gz
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/DoH-Client-v$LAT_V-$ARCH.tar.gz https://github.com/ich777/dns-over-https/releases/download/$LAT_V/DoH-Client-v$LAT_V-$ARCH.tar.gz ; then
    	echo "---Sucessfully downloaded DoH---"
    else
    	echo "---Something went wrong, can't download DoH, putting container in sleep mode---"
        sleep infinity
    fi
	if [ ! -d ${DATA_DIR}/doh-client ]; then
		mkdir ${DATA_DIR}/doh-client
	fi
	tar -C ${DATA_DIR}/doh-client -xzf ${DATA_DIR}/DoH-Client-v$LAT_V-$ARCH.tar.gz
elif [ "$CUR_V" == "$LAT_V" ]; then
	echo "---DoH-Client v$CUR_V up-to-date---"
fi

echo "---Preparing DoH-Client---"
if [ ! -f ${DATA_DIR}/doh-client.conf ]; then
	cd ${DATA_DIR}
	if wget -qO doh-client.conf "https://raw.githubusercontent.com/ich777/docker-DoH-Client/master/config/doh-client.conf" --show-progress ; then
		echo "---Sucessfully downloaded configuration file 'doh-client.conf' located in the root directory of the container---"
	else
		echo "---Something went wrong, can't download 'doh-client.conf', putting server in sleep mode---"
		sleep infinity
	fi
fi
find ${DATA_DIR} -name ".*" -exec rm -R -f {} \;
rm -R ${DATA_DIR}/dohinstalled-* ${DATA_DIR}/gopath 2&>/dev/null
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Starting DoH-Client---"
cd ${DATA_DIR}/doh-client
${DATA_DIR}/doh-client/doh-client -conf ${DATA_DIR}/doh-client.conf