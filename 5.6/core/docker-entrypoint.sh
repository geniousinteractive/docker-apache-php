#!/bin/bash -e
set -e

# Set the apache user and group to match the host user.
# This script will change the www-data UID/GID in the container from to 33 (default) to the UID/GID of the host user, if the current host user is not root.
OWNER=$(stat -c '%u' /var/www/html)
GROUP=$(stat -c '%g' /var/www/html)
USERNAME=www-data
[ -e "/etc/debian_version" ] || USERNAME=apache
if [ "$OWNER" != "0" ]; then
  usermod -o -u $OWNER $USERNAME
  usermod -s /bin/bash $USERNAME
  groupmod -o -g $GROUP $USERNAME
  usermod -d /var/www/html $USERNAME
  chown -R --silent $USERNAME:$USERNAME /var/www/html
fi
echo The apache user and group has been set to the following:
id $USERNAME

usermod -d /var/www www-data

# Apache2 custom servername, alias and documentroot
sed -i "s/MYSERVERNAME/$SERVERNAME/g" /etc/apache2/apache2.conf
sed -i "s/MYSERVERALIAS/$SERVERALIAS/g" /etc/apache2/apache2.conf
sed -i "s/MYDOCUMENTROOT/$DOCUMENTROOT/g" /etc/apache2/apache2.conf

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

# Start Apache in foreground
/usr/sbin/apache2 -DFOREGROUND

SET /P Host= | /sbin/ip route|awk '/default/ { print $3 }'
echo xdebug.remote_host=%Host% >> /usr/local/etc/php/conf.d/xdebug.ini;

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
echo 'export rvm_prefix="$HOME"' > /root/.rvmrc
echo 'export rvm_path="$HOME/.rvm"' >> /root/.rvmrc
RUN \curl -L https://get.rvm.io | rvm_path=/root/rvm bash -s stable
RUN /bin/bash -l -c "rvm requirements"
