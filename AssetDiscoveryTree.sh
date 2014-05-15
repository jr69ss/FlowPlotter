#!/bin/bash

#Generates an Asset List using a pre-existing filter file.

#Usage
# Obtain a filter file with a large amount of network data, representative of all hosts on your network
# $ rwfilter --start-date=2014/05/13 --proto=0- --type=all --pass=sample.rw

# Run AssetDiscoveryTree.sh against the file and send to an output html file
# $ ./AssetDiscoveryTree.sh /home/jason/sample.rw > /home/jason/assetlist.html

echo '{ "name": "Assets","children": [ ' > flare.temp.json

rwfilter $1 --type=outweb --sport=80,443,8080 --protocol=6 --packets=4- --ack-flag=1 --pass=stdout|rwstats --fields=sip --percentage=1 --bytes --no-titles|cut -f 1 -d "|"|rwsetbuild > web_servers.set
rwfilter $1 --type=outweb --sport=80,443,8080 --protocol=6 --packets=4- --ack-flag=1 --sipset=web_servers.set --pass=stdout|rwuniq --fields=sip --bytes --sort-output --no-titles --delimited=,|sed 's/^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\),\([0-9]\{1,\}\)$/\t{"name": "\1", "size": \2},/g' |sed '$s/,$//g' | sed '1s/^/\{"name": "Web Servers",\n"children": [/' | sed '$s/$/\n\]},/'  >> flare.temp.json

rwfilter $1 --type=out --sport=25,465,110,995,143,993 --protocol=6 --packets=4- --ack-flag=1 --pass=stdout|rwset --sip-file=smtpservers.set
rwfilter $1 --type=out --sport=25,465,110,995,143,993 --sipset=smtpservers.set --protocol=6 --packets=4- --ack-flag=1 --pass=stdout|rwuniq --fields=sip --bytes --sort-output --no-titles --delimited=,|sed 's/^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\),\([0-9]\{1,\}\)$/\t{"name": "\1", "size": \2},/g' |sed '$s/,$//g' | sed '1s/^/\{"name": "SMTP Servers",\n"children": [/' | sed '$s/$/\n\]},/' >>flare.temp.json

rwfilter $1 --type=out --sport=53 --protocol=17 --pass=stdout|rwstats --fields=sip --percentage=1 --packets --no-titles|cut -f 1 -d "|"| rwsetbuild > dnsservers.set
rwfilter $1 --type=out --sport=53 --protocol=17 --sipset=dnsservers.set --pass=stdout | rwuniq --fields=sip --bytes --sort-output --no-titles --delimited=,|sed 's/^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\),\([0-9]\{1,\}\)$/\t{"name": "\1", "size": \2},/g' |sed '$s/,$//g' | sed '1s/^/\{"name": "DNS Servers",\n"children": [/' | sed '$s/$/\n\]},/' >>flare.temp.json

rwfilter $1 --type=out --protocol=47,50,51 --pass=stdout|rwuniq --fields=sip --no-titles|cut -f 1 -d "|" |rwsetbuild > vpn.set
rwfilter $1 --type=out --sipset=vpn.set --pass=stdout|rwuniq --fields=sip --bytes --sort-output --no-titles --delimited=,|sed 's/^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\),\([0-9]\{1,\}\)$/\t{"name": "\1", "size": \2},/g' |sed '$s/,$//g' | sed '1s/^/\{"name": "VPN Servers",\n"children": [/' | sed '$s/$/\n\]},/' >>flare.temp.json

rwfilter $1 --type=out --protocol=6 --packets=4- --ack-flag=1 --sport=21 --pass=stdout|rwstats --fields=sip --percentage=1 --bytes --no-titles|cut -f 1 -d "|"|rwsetbuild > ftpservers.set
rwfilter $1 --type=out --sipset=ftpservers.set --sport=20 --flags-initial=S/SAFR --pass=stdout|rwuniq --fields=sip --bytes --sort-output --no-titles --delimited=,|sed 's/^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\),\([0-9]\{1,\}\)$/\t{"name": "\1", "size": \2},/g' |sed '$s/,$//g' | sed '1s/^/\{"name": "FTP Servers",\n"children": [/' | sed '$s/$/\n\]},/'  >>flare.temp.json

rwfilter $1 --type=out --protocol=6 --packets=4- --ack-flag=1 --sport=22 --pass=stdout|rwstats --fields=sip --percentage=1 --bytes --no-titles|cut -f 1 -d "|"|rwsetbuild>sshservers.set
rwfilter $1 --type=out --protocol=6 --packets=4- --ack-flag=1 --sipset=sshservers.set --sport=22 --pass=stdout | rwuniq --fields=sip --bytes --sort-output --no-titles --delimited=,|sed 's/^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\),\([0-9]\{1,\}\)$/\t{"name": "\1", "size": \2},/g' |sed '$s/,$//g' | sed '1s/^/\{"name": "SSH Servers",\n"children": [/' | sed '$s/$/\n\]},/' >>flare.temp.json

rwfilter $1 --type=out --protocol=6 --packets=4- --ack-flag=1 --sport=23 --pass=stdout|rwstats --fields=sip --percentage=1 --bytes --no-titles|cut -f 1 -d "|"|rwsetbuild > telnetservers.set
rwfilter $1 --type=out --protocol=6 --packets=4- --ack-flag=1 --sipset=telnetservers.set --sport=23 --pass=stdout|rwuniq --fields=sip --bytes --sort-output --no-titles --delimited=,|sed 's/^\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\),\([0-9]\{1,\}\)$/\t{"name": "\1", "size": \2},/g' |sed '$s/,$//g' | sed '1s/^/\{"name": "Telnet Servers",\n"children": [/' | sed '$s/$/\n\]},/'  >>flare.temp.json

cat flare.temp.json | sed '$s/,$/\n/' | sed '$s/$/\]\}/' | tr '\n' ' ' | sed "s/^/var myjson = '/"| sed "s/$/';/" > assets.json

sed '/dataplaceholder/{
    s/dataplaceholder//g
    r assets.json
}' d3chart/treeasset.html

rm *.set
rm flare.temp.json
rm assets.json
