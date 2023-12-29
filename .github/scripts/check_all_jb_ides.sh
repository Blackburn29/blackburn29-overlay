#!/bin/bash

SCRIPTS_DIR="./.github/scripts"

declare -A ides=( \
    ["IIU"]="dev-util/idea-ultimate" \
    ["DG"]="dev-util/datagrip" \
    ["WS"]="dev-util/webstorm" \
    ["RR"]="dev-util/rustrover" \
    ["RD"]="dev-dotnet/rider" \
)

for ide in "${!ides[@]}"; do
    AVAILABLE_UPDATE=$(bash -c "$SCRIPTS_DIR/check_jetbrains.sh $ide ${ides[$ide]}")

    if [ -n "$AVAILABLE_UPDATE" ];
    then
        echo "Update available for ${ides[$ide]}: $AVAILABLE_UPDATE"
    fi
done

