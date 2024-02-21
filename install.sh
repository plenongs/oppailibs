#!/bin/bash


mkdir -p /etc/oppailibs
mkdir -p /etc/oppailibs/menu
mkdir -p /usr/local/etc/oppailibs

apt install socat dnsutils curl nginx unzip -y
apt install certbot -y
systemctl stop nginx


#DOMAIN SERVER SETTING
#PASTIKAN DOMAIN SUDAH MEMILIKI SUBDOMAIN YANG SUDAH TERPOINTING KE VPS
#SUBDOMAIN 1: v2ray.domainkamu.op (XRAY)
#SUBDOMAIN 2: noobz.domainkamu.op (NOOBZVPNS)

DOMAIN=`cat /root/oppailibs/oppai.txt | grep 'DOMAIN ' | sed -e 's/DOMAIN //g'`
echo -e "Domain: $DOMAIN"
read -rp "Domain sudah benar (y/n)? " domainask

if [[ "$domainask" != "y" ]]; then
echo "Silakan ganti domain di /root/oppailibs/oppai.txt"
exit
fi

#COPPYING FILE AND MENU
mv /root/oppailibs/files/menu.sh /usr/bin/oppai
mv /root/oppailibs/menu/* /etc/oppailibs/menu
mv /root/oppailibs/files/exp-cron.sh /usr/bin/expuser
cp /root/oppailibs/oppai.txt /etc/oppailibs/oppai.txt
chmod -R 755 /etc/oppailibs
chmod 700 /usr/bin/oppai
chmod 700 /usr/bin/expuser

## MEMBUAT SERTIFIKAT SSL DENGAN CERTBOT
certbot certonly --standalone --preferred-challenges http --agree-tos --email lasttrying001@gmail.com -d oppai.$DOMAIN -d v2ray.$DOMAIN --cert-name oppailibs
cp /etc/letsencrypt/live/oppailibs/fullchain.pem /usr/local/etc/oppailibs/fullchain.pem
cp /etc/letsencrypt/live/oppailibs/privkey.pem /usr/local/etc/oppailibs/privkey.pem

chown root:root /usr/local/etc/oppailibs/fullchain.pem
chown root:root /usr/local/etc/oppailibs/privkey.pem

if [[ ! -f /usr/local/etc/oppailibs/fullchain.pem && ! -f /usr/local/etc/oppailibs/privkey.pem ]];then
echo -e "Gagal membuat sertifikat..."
exit
fi

### INSTALASI SCRIPT

chmod +x files/install-xray.sh && ./files/install-xray.sh
chmod +x files/install-noobzvpns.sh && ./files/install-noobzvpns.sh
chmod +x files/install-bbr.sh && ./files/install-bbr.sh

### GANTI NGINX.CONF & RUBAH DEFAULT NGINX.CONF KE .BAK
read -rp "Ganti nginx conf (y/n)? " takon
if [[ "$takon" == "y" ]]; then

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cat > /etc/nginx/nginx.conf << END
worker_processes 1;
pid /var/run/nginx.pid;

events {
	multi_accept on;
  worker_connections 1024;
}

http {
	gzip on;
	gzip_vary on;
	gzip_comp_level 5;
	gzip_types text/plain application/x-javascript text/javascript application/octet-stream text/xml text/css application/protobuf application/vnd.android.package-archive application/binary application/zip application/json application/javascript application/x-www-form-urlencoded application/geo+json application/manifest+json application/x-web-app-manifest+json text/cache-manifest text/x-component text/x-cross-domain-policy;

	autoindex on;
  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  charset UTF-8;
  source_charset UTF-8;
  charset_types text/plain application/octet-stream text/javascript application/json;
  keepalive_timeout 165;
  types_hash_max_size 2048;
  server_tokens off;
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;
  client_max_body_size 32M;
	client_header_buffer_size 8m;
	large_client_header_buffers 8 8m;

	fastcgi_buffer_size 8m;
	fastcgi_buffers 10 8m;

	fastcgi_read_timeout 600;

	set_real_ip_from 204.93.240.0/24;
	set_real_ip_from 204.93.177.0/24;
	set_real_ip_from 199.27.128.0/21;
	set_real_ip_from 173.245.48.0/20;
	set_real_ip_from 103.21.244.0/22;
	set_real_ip_from 103.22.200.0/22;
	set_real_ip_from 103.31.4.0/22;
	set_real_ip_from 141.101.64.0/18;
	set_real_ip_from 108.162.192.0/18;
	set_real_ip_from 190.93.240.0/20;
	set_real_ip_from 188.114.96.0/20;
	set_real_ip_from 197.234.240.0/22;
	set_real_ip_from 198.41.128.0/17;
	real_ip_header CF-Connecting-IP;

  include /etc/nginx/conf.d/*.conf;
  add_header 'Access-Control-Expose-Headers' 'Content-Lenght,Content-Range';
  add_header Strict-Transport-Security "max-age=999999999; includeSubDomains; preload";
}
END
echo -e "NGINX.CONF: USER"
else
echo -e "NGINX.CONF: DEFAULT"
fi

### CRONJOB EXP USER
cat > /etc/cron.d/exp_user <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/expuser
END

service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1

systemctl daemon-reload
systemctl stop noobzvpns.service
systemctl start noobzvpns.service
systemctl enable noobzvpns.service
systemctl restart noobzvpns.service
systemctl stop xray.service
systemctl start xray.service
systemctl enable xray.service
systemctl restart xray.service
systemctl restart nginx