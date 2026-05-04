curl -o libfprint-2-2.deb  https://archive.ubuntu.com/ubuntu/pool/main/libf/libfprint/libfprint-2-2_1.94.3+tod1-0ubuntu1_amd64.deb

or

curl -o libfprint-2-2.deb  https://archive.ubuntu.com/ubuntu/pool/main/libf/libfprint/libfprint-2-2_1.94.7+tod1-0ubuntu5~24.04.6_amd64.deb

./repack.sh libfprint-2-2.deb

sudo dpkg -i new_libfprint-2-2.deb
