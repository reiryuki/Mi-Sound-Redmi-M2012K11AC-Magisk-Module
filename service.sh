MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`
AML=/data/adb/modules/aml

# debug
exec 2>$MODPATH/debug.log
set -x

# property
#resetprop ro.audio.soundfx.dirac true
resetprop ro.vendor.audio.hifi false
resetprop ro.vendor.audio.ring.filter true
resetprop ro.vendor.audio.scenario.support  true
#resetprop ro.vendor.audio.sfx.audiovisual false
resetprop ro.vendor.audio.sfx.earadj true
resetprop ro.vendor.audio.sfx.independentequalizer true
resetprop ro.vendor.audio.sfx.scenario true
resetprop ro.vendor.audio.sfx.spk.stereo true
resetprop ro.vendor.audio.soundfx.type mi
resetprop ro.vendor.audio.soundfx.usb true
#dresetprop ro.vendor.dolby.dax.version DAX3_3.6.1.6_r1
#dresetprop vendor.audio.dolby.ds2.enabled false
#dresetprop vendor.audio.dolby.ds2.hardbypass false
#dresetprop ro.vendor.audio.dolby.dax.support true
#d#11resetprop ro.vendor.product.device.db OP_DEVICE
#d#11resetprop ro.vendor.product.manufacturer.db OP_PHONE
#d#10resetprop vendor.product.device OP_PHONE
#d#10resetprop vendor.product.manufacturer OPD
#d#resetprop vendor.dolby.dap.param.tee false
#d#resetprop vendor.dolby.mi.metadata.log false
#d#resetprop vendor.audio.gef.enable.traces false
#d#resetprop vendor.audio.gef.debug.flags false

# notes
#ro.audio.hifi
#ro.audio.soundfx.type
#ro.audio.soundfx.usb
#ro.board.platform
#ro.boot.hwversion
#ro.build.description
#ro.build.freeme.label
#ro.build.product
#ro.build.version.sdk
#ro.carrier.name
#ro.miui.cust_variant
#ro.miui.notch
#ro.miui.region
#ro.miui.restrict_imei
#ro.miui.ui.version.code
#ro.miui.xms.version
#ro.product.locale.region
#ro.product.manufacturer
#ro.product.mod_device
#ro.product.model
#ro.product.model.real
#ro.product.name
#ro.ssui.product
#ro.vendor.audio.sfx.harmankardon
#ro.vendor.audio.sfx.speaker
#ro.vendor.audio.sfx.spk.movie
#ro.vendor.audio.surround.headphone.only
#ro.vendor.audio.scenario.headphone.only
#ro.vendor.audio.feature.spatial
#ro.vendor.audio.misound.bluetooth.enable
#ro.vendor.audio.dolby.fade_switch

# wait
sleep 20

# aml fix
DIR=$AML/system/vendor/odm/etc
if [ -d $DIR ] && [ ! -f $AML/disable ]; then
  chcon -R u:object_r:vendor_configs_file:s0 $DIR
fi

# mount
NAME="*audio*effects*.conf -o -name *audio*effects*.xml"
#pNAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
if [ ! -d $AML ] || [ -f $AML/disable ]; then
  DIR=$MODPATH/system/vendor
else
  DIR=$AML/system/vendor
fi
FILE=`find $DIR/etc -maxdepth 1 -type f -name $NAME`
if [ `realpath /odm/etc` == /odm/etc ] && [ "$FILE" ]; then
  for i in $FILE; do
    j="/odm$(echo $i | sed "s|$DIR||")"
    if [ -f $j ]; then
      umount $j
      mount -o bind $i $j
    fi
  done
fi
if [ -d /my_product/etc ] && [ "$FILE" ]; then
  for i in $FILE; do
    j="/my_product$(echo $i | sed "s|$DIR||")"
    if [ -f $j ]; then
      umount $j
      mount -o bind $i $j
    fi
  done
fi

# restart
killall audioserver

# function
stop_service() {
for NAMES in $NAME; do
  if getprop | grep "init.svc.$NAMES\]: \[running"; then
    stop $NAMES
  fi
done
}
run_service() {
for FILES in $FILE; do
  killall $FILES
  $FILES &
  PID=`pidof $FILES`
done
}

# stop
#dNAME="dms-hal-1-0 dms-hal-2-0 dms-v36-hal-2-0"
#dstop_service

# run
#dFILE=`realpath /vendor`/bin/hw/vendor.dolby.hardware.dms@2.0-service
#drun_service

# restart
#dkillall com.dolby.daxservice
#dVIBRATOR=`realpath /*/bin/hw/vendor.qti.hardware.vibrator.service*`
#d[ "$VIBRATOR" ] && killall $VIBRATOR
#dPOWER=`realpath /*/bin/hw/vendor.mediatek.hardware.mtkpower@*-service`
#d[ "$POWER" ] && killall $POWER
#dkillall android.hardware.usb@1.0-service
#dkillall android.hardware.sensors@2.0-service-mediatek
#dkillall [chre_kthread] [scp_power_reset]
#dkillall [charger_in] [charger_thread] [tcpc_power_off]
#dkillall android.hardware.light-service.mt6768
#dCAMERA=`realpath /*/bin/hw/android.hardware.camera.provider@*-service_64`
#d[ "$CAMERA" ] && killall $CAMERA

# wait
sleep 40

# socket
#FILE=/dev/socket/audio_hw_socket
#if [ ! -e $FILE ]; then
#  rm -f /data/media/0/has_audio_hw_socket
#  touch /data/media/0/no_audio_hw_socket
#else
#  rm -f /data/media/0/no_audio_hw_socket
#  touch /data/media/0/has_audio_hw_socket
#fi
#chmod 0666 $FILE
#chown 1000.1000 $FILE
#chcon u:object_r:audio_socket:s0 $FILE

# grant
PKG=com.miui.misound
pm grant $PKG android.permission.READ_PHONE_STATE
pm grant $PKG android.permission.RECORD_AUDIO
appops set $PKG SYSTEM_ALERT_WINDOW allow
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

# grant
PKG=com.dolby.daxservice
if pm list packages | grep $PKG ; then
  pm grant $PKG android.permission.READ_EXTERNAL_STORAGE
  pm grant $PKG android.permission.WRITE_EXTERNAL_STORAGE
  if [ "$API" -ge 30 ]; then
    appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
  fi
fi





