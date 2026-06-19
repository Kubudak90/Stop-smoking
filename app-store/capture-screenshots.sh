#!/bin/bash
# Nefes — App Store ekran görüntüsü yakalayıcı.
# DEBUG screenshot harness (ScreenshotSupport.swift) ile çalışır; her ekranı
# launch argümanlarıyla deterministik gösterir. iPhone 17 Pro Max = 6.9" App Store boyutu.
set -e

UDID="${1:-800D14D4-7398-4C97-A889-52FC760BD1C3}"   # iPhone 17 Pro Max
APP="${2:-/tmp/nefes-dd/Build/Products/Debug-iphonesimulator/Nefes.app}"
BUNDLE="com.nefes.app"
OUT="$(cd "$(dirname "$0")" && pwd)/screenshots"
mkdir -p "$OUT"

echo "▸ Boot $UDID"
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b

echo "▸ Temiz status bar (9:41)"
xcrun simctl status_bar "$UDID" override \
  --time "9:41" --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 --operatorName "" 2>/dev/null || true

echo "▸ Temiz kurulum"
xcrun simctl uninstall "$UDID" "$BUNDLE" 2>/dev/null || true
xcrun simctl install "$UDID" "$APP"

shot () {  # shot <isim> <bekleme> <env...>
  local name="$1"; local wait="$2"; shift 2
  echo "▸ $name"
  env "$@" xcrun simctl launch --terminate-running-process "$UDID" "$BUNDLE" >/dev/null
  sleep "$wait"
  xcrun simctl io "$UDID" screenshot "$OUT/$name.png"
}

# 01 — Onboarding (temiz, profil yok)
shot "01-onboarding" 5

# Tohumlu ekranlar (premium açık → zengin içerik)
shot "02-counter"  6 SIMCTL_CHILD_UITEST_SEED=1 SIMCTL_CHILD_UITEST_PREMIUM=1 SIMCTL_CHILD_UITEST_TAB=0
shot "03-program"  5 SIMCTL_CHILD_UITEST_SEED=1 SIMCTL_CHILD_UITEST_PREMIUM=1 SIMCTL_CHILD_UITEST_TAB=1
shot "04-recovery" 5 SIMCTL_CHILD_UITEST_SEED=1 SIMCTL_CHILD_UITEST_PREMIUM=1 SIMCTL_CHILD_UITEST_TAB=2
shot "05-stats"    5 SIMCTL_CHILD_UITEST_SEED=1 SIMCTL_CHILD_UITEST_PREMIUM=1 SIMCTL_CHILD_UITEST_TAB=3
shot "06-settings" 5 SIMCTL_CHILD_UITEST_SEED=1 SIMCTL_CHILD_UITEST_PREMIUM=1 SIMCTL_CHILD_UITEST_TAB=4
shot "07-craving-sos" 6 SIMCTL_CHILD_UITEST_SEED=1 SIMCTL_CHILD_UITEST_PREMIUM=1 SIMCTL_CHILD_UITEST_TAB=0 SIMCTL_CHILD_UITEST_SCREEN=sos
shot "08-paywall"  6 SIMCTL_CHILD_UITEST_SEED=1 SIMCTL_CHILD_UITEST_TAB=0 SIMCTL_CHILD_UITEST_SCREEN=paywall

xcrun simctl status_bar "$UDID" clear 2>/dev/null || true
echo "✓ Bitti → $OUT"
ls -1 "$OUT"
