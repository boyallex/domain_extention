#!/usr/bin/env zsh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

app="$root/build/macos/Build/Products/Debug/domain_extention.app"
port="${VM_SERVICE_PORT:-54721}"
flutter_bin="${FLUTTER_ROOT:-/Users/axcel/src/flutter}/bin/flutter"
if [[ ! -x "$flutter_bin" ]]; then
  flutter_bin="$(command -v flutter)"
fi

"$flutter_bin" build macos --debug

binary="$app/Contents/MacOS/domain_extention"
pkill -f "$binary" 2>/dev/null || true
sleep 0.4

open -n "$app" \
  --env "FLUTTER_ENGINE_SWITCHES=6" \
  --env "FLUTTER_ENGINE_SWITCH_1=enable-dart-profiling=true" \
  --env "FLUTTER_ENGINE_SWITCH_2=enable-checked-mode=true" \
  --env "FLUTTER_ENGINE_SWITCH_3=verify-entry-points=true" \
  --env "FLUTTER_ENGINE_SWITCH_4=disable-service-auth-codes=true" \
  --env "FLUTTER_ENGINE_SWITCH_5=disable-service-origin-check=true" \
  --env "FLUTTER_ENGINE_SWITCH_6=vm-service-port=${port}"

for _ in {1..60}; do
  if nc -z 127.0.0.1 "$port" 2>/dev/null; then
    exit 0
  fi
  sleep 0.25
done

echo "VM Service не поднялся на 127.0.0.1:${port}" >&2
exit 1
