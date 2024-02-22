#!/bin/bash


DELETE_XRAY(){
case $1 in 
1) 
REGEXS="###"
AKUNS="VMESS"
;;
2)
REGEXS="#&" 
AKUNS="VLESS"
;;
3) 
REGEXS="#!" 
AKUNS="TROJAN"
;;
esac
read -rp "Username: " user
exp=$(grep -wE "^$REGEXS $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
if [ -z $exp ]; then
echo -e "[ERROR] Username $AKUNS: $user Tidak di temukan.."
else
sed -i "/^$REGEXS $user $exp/,/^},{/d" /etc/xray/config.json
echo -e "[INFO] Success hapus akun Username: $user"
systemctl restart xray > /dev/null 2>&1
fi
}

echo -e "╒════════════════════════════════════════════╕"
echo -e "                 HAPUS AKUN                "
echo -e "╘════════════════════════════════════════════╛"
echo -e "   [0] Exit Script"
echo -e "   [1] Hapus Akun Noobzvpns"
echo -e "   [2] Hapus Akun Vmess"
echo -e "   [3] Hapus Akun Vless"
echo -e "   [4] Hapus Akun Trojan"
echo -e "   [5] Kembali ke Menu"
echo -e "╘════════════════════════════════════════════╛"
echo -e " "
read -rp "[*] Input Number: " inputx

case $inputx in
0)
exit
;;
1)
read -rp "Username: " user
noobs=`noobzvpns --remove-user $user | grep "INFO"`
if [ -z "$noobs" ]; then
echo -e "[ERROR] Username: $user tidak di temukan"
else
echo -e "[INFO] Success hapus akun, Username: $user"
fi
;;
2)
DELETE_XRAY 1
;;
3)
DELETE_XRAY 2
;;
4)
DELETE_XRAY 3
;;
5)
oppai
;;
esac