
#!/bin/sh
set -eu

echo "=== Searching MI-MINI kernel config ==="

CONFIG="$(find padavan-ng/trunk/configs/boards \
  -path '*/MI-MINI/kernel-3.4.x.config' -print -quit)"

if [ -z "$CONFIG" ]; then
    echo "ERROR: MI-MINI kernel config not found"
    exit 1
fi

echo "Found: $CONFIG"

echo "=== Current relevant options ==="
grep -E 'CONFIG_(IFB|NET_CLS_ACT|NET_ACT_MIRRED|NET_SCH_INGRESS|NET_SCH_CAKE)' \
  "$CONFIG" || true

echo "=== Enabling IFB and traffic redirection ==="

set_config() {
    KEY="$1"
    VALUE="$2"

    if grep -q "^${KEY}=" "$CONFIG"; then
        sed -i "s|^${KEY}=.*|${KEY}=${VALUE}|" "$CONFIG"
    elif grep -q "^# ${KEY} is not set" "$CONFIG"; then
        sed -i "s|^# ${KEY} is not set|${KEY}=${VALUE}|" "$CONFIG"
    else
        echo "${KEY}=${VALUE}" >> "$CONFIG"
    fi
}

set_config CONFIG_IFB m
set_config CONFIG_NET_CLS_ACT y
set_config CONFIG_NET_ACT_MIRRED m
set_config CONFIG_NET_SCH_INGRESS m

echo "=== Updated relevant options ==="
grep -E 'CONFIG_(IFB|NET_CLS_ACT|NET_ACT_MIRRED|NET_SCH_INGRESS|NET_SCH_CAKE)' \
  "$CONFIG" || true

echo "=== IFB configuration patch completed ==="
