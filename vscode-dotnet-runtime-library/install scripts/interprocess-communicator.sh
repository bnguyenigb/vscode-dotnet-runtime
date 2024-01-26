#!/usr/bin/env bash
EXECFOLDER=$1 # First argument is the working folder as this is launched with cwd of /root
OKSIGNALFILE="$EXECFOLDER/ok.txt"
COMMANDTORUNFILE="$EXECFOLDER/command.txt"
OUTPUTFILE="/home/viru/om.txt"
end=$((SECONDS+3600))
while true
do
        stop=false
        while [ $SECONDS -lt $end ];
        do
            if test -f "$COMMANDTORUNFILE"; then
                # echo "COMMAND FILE FOUND" >> "$OUTPUTFILE" # Leave this here as an example of debugging
                COMMAND="$(cat "$COMMANDTORUNFILE" | awk '{$1=$1;print}')"
                for validCmd in "${@:2}"
                do
                    if [ "$COMMAND" == "$validCmd" ]; then
                        IFS=' ' read -ra COMMANDARGS <<< "$COMMAND"
                    fi
                done
                if [ -z "$COMMANDARGS" ]; then
                    rm "$COMMANDTORUNFILE"
                    exit 111777 # Special exit code - arbitrarily picked for when the command is not expected
                fi
                sudo "${COMMANDARGS[@]}" 2> "$EXECFOLDER/stderr.txt" 1> "$EXECFOLDER/stdout.txt"
                STATUSCODE=$?
                echo $STATUSCODE > "$EXECFOLDER/status.txt"
                rm "$COMMANDTORUNFILE"
                touch "$EXECFOLDER/output.txt"
            fi
            if test -f "$OKSIGNALFILE"; then
                rm "$OKSIGNALFILE"
            fi
            sleep 5
        done
done
