#!/bin/bash -xue

apt-get -y clean

IFS=$'\n'
for f in $(find /usr \( -name 'crtend*' -o -name 'crtbegin*' \)); do
	mv "$f" "$f~"
done

apt-get -y purge --auto-remove build-essential binutils libxml2-dev libedit-dev linux-headers-amd64 || true

IFS=$'\n'
for f in $(find /usr \( -name 'crtend*' -o -name 'crtbegin*' \)); do
	mv "$f" "${f%\~}"
done

rm -rf /var/lib/apt
rm -rf /var/cache/apt