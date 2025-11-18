#!/usr/bin/env bash
# Helper para aplicar, atualizar ou remover o tema Goldy Dark para o usuário.
# Adaptado do script do comm-gnome-theme-everforest.

set -e

# --- Configurações do Tema Goldy Dark ---
THEME_NAME="Goldy-Dark"
WALLPAPER_NAME="goldy.heic"
PKG_NAME="comm-gnome-theme-goldy-dark"
# --- Fim das Configurações ---

WALLPAPER_PATH="/usr/share/backgrounds/${PKG_NAME}/${WALLPAPER_NAME}"
CONFIG_DIR="${HOME}/.config"
STATE_DIR="${CONFIG_DIR}/${PKG_NAME}"
STATE_GTK_THEME_FILE="${STATE_DIR}/prev-gtk-theme"
STATE_COLOR_FILE="${STATE_DIR}/prev-color-scheme"
STATE_WALL_FILE="${STATE_DIR}/prev-wallpaper"
STATE_WALL_DARK_FILE="${STATE_DIR}/prev-wallpaper-dark"
CONVERTED_WALLPAPER="${HOME}/.local/share/backgrounds/goldy-wallpaper.jpg"
ACTION="install"

mkdir -p "${STATE_DIR}" 2>/dev/null || true

# Definições de cores
blueDark="\e[1;38;5;33m"
lightBlue="\e[1;38;5;39m"
cyan="\e[1;38;5;45m"
white="\e[1;97m"
reset="\e[0m"

printMsg() {
    local message=$1
    echo -e "${blueDark}[${lightBlue}${PKG_NAME}${blueDark}]${reset} ${cyan}→${reset} ${white}${message}${reset}"
}

usage() {
    cat <<EOF
Uso: install.sh [--install|--upgrade|--uninstall] [--help]

Ações:
  --install, --apply    Aplica o tema Goldy Dark para o usuário atual (padrão)
  --upgrade             Reaplica o tema após uma atualização do pacote
  --uninstall, --remove Remove as customizações do tema e restaura backups
  --help                Mostra esta mensagem
EOF
}

# --- Funções de Backup e Restauração de gsettings ---
save_gsettings_value() {
    local schema="$1" key="$2" file="$3"
    if command -v gsettings &>/dev/null && [ ! -s "${file}" ]; then
        local value
        value=$(gsettings get "${schema}" "${key}" 2>/dev/null || echo "")
        printf '%s\n' "${value}" > "${file}"
    fi
}

restore_gsettings_value() {
    local schema="$1" key="$2" file="$3"
    if command -v gsettings &>/dev/null && [ -s "${file}" ]; then
        local value
        value=$(cat "${file}")
        if gsettings set "${schema}" "${key}" "${value}"; then
            printMsg "Restaurado: ${key} para ${value}"
        fi
        rm -f "${file}"
    fi
}

set_gsettings_with_backup() {
    local schema="$1" key="$2" target_value="$3" backup_file="$4"
    if ! command -v gsettings &>/dev/null; then return 1; fi
    save_gsettings_value "${schema}" "${key}" "${backup_file}"
    if ! gsettings set "${schema}" "${key}" "${target_value}"; then
        printMsg "Aviso: Falha ao definir ${schema} ${key}."
    fi
}

# --- Funções Principais ---
apply_wallpaper() {
    if [ ! -f "${WALLPAPER_PATH}" ]; then
        printMsg "Arquivo de wallpaper não encontrado em ${WALLPAPER_PATH}"
        return
    fi
    printMsg "Definindo wallpaper..."
    local target_path="${WALLPAPER_PATH}"
    if [[ "${WALLPAPER_PATH}" == *.heic ]] && command -v heif-convert &>/dev/null; then
        mkdir -p "$(dirname "${CONVERTED_WALLPAPER}")"
        if heif-convert "${WALLPAPER_PATH}" "${CONVERTED_WALLPAPER}" >/dev/null; then
            target_path="${CONVERTED_WALLPAPER}"
            printMsg "Wallpaper convertido para JPG para maior compatibilidade."
        fi
    fi
    local uri="'file://${target_path}'"
    set_gsettings_with_backup org.gnome.desktop.background picture-uri "${uri}" "${STATE_WALL_FILE}"
    set_gsettings_with_backup org.gnome.desktop.background picture-uri-dark "${uri}" "${STATE_WALL_DARK_FILE}"
}

remove_wallpaper() {
    if [ -f "${CONVERTED_WALLPAPER}" ]; then
        rm -f "${CONVERTED_WALLPAPER}"
    fi
    restore_gsettings_value org.gnome.desktop.background picture-uri "${STATE_WALL_FILE}"
    restore_gsettings_value org.gnome.desktop.background picture-uri-dark "${STATE_WALL_DARK_FILE}"
}

apply_theme() {
    printMsg "Aplicando o tema Goldy Dark..."
    set_gsettings_with_backup org.gnome.desktop.interface gtk-theme "'${THEME_NAME}'" "${STATE_GTK_THEME_FILE}"
    set_gsettings_with_backup org.gnome.desktop.interface color-scheme "'prefer-dark'" "${STATE_COLOR_FILE}"
    apply_wallpaper
    printMsg "Tema Goldy Dark aplicado com sucesso!"
    printMsg "Pode ser necessário reiniciar aplicativos para ver o efeito completo."
}

remove_theme() {
    printMsg "Removendo customizações do tema Goldy Dark..."
    restore_gsettings_value org.gnome.desktop.interface gtk-theme "${STATE_GTK_THEME_FILE}"
    restore_gsettings_value org.gnome.desktop.interface color-scheme "${STATE_COLOR_FILE}"
    remove_wallpaper
    printMsg "Configurações do tema removidas."
}

# --- Lógica de Execução ---
while [[ $# -gt 0 ]]; do
    case "$1" in
    --install|--apply) ACTION="install"; shift ;;
    --upgrade) ACTION="upgrade"; shift ;;
    --uninstall|--remove) ACTION="remove"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opção desconhecida: $1"; usage; exit 1 ;;
    esac
done

case "${ACTION}" in
    install|upgrade) apply_theme ;;
    remove) remove_theme ;;
    *) usage; exit 1 ;;
esac
