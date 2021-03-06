##########################################################################################
#
# Magisk Module Template Config Script
# by topjohnwu
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure the settings in this file (config.sh)
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Configs
##########################################################################################

# Set to true if you need to enable Magic Mount
# Most mods would like it to be enabled
AUTOMOUNT=true

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Installation Message
##########################################################################################

# Set what you want to show when installing your mod

print_modname() {
  MODVERSION=$(echo $(get_file_value $INSTALLER/module.prop "version=") | sed 's|-.*||')
  ui_print "*******************************"
  ui_print "MagiskHide Props Config $MODVERSION"
  ui_print "    By Didgeridoohan @XDA"
  ui_print "*******************************"
}

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info about how Magic Mount works, and why you need this

# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will override the example above
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
  # Only some special files require specific permissions
  # The default permissions should be good enough for most cases

  # Here are some examples for the set_perm functions:

  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm_recursive  $MODPATH/system/lib       0       0       0755            0644

  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm  $MODPATH/system/bin/app_process32   0       2000    0755         u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0       2000    0755         u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0       0       0644

  # The following is default permissions, DO NOT remove
  set_perm_recursive  $MODPATH  0  0  0755  0644
  
  # Permissions for the props file
  set_perm $MODPATH/system/$BIN/props 0 0 0777
  # Permissions for boot scripts
  set_perm $LATEFILE 0 0 0755
  set_perm $POSTFILE 0 0 0755
}

##########################################################################################
# Custom Functions
##########################################################################################

# This file (config.sh) will be sourced by the main flash script after util_functions.sh
# If you need custom logic, please add them here as functions, and call these functions in
# update-binary. Refrain from adding code directly into update-binary, as it will make it
# difficult for you to migrate your modules to newer template versions.
# Make update-binary as clean as possible, try to only do function calls in it.


##########################################################################################
# Installation variables and functions for the Magisk module "MagiskHide Props Config"
# by Didgeridoohan @ XDA Developers.
##########################################################################################

# Finding file values
get_file_value() {
	cat $1 | grep $2 | sed "s|.*$2||" | sed 's|\"||g'
}
# Get left side of =
get_eq_left() {
	echo $1 | sed 's|=.*||'
}
# Get first word in string
get_first() {
	case $1 in
		*\ *) echo $1 | sed 's|\ .*||'
		;;
		*=*) get_eq_left "$1"
		;;
	esac
}

# Variables
if [ "$MAGISK_VER_CODE" -ge 17316 ]; then
	COREPATH=/sbin/.magisk
else
	COREPATH=/sbin/.core
fi
ADBPATH=/data/adb
BIMGPATH=$COREPATH/img
$BOOTMODE && IMGPATH=$BIMGPATH || IMGPATH=$MOUNTPATH
if [ "$MAGISK_VER_CODE" -ge 17316 ]; then
	POSTPATH=$ADBPATH/post-fs-data.d
	SERVICEPATH=$ADBPATH/service.d
	POSTHOLDER=$ADBPATH/post-fs-data.d/propsconf_post
	LATEHOLDER=$ADBPATH/service.d/propsconf_late
else
	POSTPATH=$IMGPATH/.core/post-fs-data.d
	SERVICEPATH=$IMGPATH/.core/service.d
	POSTHOLDER=$BIMGPATH/.core/post-fs-data.d/propsconf_post
	LATEHOLDER=$BIMGPATH/.core/service.d/propsconf_late
fi
POSTFILE=$POSTPATH/propsconf_post
UPDATEPOSTFILE=$INSTALLER/common/propsconf_post
LATEFILE=$SERVICEPATH/propsconf_late
POSTLATEFILE=$POSTPATH/propsconf_late
UPDATELATEFILE=$INSTALLER/common/propsconf_late
if [ -z $SLOT ]; then
	SYSTEMLOC=/system
	CACHELOC=/cache
else
	SYSTEMLOC=/system_root/system
	CACHELOC=/data/cache
fi
INSTLOG=$CACHELOC/propsconf_install.log
UPDATEV=$(get_file_value $UPDATELATEFILE "SCRIPTV=")
UPDATETRANSF=$(get_file_value $UPDATELATEFILE "SETTRANSF=")
NOTTRANSF=$(get_file_value $UPDATELATEFILE "NOTTRANSF=")
SETTINGSLIST="
FINGERPRINTENB
PRINTEDIT
BUILDPROPENB
FILESAFE
BUILDEDIT
DEFAULTEDIT
PROPCOUNT
PROPEDIT
CUSTOMEDIT
DELEDIT
REBOOTCHK
OPTIONLATE
OPTIONCOLOUR
OPTIONWEB
"
PROPSETTINGSLIST="
MODULEDEBUGGABLE
MODULESECURE
MODULETYPE
MODULETAGS
MODULESELINUX
MODULEFINGERPRINT
CUSTOMPROPS
CUSTOMPROPSPOST
CUSTOMPROPSLATE
DELETEPROPS
"
PROPSLIST="
debuggable
secure
type
tags
selinux
fingerprint
"
USNFLIST="xiaomi-safetynet-fix safetynet-fingerprint-fix VendingVisa DeviceSpoofingTool4Magisk universal-safetynet-fix samodx-safetyskipper safetypatcher petnoires-safetyspoofer"

# Log functions
log_handler() {
	echo "" >> $INSTLOG
	echo -e "$(date +"%m-%d-%Y %H:%M:%S") - $1" >> $INSTLOG 2>&1
}
log_start() {
	if [ -f "$INSTLOG" ]; then
		rm -f $INSTLOG
	fi
	touch $INSTLOG
	echo "***************************************************" >> $INSTLOG 2>&1
	echo "******** MagiskHide Props Config $MODVERSION ********" >> $INSTLOG 2>&1
	echo "**************** By Didgeridoohan ***************" >> $INSTLOG 2>&1
	echo "***************************************************" >> $INSTLOG 2>&1
	log_handler "Starting module installation script"
}
log_print() {
	ui_print "$1"
	log_handler "$1"
}

# Places various module scripts in their proper places
script_placement() {
	if [ -f "$LATEFILE" ]; then
		FILEV=$(get_file_value $LATEFILE "SCRIPTV=")
		FILETRANSF=$(get_file_value $LATEFILE "SETTRANSF=")
	else
		FILEV=0
		FILETRANSF=$UPDATETRANSF
	fi
	log_print "- Installing scripts"
	cp -af $INSTALLER/common/util_functions.sh $MODPATH/util_functions.sh >> $INSTLOG 2>&1
	cp -af $INSTALLER/common/prints.sh $MODPATH/prints.sh >> $INSTLOG 2>&1
	cp -af $UPDATEPOSTFILE $MODPATH/propsconf_post >> $INSTLOG 2>&1
	cp -af $UPDATEPOSTFILE $POSTFILE >> $INSTLOG 2>&1
	cp -af $UPDATELATEFILE $MODPATH/propsconf_late >> $INSTLOG 2>&1
	if [ "$FILEV" ]; then
		# New script
		if [ "$UPDATEV" -gt "$FILEV" ]; then
			# Fresh install
			if [ "$FILEV" == 0 ]; then
				log_print "- Placing settings script"
			# Updated script with a required clearing of settings
			elif [ "$UPDATETRANSF" -gt "$FILETRANSF" ] && [ -z "$NOTTRANSF" ]; then
				log_print "- Settings cleared (script updated)"
			# Updated script
			else
				log_print "- Script updated"
				log_print "- Transferring settings from old script"
				# Prop settings
				for ITEM in $SETTINGSLIST; do
					# Checking if a script update requires some options not to transfer
					case "$NOTTRANSF" in
						*${ITEM}*)						
							if [ "$UPDATETRANSF" -gt "$FILETRANSF" ]; then
								TRANSFOPT=1
							else
								TRANSFOPT=0
							fi
						;;
						*)
							TRANSFOPT=0
						;;
					esac
					if [ "$TRANSFOPT" == 1 ]; then
						log_handler "Not transfering settings for ${ITEM}."
					else
						SOLD=$(get_file_value $LATEFILE "${ITEM}=")
						SNEW=$(get_file_value $UPDATELATEFILE "${ITEM}=")
						if [ "$SOLD" ] && [ "$SOLD" != "$SNEW" ]; then
							log_handler "Setting ${ITEM} from ${SNEW} to ${SOLD}."
							sed -i "s|${ITEM}=${SNEW}|${ITEM}=${SOLD}|" $UPDATELATEFILE
						fi
					fi
				done
				# Prop values
				for ITEM in $PROPSETTINGSLIST; do
					SOLD=$(get_file_value $LATEFILE "${ITEM}=")
					if [ "$SOLD" ]; then
						log_handler "Setting ${ITEM} to ${SOLD}."
						sed -i "s|${ITEM}=\"\"|${ITEM}=\"${SOLD}\"|" $UPDATELATEFILE
					fi
				done
				# Prop and file edits
				for ITEM in $PROPSLIST; do
					REPROP=$(echo "RE${ITEM}" | tr '[:lower:]' '[:upper:]')
					SETPROP=$(echo "SET${ITEM}" | tr '[:lower:]' '[:upper:]')
					REOLD=$(get_file_value $LATEFILE "${REPROP}=")
					SETOLD=$(get_file_value $LATEFILE "${SETPROP}=")
					if [ "$REOLD" ] && [ "$REOLD" != "false" ]; then
						log_handler "Setting sensitive prop ${ITEM} to ${REOLD}."
						sed -i "s/${REPROP}=false/${REPROP}=${REOLD}/" $UPDATELATEFILE
					fi
					if [ "$SETOLD" ] && [ "$SETOLD" != "false" ]; then
						log_handler "Setting file edit ${ITEM} to ${SETOLD}."
						sed -i "s/${SETPROP}=false/${SETPROP}=${SETOLD}/" $UPDATELATEFILE
					fi
				done
			fi
			log_handler "Setting up late_start settings script."
			cp -af $UPDATELATEFILE $LATEFILE >> $INSTLOG 2>&1
		# Downgraded script (flashed old module version)
		elif [ "$UPDATEV" -lt "$FILEV" ]; then
			log_print "- Settings cleared (script downgraded)"
			cp -af $UPDATELATEFILE $LATEFILE >> $INSTLOG 2>&1
		# No update of script
		else
			log_print "- Module settings preserved"
		fi
	else
		log_print "- Placing settings script"
		log_handler "Setting up late_start settings script."
		cp -af $UPDATELATEFILE $LATEFILE >> $INSTLOG 2>&1
	fi
}

# Create fingerprint files
print_files() {
	log_print "- Creating fingerprint files."
	rm -rf $MODPATH/printfiles >> $INSTLOG 2>&1
	mkdir -pv $MODPATH/printfiles >> $INSTLOG 2>&1
	# Loading prints
	. $MODPATH/prints.sh
	# Saving manufacturers
	log_handler "Saving manufacturers"
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	for ITEM in $PRINTSLIST; do
		TMPOEMLIST=$(echo "$OEMLIST $(get_first $ITEM)" | sed 's|^[ \t]*||')
		OEMLIST="$TMPOEMLIST"
	done
	IFS=$SAVEIFS
	TMPOEMLIST=$(echo $(printf '%s\n' $OEMLIST | sort -u))
	OEMLIST="$TMPOEMLIST"
	log_handler "Creating files"
	for OEM in $OEMLIST; do
		echo -e "PRINTSLIST=\"" >> $MODPATH/printfiles/${OEM}\.sh
		cat $MODPATH/prints.sh | grep $OEM >> $MODPATH/printfiles/${OEM}\.sh
		echo -e "\"" >> $MODPATH/printfiles/${OEM}\.sh
	done
}

# Updates placeholders
placeholder_update() {
	FILEVALUE=$(get_file_value $1 "$2=")
	log_handler "Checking for ${3} in ${1}. Current value is ${FILEVALUE}."
	case $FILEVALUE in
		*PLACEHOLDER*)	sed -i "s|${2}=${3}|${2}=\"${4}\"|g" $1
						log_handler "Placeholder ${3} updated to ${4} in ${1}."
		;;
	esac
}

# Checks if any other module is using a local copy of build.prop
build_prop_check() {
	log_print "- Checking for build.prop conflicts"
	for D in $(ls $IMGPATH); do
		if [ "$D" != "$MODID" ]; then
			if [ -f "$IMGPATH/$D/system/build.prop" ]; then
				NAME=$(get_file_value $IMGPATH/$D/module.prop "name=")
				ui_print "!"
				log_print "! Another module editing build.prop detected!"
				log_print "! Module - '$NAME'!"
				log_print "! Modification of build.prop disabled!"
				ui_print "!"
				sed -i 's/BUILDPROPENB=1/BUILDPROPENB=0/' $UPDATELATEFILE
			fi
		fi
	done
}

# Checks for the Universal SafetyNet Fix module and similar modules editing device fingerprint
usnf_check() {
	log_print "- Checking for fingerprint conflicts"
	for USNF in $USNFLIST; do
		if [ -d "$IMGPATH/$USNF" ]; then
			NAME=$(get_file_value $IMGPATH/$USNF/module.prop "name=")
			ui_print "!"
			log_print "! Module editing fingerprint detected!"
			log_print "! Module - '$NAME'!"
			log_print "! Fingerprint modification disabled!"
			ui_print "!"
			sed -i 's/FINGERPRINTENB=1/FINGERPRINTENB=0/' $UPDATELATEFILE
		fi
	done
}

# Check for bin/xbin
bin_check() {
	$BOOTMODE && BINCHECK=$COREPATH/mirror/system/xbin || BINCHECK=/system/xbin
	if [ -d "$BINCHECK" ]; then
		BIN=xbin
	else
		BIN=bin
	fi
	log_handler "Using /system/$BIN."
	mv -f $MODPATH/system/binpath $MODPATH/system/$BIN >> $INSTLOG 2>&1
}

# Magisk installation check
install_check() {
	if [ ! -d "$SERVICEPATH" ] || [ ! -d "$POSTPATH" ]; then
		log_print "- Fresh Magisk installation detected."
		log_handler "Creating path for boot script."
		mkdir -pv $POSTPATH >> $INSTLOG 2>&1
		mkdir -pv $SERVICEPATH >> $INSTLOG 2>&1
	fi
}

# Check for late_start service boot script in post-fs-data.d, in case someone's moved it
post_check() {
	if [ -f "$POSTLATEFILE" ]; then
		log_handler "Removing late_start service boot script from post-fs-data.d."
		rm -f $POSTLATEFILE
	fi
}

# Installs everything
script_install() {
	build_prop_check
	usnf_check
	bin_check
	post_check
	script_placement
	log_print "- Updating placeholders"
	placeholder_update $LATEFILE CACHELOC CACHE_PLACEHOLDER "$CACHELOC"
	placeholder_update $MODPATH/util_functions.sh BIN BIN_PLACEHOLDER "$BIN"
	placeholder_update $MODPATH/util_functions.sh USNFLIST USNF_PLACEHOLDER "$USNFLIST"
	placeholder_update $MODPATH/util_functions.sh SYSTEMLOC SYSTEM_PLACEHOLDER "$SYSTEMLOC"
	placeholder_update $MODPATH/util_functions.sh CACHELOC CACHE_PLACEHOLDER "$CACHELOC"
	placeholder_update $MODPATH/util_functions.sh LATEFILE LATE_PLACEHOLDER "$LATEHOLDER"
	placeholder_update $MODPATH/util_functions.sh POSTFILE POST_PLACEHOLDER "$POSTHOLDER"
	placeholder_update $MODPATH/util_functions.sh MODVERSION VER_PLACEHOLDER "$MODVERSION"
	placeholder_update $MODPATH/util_functions.sh BBWWWPATH BB_PLACEHOLDER "$BBWWWPATH"
	placeholder_update $POSTFILE COREPATH CORE_PLACEHOLDER "$COREPATH"
	placeholder_update $POSTFILE CACHELOC CACHE_PLACEHOLDER "$CACHELOC"
	placeholder_update $LATEFILE POSTFILE POST_PLACEHOLDER "$POSTHOLDER"
	placeholder_update $LATEFILE COREPATH CORE_PLACEHOLDER "$COREPATH"
	placeholder_update $MODPATH/system/$BIN/props LATEFILE LATE_PLACEHOLDER "$LATEHOLDER"
	placeholder_update $MODPATH/system/$BIN/props COREPATH CORE_PLACEHOLDER "$COREPATH"
	print_files
	ui_print ""
	ui_print "- Make sure to have Busybox installed."
	ui_print "- osm0sis' Busybox is recommended."
	ui_print ""
}
