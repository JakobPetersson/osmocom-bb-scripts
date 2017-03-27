#!/usr/bin/env bash
# Layer1 osmocom BB

# Print directions
function press_button {
	echo "Loading app with osmocon."
	echo "Press POWER-Button NOW!"
}

#Usage
function usage() {
	echo    "Usage: load_app.sh [OPTION]..."  >&2
	echo -e "Loads layer1 on osmocom phones.\n" >&2
	echo    "  -m    Phone model" >&2
	echo    "  -p    Serial Port" >&2
	echo    "  -a    App name" >&2
	valid_phones
}

# Valid phone models
function valid_phones() {
	echo -e ""
	echo "Valid phone models:"  >&2
	echo "  Motorola c115 c117 c118 c121 c123 c139 c140"  >&2
	echo "  Ericsson j100i"  >&2
}

#Invalid phone model
function invalid_phone_model() {
	echo "Error: \"$PHONEMODEL\" not a valid phone model." >&2
	valid_phones
}

#
function load_app_path() {
	case "$PHONEMODEL" in
		"c115" | "c117" | "c118" | "c121" | "c123") # Motorola C115/C117/C118/C121/C123
			APPPATH="./src/target/firmware/board/compal_e88/$APPNAME.compalram.bin"
			;;
		"c139" | "c140") # Motorola C139/C140
			APPPATH="./src/target/firmware/board/compal_e86/$APPNAME.highram.bin"
			;;
		"j100i") # Sony Ericsson j100i
			APPPATH="./src/target/firmware/board/se_j100/$APPNAME.highram.bin"
			;;
		*)
			APPPATH=""
			;;
	esac
	if [ ! -e "$APPPATH" ]; then
		echo "Error: App file not found. [$APPPATH]"
		exit 1
	fi
}

# Var init
PHONEMODEL=""
SERIALPORT="/dev/ttyUSB0"
APPNAME=""
APPPATH=""

# Get args
while getopts ":p:m:a:h" opt; do
	case $opt in
	p)
		SERIALPORT=$OPTARG
		;;
	m)
		PHONEMODEL=$OPTARG
		;;
	a)
		APPNAME=$OPTARG
		;;
	h)
		usage
		exit 1
		;;
	\?)
		echo "Unknown option: -$OPTARG" >&2;
		exit 1
		;;
	:)
		echo "Missing option argument for -$OPTARG" >&2;
		exit 1
		;;
	*)
		echo "Unimplemented option: -$OPTARG" >&2;
		exit 1
		;;
	esac
done

if [ "$PHONEMODEL" = "" ]; then
	echo "Error: -m argument required" >&2
	valid_phones
	exit 1
fi

if [ "$APPNAME" = "" ]; then
	echo "Error: -a argument required" >&2
	exit 1
fi

load_app_path

# Load with osmocon
case "$PHONEMODEL" in
	"c115" | "c117" | "c118" | "c121" | "c123") # Motorola C115/C117/C118/C121/C123
		press_button
		./src/host/osmocon/osmocon -p "$SERIALPORT" -m c123xor "$APPPATH"
		;;
	"c139" | "c140") # Motorola C139/C140
		press_button
		./src/host/osmocon/osmocon -p "$SERIALPORT" -m c140xor -c "$APPPATH"
		;;
	"j100i") # Sony Ericsson j100i
		press_button
		./src/host/osmocon/osmocon -p "$SERIALPORT" -m c140xor -c "$APPPATH"
		;;
	*)
		invalid_phone_model
		exit 1
		;;
esac
