#!/bin/bash
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --optimize)
        echo "Optimize requested"
        shift
    ;;
    -o)
        OUTPUT_FILE="$2"
        shift
        shift
    ;;
    *)
        if [[ "$key" == "-"* ]]; then
            echo "Option $key not supported"
            exit 1
        else
            INPUT_FILE="$1"
        fi
        shift
    ;;
esac
done

exec ffmpeg -i "$INPUT_FILE" -y "$OUTPUT_FILE"
