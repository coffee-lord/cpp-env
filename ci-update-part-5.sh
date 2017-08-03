#!/bin/bash -ue

echo 'EXECUTING PART 5'

cd ~
python3 -m pip install --user --upgrade conan pip
apt-get -y clean

IFS=$'\n'
for f in $(find /usr \( -name 'crtend*' -o -name 'crtbegin*' \)); do
	mv "$f" "$f~"
done

apt-get -y purge --auto-remove build-essential binutils libxml2-dev libedit-dev
# Move to part 1
apt-get install -y --no-install-recommends libedit2

IFS=$'\n'
for f in $(find /usr \( -name 'crtend*' -o -name 'crtbegin*' \)); do
	mv "$f" "${f%\~}"
done

rm -rf /var/lib/apt
rm -rf /var/cache/apt
