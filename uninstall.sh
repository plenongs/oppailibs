#!/bin/bash

echo -e "Mematikan semua service Oppailibs.."
systemctl stop noobzvpns.service
systemctl stop xray.service
systemctl stop nginx
systemctl disable noobzvpns.service
systemctl disable xray.service

echob -e "Hapus semua file Oppailibs..."
##OPPAILIBS SCRIPT
rm -rf /etc/oppailibs
rm -f /usr/bin/oppai

##CRONJOBS DELETE
rm -f /etc/cron.d/reboot_otomatis /usr/local/bin/reboot_otomatis
rm -f /etc/cron.d/exp_user /usr/bin/expuser

##XRAY SCRIPT
rm -rf /etc/xray /var/log/xray 
rm -f /usr/local/bin/xray /usr/bin/xray /etc/nginx/conf.d/xray.conf 

##CERTBOT SERTIFIKAT
rm -rf /usr/local/etc/oppailibs
certbot delete --cert-name oppailibs

##noobzvpns
rm -rf /etc/noobzvpns
rm -f /usr/bin/noobzvpns /etc/nginx/conf.d/noobz.conf

##BBR UNINSTALL NEXT

apt remove socat dnsutils curl nginx unzip certbot -y
rm -rf /etc/nginx
sudo reboot