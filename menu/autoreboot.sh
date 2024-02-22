#!/bin/bash

if [ ! -e /usr/local/bin/reboot_otomatis ]; then
echo '#!/bin/bash' > /usr/local/bin/reboot_otomatis 
echo 'tanggal=$(date +"%m-%d-%Y")' >> /usr/local/bin/reboot_otomatis 
echo 'waktu=$(date +"%T")' >> /usr/local/bin/reboot_otomatis 
echo 'echo "Server successfully rebooted on the date of $tanggal hit $waktu." >> /root/log-reboot.txt' >> /usr/local/bin/reboot_otomatis 
echo '/sbin/shutdown -r now' >> /usr/local/bin/reboot_otomatis 
chmod +x /usr/local/bin/reboot_otomatis
fi

if [ -f /etc/cron.d/reboot_otomatis ]; then
STATUS="ON"
else
STATUS="OFF"
fi

echo -e "╒════════════════════════════════════════════╕"
echo  -e "                 AUTO REBOOT                "
echo -e "╘════════════════════════════════════════════╛"
echo -e "   [*] Auto-Reboot Status: $STATUS"
echo -e "   [0] Exit Script"
echo -e "   [1] Set Auto-Reboot Setiap 6 jam"
echo -e "   [2] Set Auto-Reboot Setiap 12 jam"
echo -e "   [3] Set Auto-Reboot Setiap 1 hari"
echo -e "   [4] Set Auto-Reboot Setiap 1 minggu"
echo -e "   [5] Matikan Auto-Reboot"
echo -e "╘════════════════════════════════════════════╛"
echo -e " "

read -p " Select menu: " smenu
if test $smenu -eq 0; then
exit
elif test $smenu -eq 1; then
echo "10 */6 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo "Auto-Reboot has been successfully set every 6 hours."
elif test $smenu -eq 2; then
echo "10 */12 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo "Auto-Reboot has been successfully set every 12 hours."
elif test $smenu -eq 3; then
echo "10 0 * * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo "Auto-Reboot has been successfully set once a day."
elif test $smenu -eq 4; then
echo "10 0 */7 * * root /usr/local/bin/reboot_otomatis" > /etc/cron.d/reboot_otomatis
echo "Auto-Reboot has been successfully set once a week."
elif test $smenu -eq 5; then
rm -f /etc/cron.d/reboot_otomatis
echo "Auto-Reboot successfully TURNED OFF."
else
echo -e "Menu tidak ada..."
exit
fi