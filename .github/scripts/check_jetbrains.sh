# Checks the Jetbrains API for the latest version of a given product code and compares it to a given ebuild directory
#

# Known product codes:
# IDEA: IIU
# Rider: RD
# Datagrip: DG
# CLion: CL
# RustRover: RR
# WebStorm: WS


CURRENT_TIMESTAMP=$(date +%s%N | cut -b1-13)
LATEST_VERSION=$(curl -s "https://data.services.jetbrains.com/products?code=$1%2CIIC&release.type=release&_=${CURRENT_TIMESTAMP}" |  \
    jq .[0].releases.[0].downloads.linux.link | \
    grep -Eow '([0-9\.]+)' \
)

CURRENT_EBUILD=$(find $2 -name '*.ebuild' | sort -Vr | head -n1 | perl -n -e'/([0-9\.]+).ebuild/ && print $1')

#echo "Current ebuild version: $CURRENT_EBUILD"
#echo "Latest JetBrains version: $LATEST_VERSION"

if [ "$LATEST_VERSION" != "$CURRENT_EBUILD" ]; then
    echo "$LATEST_VERSION"
    exit 1
fi
