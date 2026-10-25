#!/usr/bin/env bash
# ==========================================================================
# EICL — Verificador de saneamiento
#
# Aplica la norma «EICL – Criterios de protección de la información»:
# busca datos que nunca deben publicarse y bloquea el commit si los encuentra.
#
# Uso:
#   scripts/check-sanitization.sh                 revisa los archivos preparados (git add)
#   scripts/check-sanitization.sh --all           revisa todos los archivos del repositorio
#   scripts/check-sanitization.sh archivo1 ...    revisa archivos concretos
#
# Patrones personales: crea un archivo .sanitize-private en la raíz del repo
# (está en .gitignore, nunca se sube) con un dato por línea: la IP de tu PC
# de administración, tu usuario y hostname, números de serie completos, etc.
# Se buscan como texto literal, sin distinguir mayúsculas.
#
# Código de salida: 0 = limpio · 1 = hallazgos · 2 = error de uso
# ==========================================================================
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PRIVATE_FILE="$ROOT/.sanitize-private"
FOUND=0

red()    { printf '\033[31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }

# --- Archivos excluidos del análisis (contienen los propios patrones) ---
is_excluded() {
  case "$1" in
    scripts/check-sanitization.sh|.gitleaks.toml|.pre-commit-config.yaml) return 0 ;;
  esac
  return 1
}

# --- Patrones genéricos (regex Perl) : "motivo|||regex" ---
PATTERNS=(
  "Dirección MAC (xx:xx:xx:xx:xx:xx)|||(?<![0-9A-Fa-f:])([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}(?![0-9A-Fa-f:])"
  "Dirección MAC formato Huawei (xxxx-xxxx-xxxx)|||(?<![0-9A-Fa-f-])[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}(?![0-9A-Fa-f-])"
  "Interfaz con MAC en el nombre (wlx/enx)|||\b(wlx|enx)[0-9A-Fa-f]{12}\b"
  "Contraseña cifrada de FortiOS (ENC)|||\bENC\s+[A-Za-z0-9+/=]{16,}"
  "Contraseña cifrada de Huawei (cipher / %^%#)|||(irreversible-cipher|password\s+cipher|%\^%#|%@%@)"
  "Hash de contraseña Unix (\$1\$ \$5\$ \$6\$ \$y\$)|||\\\$(1|5|6|y|2[aby])\\\$[A-Za-z0-9./]{4,}"
  "Llave privada|||-----BEGIN [A-Z ]*PRIVATE KEY-----"
  "Número de serie completo de FortiGate|||\bFG(?![0-9A-Z]*XXXXXX)[0-9A-Z]{12,16}\b"
  "UUID (objetos o políticas)|||\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b"
  "PSK, secreto o comunidad SNMP en configuración|||\bset\s+(psksecret|secret|passwd|password|community)\s+\S+|\bsnmp-agent\s+community\s+\S+"
  "Ruta personal de Windows|||[A-Za-z]:\\\\Users\\\\[^\\\\\s]+"
  "Ruta personal de Linux/macOS|||(/home|/Users)/[a-z_][a-z0-9_.-]+/"
  "IPv6 de enlace local (equipos personales)|||\bfe80:(:[0-9a-fA-F]{0,4}){1,7}"
  "Token de API o acceso|||(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16})"
)

# --- Nombres de archivo que nunca deben publicarse ---
FORBIDDEN_NAMES='(\.conf|\.cfg|\.bak|\.zip|\.7z|\.rar|\.pem|\.key|\.p12|\.pfx|\.kdbx|\.ovpn)$|vrpcfg|base-LAB-|EICL-PKG-|_ORIGINAL\.|/originales/|/sin-sanear/|/privado/'

report() { # archivo, motivo, líneas
  red "✗ $1 — $2"
  printf '%s\n' "$3" | head -n 5 | sed 's/^/    /'
  FOUND=1
}

check_text() { # archivo (o "-" para stdin con etiqueta en $2)
  local file="$1" label="${2:-$1}" content
  if [[ "$file" == "-" ]]; then content="$(cat)"; else content="$(cat "$file")"; fi

  local entry name regex hits
  for entry in "${PATTERNS[@]}"; do
    name="${entry%%|||*}"; regex="${entry#*|||}"
    hits="$(printf '%s' "$content" | grep -nP -- "$regex" 2>/dev/null || true)"
    [[ -n "$hits" ]] && report "$label" "$name" "$hits"
  done

  if [[ -s "$PRIVATE_FILE" ]]; then
    local pat
    while IFS= read -r pat || [[ -n "$pat" ]]; do
      pat="${pat%%#*}"; pat="$(printf '%s' "$pat" | sed 's/[[:space:]]*$//')"
      [[ -z "$pat" ]] && continue
      hits="$(printf '%s' "$content" | grep -niF -- "$pat" 2>/dev/null | cut -c1-120 || true)"
      [[ -n "$hits" ]] && report "$label" "Dato personal de .sanitize-private" "$hits"
    done < "$PRIVATE_FILE"
  fi
}

check_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  is_excluded "$f" && return 0

  if printf '%s' "$f" | grep -qiE "$FORBIDDEN_NAMES"; then
    report "$f" "Tipo o nombre de archivo prohibido (respaldo, paquete, llave u original)" "$f"
    return 0
  fi

  case "${f,,}" in
    *.pdf)
      if command -v pdftotext >/dev/null; then
        pdftotext -q "$f" - 2>/dev/null | check_text - "$f (texto del PDF)"
      else
        yellow "! $f — pdftotext no instalado: el texto del PDF no se revisó"
      fi
      if command -v exiftool >/dev/null; then
        local meta; meta="$(exiftool -s -Author -Creator -Producer -Title "$f" 2>/dev/null)"
        printf '%s' "$meta" | check_text - "$f (metadatos)"
      fi
      ;;
    *.png|*.jpg|*.jpeg|*.heic|*.webp|*.tif|*.tiff)
      if command -v exiftool >/dev/null; then
        local gps; gps="$(exiftool -s -GPS:all -XMP:GPS* "$f" 2>/dev/null)"
        [[ -n "$gps" ]] && report "$f" "Imagen con ubicación GPS en los metadatos (quítala con: exiftool -all= archivo)" "$gps"
        local cam; cam="$(exiftool -s -SerialNumber -OwnerName -Artist "$f" 2>/dev/null)"
        [[ -n "$cam" ]] && report "$f" "Imagen con número de serie o dueño de la cámara en los metadatos" "$cam"
      else
        yellow "! $f — exiftool no instalado: no se revisaron los metadatos de la imagen"
      fi
      ;;
    *)
      # Solo archivos de texto
      if grep -Iq . "$f" 2>/dev/null; then check_text "$f"; fi
      ;;
  esac
}

# --- Selección de archivos ---
cd "$ROOT" || exit 2
FILES=()
if [[ $# -eq 0 ]]; then
  mapfile -t FILES < <(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null)
elif [[ "$1" == "--all" ]]; then
  mapfile -t FILES < <(git ls-files 2>/dev/null || find . -type f -not -path './.git/*' | sed 's|^\./||')
else
  FILES=("$@")
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  green "Sin archivos que revisar."
  exit 0
fi

[[ -s "$PRIVATE_FILE" ]] || yellow "! No existe .sanitize-private: solo se aplican los patrones genéricos."

for f in "${FILES[@]}"; do check_file "$f"; done

if [[ $FOUND -ne 0 ]]; then
  echo
  red "Saneamiento: se encontraron datos que no deben publicarse."
  echo "Corrige los archivos (marcadores como <IP-PC-ADMIN> o <REDACTADO>) y vuelve a intentarlo."
  echo "Si es un falso positivo claro, documéntalo antes de forzar con --no-verify."
  exit 1
fi

green "✓ Saneamiento correcto (${#FILES[@]} archivo(s) revisados)."
exit 0
