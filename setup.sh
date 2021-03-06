#!/usr/bin/env bash
# Copyright © 2009 Jason Perkins <jperkins@sneer.org>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or
# implied warranty.


# ---------------------------------------------------------------------------
# test for sudo invocation and get username who invoked script
# ---------------------------------------------------------------------------

if [ `whoami` != 'root' ] ; then
  echo "This script must be invoked with sudo."
  exit 1
fi


# ---------------------------------------------------------------------------
# test for sudo invocation and get username who invoked script
# ---------------------------------------------------------------------------

if [ -z $USER -o $USER = "root" ]; then
	if [ ! -z $SUDO_USER ]; then
		USER=$SUDO_USER
	else
		USER=""
		echo "ALERT! Your root shell did not provide your username."
		while : ; do
			if [ -z $USER ]; then
				while : ; do
					echo -n "Please enter *your* username: "
					read USER
					if [ -d /Users/$USER ]; then
						break
					else
						echo "$USER is not a valid username."
					fi
				done
			else
				break
			fi
		done
	fi
fi

if [ -z $DOC_ROOT_PREFIX ]; then
	DOC_ROOT_PREFIX="/Users/$USER/Sites"
fi


# ---------------------------------------------------------------------------
# get os x version that we're running on
# ---------------------------------------------------------------------------




# ---------------------------------------------------------------------------
# install macports
# ---------------------------------------------------------------------------

mkdir -p /opt/mports
cd /opt/mports
/usr/bin/svn checkout http://svn.macports.org/repository/macports/trunk/base
cd ./base/
./configure --enable-readline
make
sudo make install
sudo /opt/local/bin/port -v selfupdate
cd ~
sudo rm -rf /opt/mports



# ---------------------------------------------------------------------------
# macports install
# ---------------------------------------------------------------------------

sudo /opt/local/bin/port install bash-completion
sudo /opt/local/bin/port install bzip2
sudo /opt/local/bin/port install fetch
sudo /opt/local/bin/port install git-core +bash_completion
sudo /opt/local/bin/port install screen
sudo /opt/local/bin/port install watch
sudo /opt/local/bin/port install xtail


# ---------------------------------------------------------------------------
# install postgresql
# ---------------------------------------------------------------------------

sudo /opt/local/bin/port install postgresql84-server

sudo mkdir -p /opt/local/var/db/postgresql84/defaultdb
sudo chown postgres:postgres /opt/local/var/db/postgresql84/defaultdb
sudo su postgres -c '/opt/local/lib/postgresql84/bin/initdb -D /opt/local/var/db/postgresql84/defaultdb'


# modify pg logging
sudo sed -i -e 's/#client_min_messages = notice/client_min_messages = error/' \
  /opt/local/var/db/postgresql84/defaultdb/postgresql.conf

sudo sed -i -e 's/#log_min_messages = warning/log_min_messages = error/'  \
  /opt/local/var/db/postgresql84/defaultdb/postgresql.conf


# start pg via launchctl
sudo launchctl load -w /Library/LaunchDaemons/org.macports.postgresql84-server.plist
sudo /opt/local/etc/LaunchDaemons/org.macports.postgresql84-server/postgresql84-server.wrapper start


# ---------------------------------------------------------------------------
# centro config/setup
# ---------------------------------------------------------------------------

# sudo su postgres -c '/opt/local/lib/postgresql84/bin/createuser -s mms'
# sudo su postgres -c '/opt/local/lib/postgresql84/bin/createuser -s jperkins'
#
# /opt/local/lib/postgresql84/bin/createdb mms_development
# /opt/local/lib/postgresql84/bin/createdb mms_test


# ---------------------------------------------------------------------------
# install gems
# ---------------------------------------------------------------------------

sudo gem update --system
sudo gem sources -a http://gems.github.com
sudo gem update outdated








