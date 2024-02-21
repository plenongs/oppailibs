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
sed -i '/#trojanws$/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

trojanlink="trojan://${uuid}@isi_bug_disini:443?path=%2Ftrojan-ws&security=tls&host=v2ray.${domain}&type=ws&sni=v2ray.${domain}#${user}"
trojanlink1="trojan://${uuid}@isi_bug_disini:80?path=%2Ftrojan-ws&security=none&host=v2ray.${domain}&type=ws#${user}"
systemctl restart xray
service cron restart > /dev/null 2>&1

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "\E[0;41;36m           TROJAN ACCOUNT           \E[0m" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 
echo -e "Remarks        : ${user}" 
echo -e "Host/IP        : ${domain}" 
echo -e "Port TLS       : 443" 
echo -e "Port none TLS  : 80"
echo -e "Key            : ${uuid}"
echo -e "Path           : /trojan-ws"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 
echo -e "Link TLS       : ${trojanlink}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 
echo -e "Link none TLS  : ${trojanlink1}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Expired On     : $exp" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"