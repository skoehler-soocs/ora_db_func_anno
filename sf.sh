FUNCTION=$1
sqlite3 memory_ranges.db "drop table if exists functions;"
sqlite3 memory_ranges.db "create table functions (function_name varchar(30), function_sum varchar(60));"
sqlite3 memory_ranges.db ".import functions.csv functions"
MIN_LENGTH=$(sqlite3 memory_ranges.db "select min(length(function_name)) from functions;")
MAX_LENGTH=$(sqlite3 memory_ranges.db "select max(length(function_name)) from functions;")
function_description() {
        LOCAL_FUNCTION_NAME=$(echo $1 | sed 's/_/\\_/g')
        USE=$2
        [ ${#LOCAL_FUNCTION_NAME} -lt $MAX_LENGTH ] && LOCAL_LENGTH=${#LOCAL_FUNCTION_NAME} || LOCAL_LENGTH=$MAX_LENGTH
        if [ $USE = "n" ]; then
        	RETURN=$(for LEN in $(seq $MIN_LENGTH $LOCAL_LENGTH); do sqlite3 memory_ranges.db "select function_sum from functions where function_name like substr('$LOCAL_FUNCTION_NAME',1,$LEN) escape '\';"; done)
        else
                RETURN=0
		PREV_RESULT=""
        	for LEN in $(seq $MIN_LENGTH $LOCAL_LENGTH); do
			RESULT="$RESULT$(sqlite3 memory_ranges.db "select function_sum from functions where function_name like substr('$LOCAL_FUNCTION_NAME',1,$LEN) escape '\';")"
			if [ "${#RESULT}" -gt "${#PREV_RESULT}" ]; then 
				RETURN=$LEN
				PREV_RESULT=$RESULT
			fi
		done
	fi
        [ -z "$RETURN" ] && printf "?" || echo $RETURN
}
echo "$FUNCTION -- $(function_description "$FUNCTION" n)"
for P in $(seq 1 $(function_description "$FUNCTION" r)); do printf "-"; done; printf "\n"
