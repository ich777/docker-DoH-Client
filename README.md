# DNS over HTTPS (DoH) Client in Docker optimized for Unraid
This is a simple DoH Client for Unraid, it is based on the DoH Client component from: https://github.com/m13253/dns-over-https

This Container will create a DNS Server wich connects by default to Goole's & DNS.SB's DoH resolver with ECS disabled (you can change that simply by editing the 'doh-client.conf' in your root directory of the container)

You easily can now hide your DNS querys from your ISP with this docker for your whole internal network, you can use it in combination with DoH-Server to protect even your mobile devices and encrypt all your querys.

You can also use this infront of your PiHole to also block Ad's and with DoH-Server to secure your mobile devices.

If you have any questions feel free to ask them on the support thread in the Unraid Forums.

Update Notice: If you want to upgrade to a newer version of the DoH-Server just enter the preferred version number (eg. '2.1.2' without quotes, get them from here: https://github.com/m13253/dns-over-https/releases)

The Docker needs to be run in bridge mode and a Fixed IP address and with the CAP and SYSCTL in the run example below added.

>**NOTE:** Please also check out the github page of the creater from DoH: https://github.com/m13253

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DoH_V | Version to install | 2.1.2 |
| GO_DL_URL | The download url for Golang | https://dl.google.com/go/go1.1... |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

## Run example
```
docker run --name DoH-Client -d \
    --p 53:53 -p 53:53/udp \
	--env 'DoH_V=2.1.2' \
	--env 'GO_DL_URL=https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz' \
	--env 'UID=99' \
	--env 'GID=100' \
	--volume /mnt/user/appdata/doh-client:/DoH \
    --net=br1 \
    --ip=192.168.1.8 \
    --restart=unless-stopped \
    --cap-add=NET_ADMIN \
    --sysctl net.ipv4.ip_unprivileged_port_start=0 \
	ich777/doh-client
```
>**NOTE** Please note that i recommend you to run this container in 'Bridge' mode and assign it a dedicated IP adress.


This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/