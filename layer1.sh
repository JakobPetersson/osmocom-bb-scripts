#!/usr/bin/env bash
# Layer1 osmocom BB

# Print directions
function press_button {
	echo "Loading layer1 with osmocon."
	echo "Press POWER-Button NOW!"
}

#Usage
function usage() {
	echo    "Usage: layer1.sh [OPTION]..."  >&2
	echo -e "Loads layer1 on osmocom phones.\n"  >&2
	echo    "  -m    Phone model" >&2
	echo    "  -p    Serial Port" >&2
	echo    "  -i    " >&2
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

# Var init
PHONEMODEL=""
EXTRAARGS=""
SERIALPORT="/dev/ttyUSB0"

# Get args
while getopts ":p:i:m:h" opt; do
	case $opt in
	p)
		SERIALPORT=$OPTARG
		;;
	i)
		re='^[0-9]+$'
		if ! [[ $OPTARG =~ $re ]] ; then
			echo "-n argument error: \"$OPTARG\" Not a number." >&2
			exit 1
		fi
		EXTRAARGS="-s /tmp/osmocom_l2.$OPTARG -l /tmp/osmocom_loader.$OPTARG"
		;;
	m)
		PHONEMODEL=$OPTARG
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

# Load with osmocon
case "$PHONEMODEL" in
	"c115" | "c117" | "c118" | "c121" | "c123") # Motorola C115/C117/C118/C121/C123
		press_button
		./src/host/osmocon/osmocon -p "$SERIALPORT" -m c123xor $EXTRAARGS ./src/target/firmware/board/compal_e88/layer1.compalram.bin
		;;
	"c139" | "c140") # Motorola C139/C140
		press_button
		./src/host/osmocon/osmocon -p "$SERIALPORT" -m c140xor $EXTRAARGS -c ./src/target/firmware/board/compal_e86/layer1.highram.bin
		;;
	"j100i") # Sony Ericsson j100i
		press_button
		./src/host/osmocon/osmocon -p "$SERIALPORT" -m c140xor $EXTRAARGS -c ./src/target/firmware/board/se_j100/layer1.highram.bin
		;;
	*)
		invalid_phone_model
		exit 1
		;;
esac
