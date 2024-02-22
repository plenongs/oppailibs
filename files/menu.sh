#!/bin/bash

cat <<"EOF"
   ___                    _ _     _ _         
  / _ \ _ __  _ __   __ _(_) |   (_) |__  ___ 
 | | | | '_ \| '_ \ / _` | | |   | | '_ \/ __|
 | |_| | |_) | |_) | (_| | | |___| | |_) \__ \
  \___/| .__/| .__/ \__,_|_|_____|_|_.__/|___/
       |_|   |_|                              
EOF

echo -e "[..] Mohon tunngu sedang memprosses data..."
RESTART_ALLSERVICE(){
  systemctl daemon-reload
  systemctl restart noobzvpns.service
  systemctl restart xray.service
  systemctl restart nginx
  echo -e "[INFO] Restart all service done."
}

NOOBZVPNS_CREATE(){
  read -p "Username : " USERNAME
  read -p "Password : " PASSWORD
  read -p "Expired(Hari) : " EXPD
  if noobzvpns --add-user $USERNAME $PASSWORD | grep -i "INFO" > /dev/null; then
    if [ "$EXPD" != "" ]; then
      noobzvpns --expired-user $USERNAME $EXPD > /dev/null
    fi
    echo -e "[USER INFO]\nUsername: $USERNAME\nPasword: $PASSWORD\nPort: 443(TLS) / 80(PLAIN)\nExpired: $EXPD (Hari)\nServer: oppai.$DOMAIN"
  else
    echo -e "[ERROR] User sudah ada"
  fi 
}

CACHE_DROPX(){
  echo -e "[INFO] Clear Ram cache.."
  echo 1 > /proc/sys/vm/drop_caches
  sleep 3
  echo -e "[INFO] Cache cleard"
}

#OS INFORMATION
DOMAIN=`cat /etc/oppailibs/oppai.txt | grep 'DOMAIN ' | sed -e 's/DOMAIN //g'`
UPTIME="$(uptime -p | cut -d " " -f 2-10)"
OSNAME="$(hostnamectl | grep "Operating System" | cut -d ' ' -f5-)"

#ISP INFORMATION
ISP=$(curl -s ipinfo.io/org?token=ce3da57536810d | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city?token=ce3da57536810d )
COUNTRY=$(curl -s ipinfo.io/country?token=ce3da57536810d )
TRAM=$( free -m | awk 'NR==2 {print $2}' )
URAM=$( free -m | awk 'NR==2 {print $3}' )

EXPDAT=`certbot certificates 2>/dev/null| grep 'Expiry Date:' | awk -F ' ' '{print $3}'`
VALID=`certbot certificates 2>/dev/null| grep 'Expiry Date:' | awk -F ' ' '{print $6}'`
SER_ST=""
if [ "$VALID" != "0" ]; then
SER_ST="Active"
else
SER_ST="NonActive"
fi
echo -e "\033[1A\033[K"
echo -e "╒════════════════════════════════════════════╕"
echo -e "                 TUNNEL MENU                "
echo -e "╘════════════════════════════════════════════╛"

echo -e " "

echo -e "╒════════════════════════════════════════════╕"

echo -e "  OS System      : $OSNAME"
echo -e "  ISP            : $ISP"
echo -e "  CITY           : $CITY ($COUNTRY)"
echo -e "  Uptime         : $UPTIME"
echo -e "  Usage Ram      : $URAM MB / $TRAM MB"
echo -e "  Sertifikat     : $SER_ST"
echo -e "  Sertifikat exp : $EXPDAT"

echo -e "╘════════════════════════════════════════════╛"
echo -e " "

XRAY=`systemctl status xray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1`
NOOBX=`systemctl status noobzvpns | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1`
NGINXS=`systemctl status noobzvpns | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1`

if [[ $XRAY == "running" ]]; then
XRAY_STATUS="ON"
else
XRAY_STATUS="OFF"
fi

if [[ $NOOBX == "running" ]]; then
NOOBX_STATUS="ON"
else
NOOBX_STATUS="OFF"
fi

if [[ $NGINXS == "running" ]]; then
NGINXS_STATUS="ON"
else
NGINXS_STATUS="OFF"
fi

if [ -z `noobzvpns --info-all-user | grep "Total User"` ]; then
NOOBUSER=0
else
NOOBUSER=`noobzvpns --info-all-user | grep "Total User" | sed 's/Total User(s): //g'`
fi

VMUSER=`cat /etc/xray/config.json | grep '^###' | cut -d ' ' -f 2 | wc -l`
VLUSER=`cat /etc/xray/config.json | grep '^#&' | cut -d ' ' -f 2 | wc -l`
TRUSER=`cat /etc/xray/config.json | grep '^#!' | cut -d ' ' -f 2 | wc -l`

echo -e "╒════════════════════════════════════════════╕"

echo -e "        NGINX: $NGINXS_STATUS  | XRAY: $XRAY_STATUS | NOOBZVPNS: $NOOBX_STATUS"
echo -e "   VMESS: $VMUSER | VLESS: $VLUSER | TROJAN: $TRUSER | NOOBZVPNS: $NOOBUSER"

echo -e "╘════════════════════════════════════════════╛"
echo -e " "

echo -e "╒════════════════════════════════════════════╕"
echo -e " "
echo -e "   [0] Exit Script        | [5] Clear Cache"
echo -e "   [1] Create Vmess       | [6] Restart All Service"
echo -e "   [2] Create Trojan      | [7] Renew Sertifikat"
echo -e "   [3] Create Vless       | [8] Delete Account"
echo -e "   [4] Create Noobzvpns   | [9] Autoreboot Setting"
echo -e "╘════════════════════════════════════════════╛"
echo -e " "
read -r "[*] Input Number: " nmenu

case $nmenu in 
0)
exit
;;
1)
bash /etc/oppailibs/menu/cr-vmess.sh
;;
2)
bash /etc/oppailibs/menu/cr-vless.sh
;;
3)
bash /etc/oppailibs/menu/cr-trojan.sh
;;
4)
NOOBZVPNS_CREATE
;;
5)
CACHE_DROPX
;;
6)
RESTART_ALLSERVICE
;;
7)
echo -e "Comming next.."
;;
8)
bash /etc/oppailibs/menu/del-akun.sh
;;
9)
bash /etc/oppailibs/menu/autoreboot.sh
;;
esac