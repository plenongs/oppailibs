#!/bin/bash

domain=`cat /etc/oppailibs/oppai.txt | grep 'DOMAIN ' | sed -e 's/DOMAIN //g'`

until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
	read -rp "Username : " -e user
	CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

	if [[ ${CLIENT_EXISTS} == '1' ]]; then
		echo ""
		echo -e "Username ${CLIENT_NAME} Already On VPS Please Choose Another"
		exit 1
	fi
done

uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`

asu=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "v2ray.${domain}",
      "port": "443",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "",
      "tls": "tls"
}
EOF`
ask=`cat<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "v2ray.${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "",
      "tls": "none"
}
EOF`


vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmesslink1="vmess://$(echo $asu | base64 -w 0)"
vmesslink2="vmess://$(echo $ask | base64 -w 0)"
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 
echo -e "\\E[0;41;36m        Vmess Account        \E[0m" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Remarks        : ${user}"
echo -e "Domain         : v2ray.${domain}" 
echo -e "Port TLS       : 443" 
echo -e "Port none TLS  : 80" 
echo -e "id             : ${uuid}"
echo -e "alterId        : 0"
echo -e "Security       : auto"
echo -e "Network        : ws"
echo -e "Path           : /vmess"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 
echo -e "Link TLS       : ${vmesslink1}" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Link none TLS  : ${vmesslink2}" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 
echo -e "Expired On     : $exp" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 

