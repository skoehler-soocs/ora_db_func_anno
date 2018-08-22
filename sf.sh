if [ -z "$1" ]; then
	echo "Usage: $0 [-l n | -w ] <oracle c function name>"
	echo "-l = level; find annotations at a certain mnemonic level; for example:"
	echo "            $0 -l 3 kc"
	echo "            kc  kernel cache"
	echo "            kcb  buffers"
	echo "            kcc  controlfile"
	echo "            kcf  file management"
	echo "            kck  compatibility"
	echo "            kcl  lock manager"
	echo "            kcm  miscellaneous"
	echo "            kco  operation"
	echo "            kcr  redo"
	echo "            kcs  service"
	echo "            kct  threads"
	echo "-w = wildcard; find anything starting with function name, for example:"
	echo "            $0 -w rpi"
	echo "            rpi  recursive program interface"
	echo "            rpicls  close"
	echo "            rpidru  setup memory for recursive session"
	echo "            rpidrus  recursive program handling"
	echo "            rpidrv  driver"
	exit 1
fi
if [ $1 = "-l" ]; then
	LEVEL=$2
	shift 2
else
	LEVEL=0
fi
if [ $1 = "-w" ]; then
	WILDCARD=yes
	shift
else
	WILDCARD=no
fi
FUNCTION=$1
sqlite3 functions.db "drop table if exists functions;"
sqlite3 functions.db "create table functions (function_name varchar(30), function_sum varchar(60));"
sqlite3 functions.db ".import functions.csv functions"
MIN_LENGTH=$(sqlite3 functions.db "select min(length(function_name)) from functions;")
MAX_LENGTH=$(sqlite3 functions.db "select max(length(function_name)) from functions;")
function_description() {
        LOCAL_FUNCTION_NAME=$1
        USE=$2
	if [[ $LOCAL_FUNCTION_NAME =~ ^__PGOSF[0-9]*_ ]]; then
		LOCAL_FUNCTION_NAME=$(echo $LOCAL_FUNCTION_NAME | sed 's/^__PGOSF[0-9]*_\(.*\)/\1/')
	fi
        LOCAL_FUNCTION_NAME=$(echo $LOCAL_FUNCTION_NAME | sed 's/_/\\_/g')
        [ ${#LOCAL_FUNCTION_NAME} -lt $MAX_LENGTH ] && LOCAL_LENGTH=${#LOCAL_FUNCTION_NAME} || LOCAL_LENGTH=$MAX_LENGTH
        if [ $USE = "n" ]; then
        	RETURN=$(for LEN in $(seq $MIN_LENGTH $LOCAL_LENGTH); do sqlite3 functions.db "select function_sum from functions where function_name like substr('$LOCAL_FUNCTION_NAME',1,$LEN) escape '\';"; done)
        elif [ $USE = "r" ]; then
                RETURN=0
		PREV_RESULT=""
        	for LEN in $(seq $MIN_LENGTH $LOCAL_LENGTH); do
			RESULT="$RESULT$(sqlite3 functions.db "select function_sum from functions where function_name like substr('$LOCAL_FUNCTION_NAME',1,$LEN) escape '\';")"
			if [ "${#RESULT}" -gt "${#PREV_RESULT}" ]; then 
				RETURN=$LEN
				PREV_RESULT=$RESULT
			fi
		done
	elif [ $USE = "l" ]; then
		printf "$(sqlite3 functions.db "select function_name||'\t'||function_sum||'\n' from functions where function_name like '${LOCAL_FUNCTION_NAME}%' and length(function_name) <= $LEVEL;")" | while read OUT; do
			echo "$OUT"
		done
		RETURN=0
	elif [ $USE = "w" ]; then
		printf "$(sqlite3 functions.db "select function_name||'\t'||function_sum||'\n' from functions where function_name like '${LOCAL_FUNCTION_NAME}%';")" | while read OUT; do
			echo "$OUT"
		done
		RETURN=0
	fi
        [ -z "$RETURN" ] && printf "?" || echo $RETURN
}
if [ $WILDCARD = "yes" ]; then
	echo "$(function_description "$FUNCTION" w)" | grep -v '^0$' | grep -v '^$'
elif [ $LEVEL -gt 0 ]; then
	echo "$(function_description "$FUNCTION" l)" | grep -v '^0$' | grep -v '^$'
else
	echo -n "$FUNCTION -- $(function_description "$FUNCTION" n)"
        echo "$PGO_INDICATION"
	for P in $(seq 1 $(function_description "$FUNCTION" r)); do printf "-"; done; printf "\n"
fi
