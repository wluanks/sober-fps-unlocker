#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.var/app/org.vinegarhq.Sober/data/sober/appData/GlobalBasicSettings_13.xml"
DEFAULT_FPS=10000

usage() {
    cat <<EOF
Uso: $(basename "$0") [--fps N] [--undo]

Remove o teto de 240 FPS do Sober (cliente Roblox pra Linux) travando o
FramerateCap no arquivo de configurações como imutável. O Roblox
sobrescreve esse arquivo (via substituição atômica) toda vez que abre,
o que ignora permissões normais de somente-leitura -- por isso é
necessário o atributo imutável do sistema de arquivos (chattr +i).

  --fps N   define o valor do FramerateCap (padrão: $DEFAULT_FPS)
  --undo    destrava o arquivo (chattr -i) sem mudar o valor
  -h        mostra essa ajuda

Requer sudo (pra chattr) e que o Sober já tenha sido aberto ao menos
uma vez, pro arquivo de configuração existir.
EOF
}

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    echo "Não rode o script inteiro com sudo -- ele já chama sudo internamente só onde precisa." >&2
    echo "Rode assim: ./$(basename "$0")" >&2
    exit 1
fi

FPS="$DEFAULT_FPS"
UNDO=0

while [ $# -gt 0 ]; do
    case "$1" in
        --fps) FPS="$2"; shift 2 ;;
        --undo) UNDO=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Opção desconhecida: $1" >&2; usage; exit 1 ;;
    esac
done

if [ ! -f "$CONFIG" ]; then
    echo "Não encontrei $CONFIG" >&2
    echo "Abra o Sober pelo menos uma vez antes de rodar esse script." >&2
    exit 1
fi

if [ "$UNDO" -eq 1 ]; then
    sudo chattr -i "$CONFIG"
    echo "Arquivo destravado: $CONFIG"
    exit 0
fi

if ! [[ "$FPS" =~ ^[0-9]+$ ]]; then
    echo "--fps precisa ser um número inteiro positivo" >&2
    exit 1
fi

sudo chattr -i "$CONFIG" 2>/dev/null || true

if ! grep -q '<int name="FramerateCap">' "$CONFIG"; then
    echo "Não encontrei o campo FramerateCap em $CONFIG -- formato inesperado, abortando." >&2
    exit 1
fi

sed -i -E "s/<int name=\"FramerateCap\">-?[0-9]+<\/int>/<int name=\"FramerateCap\">${FPS}<\/int>/" "$CONFIG"
sudo chattr +i "$CONFIG"

echo "FramerateCap definido para $FPS e arquivo travado (chattr +i)."
echo "Pra desfazer: $(basename "$0") --undo"
