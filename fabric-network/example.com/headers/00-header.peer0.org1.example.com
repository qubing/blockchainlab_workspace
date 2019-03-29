#!/bin/sh

[ -r /etc/lsb-release ] && . /etc/lsb-release

if [ -z "$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
        # Fall back to using the very slow lsb_release utility
        DISTRIB_DESCRIPTION=$(lsb_release -s -d)
fi

printf "Welcome to %s (%s %s %s)\n" "$DISTRIB_DESCRIPTION" "$(uname -o)" "$(uname -r)" "$(uname -m)"

printf "\n"
printf "================== FABRIC-PEER ==================\n"
printf "=                                               =\n"
printf "=            (peer0.org1.example.com)           =\n"
printf "=                                               =\n"
printf "=================================================\n"
printf "\n"
