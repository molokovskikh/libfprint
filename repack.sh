#!/bin/bash


cur_dir=$(pwd)
deb_orig=$(realpath $1)
deb_orig_dir=${cur_dir}/deb_orig

echo $(basename $(pwd)) | grep -q libfprint-CS9711 || 
{ git clone git@github.com:archeYR/libfprint-CS9711.git; cd libfprint-CS9711; }


#Before need run:
sudo apt install ninja-build meson libgusb-dev libgirepository1.0-dev libopencv-dev gtk-doc-tools -y
rm -rf _build
meson _build
meson compile -C _build



rm -rf ${deb_orig_dir}

echo dpkg-deb -R ${deb_orig} ${deb_orig_dir} 
dpkg-deb -R ${deb_orig} ${deb_orig_dir} 

cp _build/libfprint/70-libfprint-2.rules ${deb_orig_dir}/lib/udev/rules.d/70-libfprint-2.rules
cp data/autosuspend.hwdb ${deb_orig_dir}/lib/udev/hwdb.d/60-autosuspend-libfprint-2.hwdb
cp _build/libfprint/libfprint-2.so.2.0.0 ${deb_orig_dir}/usr/lib/x86_64-linux-gnu/libfprint-2.so.2.0.0

cat<<EOF>${deb_orig_dir}/DEBIAN/postinst
#!/bin/sh

set -e



if [ "$1" = "configure" -o "$1" = "upgrade" ] && command -V udevadm >/dev/null 2>&1; then
	# apply hwdb rules at package installation, see
	# <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=683863#27>
	# NOTA BENE: after the DEBHELPER section since dh_installudev
	# adds stuff there
	# The devices ID list is auto-generated using the gbp postimport hook
	# see debian/README.sources for more details.
EOF

cat data/autosuspend.hwdb| grep '^usb:'| sed -E 's/^usb:v([^p]+)p([^\*]+)\*$/   udevadm trigger --action=add --attr-match=idVendor=\1 --attr-match=idProduct=\2 || true/' >> ${deb_orig_dir}/DEBIAN/postinst

cat<<EOF>>${deb_orig_dir}/DEBIAN/postinst
fi

exit 0
EOF

chmod +x ${deb_orig_dir}/DEBIAN/postinst

cd ${deb_orig_dir}
find lib usr -type f|xargs md5sum > DEBIAN/md5sums

cd ${cur_dir}

rm new_$(basename ${deb_orig})

dpkg-deb -b ${deb_orig_dir} new_$(basename ${deb_orig})

rm -rf ${deb_orig_dir} libfprint-CS9711
