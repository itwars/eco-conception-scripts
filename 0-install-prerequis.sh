#!/usr/bin/env sh

apk update
apk upgrade
apk add imagemagick libwebp-tools libavif-apps vim mc python3 git wget bash coreutils mailcap jpegoptim curl npm
npm i -g svgo
cat << EOF > /root/.ashrc
alias ll='ls -al'
alias web='python3 -m http.server 80'
export PATH="/root/:$PATH"
EOF
cat << EOF > /root/.profile
source /root/.ashrc
EOF
