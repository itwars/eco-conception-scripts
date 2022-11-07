#!/usr/bin/env sh

apk update
apk upgrade
apk add imagemagick libwebp-tools libavif-apps vim mc python3 git
cat << EOF > /root/.profile
alias ll='ls -al'
alias web='python3 -m http.server 80'
EOF
