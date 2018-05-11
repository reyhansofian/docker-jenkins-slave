#!/usr/bin/env bash

#source /root/.profile
source /opt/nvm/nvm.sh;

echo "Installed"
echo ""
# echo "> java versions"
# java -version 2>&1
# mvn -version

echo ""
echo "> node versions"
echo "node $(node -v)"
echo "npm $(npm -v)"

echo ""
echo "> browser versions"
firefox -v 2> /dev/null
chromium-browser -version 2> /dev/null
google-chrome -version
echo ""