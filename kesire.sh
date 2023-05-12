#!/bin/sh

VERSION="1.2"

#  kesire.sh
#
# A very simple helper tool that leverages openssl to generate
# a private key and a X.509 certificate signing request, giving you
# the ability of specifying a list of possible alternative names
#
#  Copyright 2023 Filippo Lauria <filippo.lauria@iit.cnr.it>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

echo "
+-------------------------------+
|                               |
|         kesire.sh v${VERSION}        |
| [ke]y and [si]gning [re]quest |
|                               |
+-------------------------------+

run kesire.sh in an empty directory and it will generate the following files:
 - a private key file (extension .key)
 - a certificate signing request file (extension .csr)
 - (optionally) an encrypted version of the private key file (extension .enc.key).

\033[1mBy proceeding, you accept the terms and conditions of use of this script\033[0m
(more on them executing the command 'head -n25 kesire.sh').
"

#
# ~ fill in any of these variables to skip the related prompt
#

# fill this with yes to skip the disclaimer prompt
ACCEPT_DISCLAIMER=""

# fill in these variables according to what specified in here:
# https://en.wikipedia.org/wiki/Certificate_signing_request
COUNTRY_CODE=""
STATE_OR_PROVINCE=""
LOCALITY=""
ORGANIZATION=""
ORGANIZATIONAL_UNIT=""

# requester email (i.e. your email)
EMAIL=""

#  the chosen common name
CN=""

# use yes if you want to use subject alternative names
USE_ALT_NAMES="yes"

# a space-separated list of fully qualified alternative domain names
# this will be taken into account only if USE_ALT_NAMES equals yes
ALT_NAMES=""

# if you do not want an encrypted version of the key, you must choose no
# if you choose yes instead, you will be asked for a passphrase
ENCRYPT_KEY=""

# change this if you want to change the output private key length
KEYLEN=4096



# the tool provide user with some default choices (variables starting with DEFAULT_)
# or at least some hint (variables starting with EXAMPLE_)
DEFAULT_COUNTRY_CODE="IT"
DEFAULT_STATE_OR_PROVINCE="Lazio"
DEFAULT_LOCALITY="Roma"

EXAMPLE_ORGANIZATION="My Organization"
EXAMPLE_ORGANIZATIONAL_UNIT="ICT Unit, Legal Unit"
EXAMPLE_EMAIL="firstname.lastname@example.xyz"

# common name, i.e. the main domain name for which the certificate will be issued
# e.g. example.com, etc.
EXAMPLE_CN="example.xyz"

# a space-separated list of alternative fully qualified domain names (optional)
# e.g. fqdn1.example.com fqdn2.example.com fqdn3.example.com
EXAMPLE_ALT_NAMES="fqdn1.example.xyz, fqdn2.example.xyz, fqdn3.example.xyz"

#
# ~ the script
#

# ~ before proceding, we check if openssl is present
if [ ! -x "$(command -v openssl)" ]; then
    echo "Error: OpenSSL is not installed or not accessible in the current path."
    echo "Please install it and try again."
    exit 1
fi

while [ "$ACCEPT_DISCLAIMER" != "yes" ]; do
    printf "Are you ok with that? "
    read -r ACCEPT_DISCLAIMER

    case $ACCEPT_DISCLAIMER in
        "yes") echo "Very good!"; ACCEPT_DISCLAIMER="yes" ;;
        "no") echo "Bye."; exit ;;
        *) echo "You have to answer yes or no"; ACCEPT_DISCLAIMER="" ;;
    esac
done
echo;

if [ "$COUNTRY_CODE" = "" ]; then
    printf "Insert your country code [%s]: " "${DEFAULT_COUNTRY_CODE}"
    read -r COUNTRY_CODE

    if ! echo "$COUNTRY_CODE" | grep -q "^[A-Z]\{2\}$"; then
        echo "Empty or invalid country code (using default: $DEFAULT_COUNTRY_CODE)."
        COUNTRY_CODE=$DEFAULT_COUNTRY_CODE
    fi
fi

if [ "$STATE_OR_PROVINCE" = "" ]; then
    printf "Insert your state or province [%s]: " "${DEFAULT_STATE_OR_PROVINCE}"
    read -r STATE_OR_PROVINCE

    if ! echo "$STATE_OR_PROVINCE" | grep -q "^[A-Z][a-z]\+$"; then
        echo "Empty or invalid state or province (using default: $DEFAULT_STATE_OR_PROVINCE)."
        STATE_OR_PROVINCE=$DEFAULT_STATE_OR_PROVINCE
    fi
fi

if [ "$LOCALITY" = "" ]; then
    printf "Insert your state or province [%s]: " "${DEFAULT_LOCALITY}"
    read -r LOCALITY

    if ! echo "$LOCALITY" | grep -q "^[A-Z][a-z]\+$"; then
        echo "Empty or invalid locality (using default: $DEFAULT_LOCALITY)."
        LOCALITY=$DEFAULT_LOCALITY
    fi
fi


while ! echo "$ORGANIZATION" | grep -q "^[0-9A-Za-z' ]\+$"; do
    printf "Insert your organization (e.g. %s, etc.): " "${EXAMPLE_ORGANIZATION}"
    read -r ORGANIZATION
done


while ! echo "$ORGANIZATIONAL_UNIT" | grep -q "^[0-9A-Za-z' ]\+$"; do
    printf "Insert your organizational unit (e.g. %s, etc.): " "${EXAMPLE_ORGANIZATIONAL_UNIT}"
    read -r ORGANIZATIONAL_UNIT
done

while ! echo "$EMAIL" | grep -q "^[a-zA-Z0-9\._%+-]\+\@[a-zA-Z0-9\.-]\+\.[a-zA-Z]\{2,4\}$"; do
    printf "Insert your email (e.g. %s, etc.): " "${EXAMPLE_EMAIL}"
    read -r EMAIL
done

while ! echo "$CN" | grep -q '^[a-zA-Z0-9]\{1,\}\([a-zA-Z0-9\-]\{0,61\}[a-zA-Z0-9]\)\{0,1\}\(\.[a-zA-Z]\{2,\}\)\{1,\}$'; do
    printf "Insert the common name, i.e. the main domain name for which the certificate will be issued (e.g. %s, etc.): " "${EXAMPLE_CN}"
    read -r CN
done


if [ "$ALT_NAMES" = "" ] && [ "$USE_ALT_NAMES" = "yes" ]; then
    while true; do
        printf "Insert an optional domain name for which the certificate will be issued (e.g. %s, etc.): " "${EXAMPLE_ALT_NAMES}"
        read -r ALT_NAME

        if [ "$ALT_NAME" = "" ]; then
            break;
        fi

        if echo "$ALT_NAME" | grep -q '^[a-zA-Z0-9]\{1,\}\([a-zA-Z0-9\-]\{0,61\}[a-zA-Z0-9]\)\{0,1\}\(\.[a-zA-Z]\{2,\}\)\{1,\}$'; then
            if ( ! echo "${ALT_NAMES}" | grep -q "${ALT_NAME}" ) && ( ! echo "${CN}" | grep -q "${ALT_NAME}" ); then
                ALT_NAMES="${ALT_NAMES} ${ALT_NAME}"
            fi
        fi
    done
fi

# this is the prefix name of the ouput files
FILE_PREFIX=$CN

if [ -z "${COUNTRY_CODE}" ] || [ -z "${STATE_OR_PROVINCE}" ] || [ -z "${LOCALITY}" ] || [ -z "${ORGANIZATION}" ] &&
   [ -z "${ORGANIZATIONAL_UNIT}" ] || [ -z "${EMAIL}" ] || [ -z "${CN}" ] || [ -z "${FILE_PREFIX}" ]; then
    echo "Error: Missing mandatory option(s)."
    exit 1
fi

REQ_FILENAME="$(mktemp -qu).conf"

cat << EOF > "${REQ_FILENAME}"
[req]
  distinguished_name = req_distinguished_name
  req_extensions     = v3_req
  prompt             = no

[req_distinguished_name]
  C                  = ${COUNTRY_CODE}
  ST                 = ${STATE_OR_PROVINCE}
  L                  = ${LOCALITY}
  O                  = ${ORGANIZATION}
  OU                 = ${ORGANIZATIONAL_UNIT}
  CN                 = ${CN}
  emailAddress       = ${EMAIL}

[v3_req]
  keyUsage           = keyEncipherment, dataEncipherment
  extendedKeyUsage   = serverAuth
EOF

if [ "$ALT_NAMES" ]; then
    cat << EOF >> "${REQ_FILENAME}"
  subjectAltName     = @alt_names

[alt_names]
EOF

    INDEX=1
    for ALT_NAME in ${ALT_NAMES}; do
        echo "  DNS.${INDEX}              = ${ALT_NAME}" >> "${REQ_FILENAME}"
        INDEX=$((INDEX+1))
    done
fi

DEFAULT_KEYLEN=4096
MIN_KEYLEN=2048
if [ "$KEYLEN" -lt "$MIN_KEYLEN" ]; then
    echo "Key length is invalid (using default: $DEFAULT_KEYLEN)."
    KEYLEN=$DEFAULT_KEYLEN
fi

openssl req -new -out "${FILE_PREFIX}.csr" -newkey rsa:${KEYLEN} -nodes -sha512 -keyout "${FILE_PREFIX}.key" -config "${REQ_FILENAME}"


while [ "$ENCRYPT_KEY" != "no" ]; do
    printf "Do you want an encrypted version of the key? "
    read -r ENCRYPT_KEY

    case $ENCRYPT_KEY in
        "yes") while ! openssl rsa -aes256 -in "${FILE_PREFIX}.key" -out "${FILE_PREFIX}.enc.key"; do :; done; break ;;
        "no") break ;;
        *) echo "You have to answer yes or no"; ENCRYPT_KEY="" ;;
    esac
done
echo;


openssl req -text -noout -verify -in "${FILE_PREFIX}.csr"

rm -f "${REQ_FILENAME}"

echo; echo "Output files:"; echo
ls -l "${FILE_PREFIX}"*

exit 0
