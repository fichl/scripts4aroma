#!/sbin/sh
# hexedit script by fichl

# Allow ui_print from sh
ui_print() {
  if [ $RECOVERY_BINARY != "" ]; then
    echo "ui_print ${1} " 1>&$RECOVERY_BINARY;
    echo "ui_print " 1>&$RECOVERY_BINARY;
  else
    echo "${1}";
  fi;
}
CWM_RUN=$(ps | grep -v "grep" | grep -o -E "update_binary(.*)" | cut -d " " -f 3);
TWRP_RUN=$(ps | grep -v "grep" | grep -o -E "updater(.*)" | cut -d " " -f 3);
if [ "$CWM_RUN" ]; then
	RECOVERY_BINARY=$CWM_RUN
else
if [ "$TWRP_RUN" ]; then
	RECOVERY_BINARY=$TWRP_RUN
fi
fi

#HEXEDIT
ui_print "   patching colors in resourses.arsc"
#read from txt file
file=/sdcard/vrtheme/colors.txt
IFS="|"
while read value comment path typ offset
do
  case "$color" in \#*) continue ;; esac
  if [ $typ = "color" ]; then
  #reverse hex color values and write them to the given offset
    s1=`echo "$value" | cut -b7-8`  
  	s2=`echo "$value" | cut -b5-6`  
  	s3=`echo "$value" | cut -b3-4`  
  	s4=`echo "$value" | cut -b1-2`  
    printf '\x'$s1'\x'$s2'\x'$s3'\x'$s4 | dd of=$path bs=1 seek=$offset count=4 conv=notrunc
    ui_print "   - "$s1$s2$s3$s4" written to offset: "$offset
  fi
  
  if [ $typ = "int" ]; then   
  #convert integers to hex and write them to the given offset
    z="$(printf %04x ${value// /})"
    s1=`echo "$z" | cut -b3-4` 
    s2=`echo "$z" | cut -b1-2`
    printf '\x'$s1'\x'$s2 | dd of=$path bs=1 seek=$offset count=2 conv=notrunc
    ui_print "   - "$s1$s2" written to offset: "$offset
  fi
done <"$file"
