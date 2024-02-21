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
sed -i '/#vless$/a\#& '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

vlesslink1="vless://${uuid}@v2ray.${domain}:$tls?path=/vless&security=tls&encryption=none&type=ws#${user}"
vlesslink2="vless://${uuid}@v2ray.${domain}:$none?path=/vless&encryption=none&type=ws#${user}"

systemctl restart xray
service cron restart > /dev/null 2>&1

 echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 
echo -e "\E[44;1;39m        Vless Account        \E[0m" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Remarks        : ${user}" 
echo -e "Domain         : v2ray.${domain}" 
echo -e "Port TLS       : 443" 
echo -e "Port none TLS  : 80" 
echo -e "id             : ${uuid}" 
echo -e "Encryption     : none"
echo -e "Network        : ws" 
echo -e "Path           : /vless"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 
echo -e "Link TLS       : ${vlesslink1}" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Link none TLS  : ${vlesslink2}" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 
echo -e "Expired On     : $exp" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
