#!/system/bin/sh
# 不依赖 meta-overlayfs: 把 overlay 复制到 tmpfs, 再用 overlayfs 叠到 /system/product/overlay 上.
# overlayfs 不接受 /data(f2fs) 做 lowerdir, 所以先复制. 重启即失效, 卸载模块不用清理.
MODDIR=${0%/*}
LOG=$MODDIR/mount.log
S=/dev/tb321fu_brightness
DIR=/system/product/overlay
APK=treble-overlay-lenovo-tb321fu.apk
echo "== $(date)" > $LOG

if [ -f $DIR/$APK ]; then
    echo "skip: $DIR/$APK already present (ROM or another module provides it)" >> $LOG
    exit 0
fi
mkdir -p $S
mount -t tmpfs -o mode=755 tmpfs $S >> $LOG 2>&1
cp $MODDIR/files/$APK $S/
chmod 0644 $S/$APK
chcon -R u:object_r:system_file:s0 $S 2>> $LOG
mount -t overlay overlay -o lowerdir=$S:$DIR $DIR >> $LOG 2>&1 \
    && echo "ok overlay $DIR" >> $LOG || echo "FAIL overlay $DIR" >> $LOG
ls -lZ $DIR/$APK >> $LOG 2>&1
