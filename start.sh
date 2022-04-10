#!/usr/bin/env bash
set -eu -o pipefail

ETC_PRINTERS_CONF="/etc/cups/printers.conf"
ETC_PPD_DIR="/etc/cups/ppd"
VOLUME_PRINTERS_CONF="/config/printers.conf"
VOLUME_PPD_DIR="/config/ppd"

cups_user="${CUPS_USER:-cups}"
echo "Create user '$cups_user'"
if [[ -f /run/secrets/cups_password ]]; then
  cups_password="$(cat /run/secrets/cups_password)"
else
  cups_password="cups"
  echo "WARNING: Using default password '$cups_password'"
fi

if ! id -u "$cups_user" >/dev/null 2>&1; then
  useradd --groups=lp,lpadmin --no-create-home \
    "$cups_user"
fi
echo "$cups_user:$cups_password" | chpasswd

# Set default papersize
echo "${DEFAULT_PAPER_SIZE:-a4}" >/etc/papersize

if [[ ! -f /run/dbus/pid ]]; then
  echo "Start dbus"
  mkdir -p /var/run/dbus
  dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address
fi

if [[ ! -f /run/avahi-daemon/pid ]]; then
  echo "Start avahi-daemon"
  avahi-daemon --daemonize
fi

echo "Create symlink for ppd files"
rm -rf "${ETC_PPD_DIR}"
mkdir -p "${VOLUME_PPD_DIR}"
ln -s "${VOLUME_PPD_DIR}" "${ETC_PPD_DIR}"

echo "Check for existing printers.conf"
if [[ ! -f /config/printers.conf ]]; then
  echo "Create new file at ${VOLUME_PRINTERS_CONF}"
  touch "${VOLUME_PRINTERS_CONF}"
fi

echo "Copy ${VOLUME_PRINTERS_CONF} to ${ETC_PRINTERS_CONF}"
cp "${VOLUME_PRINTERS_CONF}" "${ETC_PRINTERS_CONF}"

./detect-changes.sh "${ETC_PRINTERS_CONF}" "${VOLUME_PRINTERS_CONF}" &

echo "Start cups"
cupsd -f
