#!/bin/bash
set -euo pipefail

# Print status of services.
# Run it to see what it looks like.

# config
columns=2
filter='' # excluded containers separated by |

TOOL_PATH=$(realpath "$(dirname "$0")/../tools")
# shellcheck source-path=../tools
source "${TOOL_PATH}/colors.sh"

if ! "${TOOL_PATH}/package-check.sh" docker; then
	echo -e "${COLOR_INFO}docker not installed${RESET}"
	exit 0
fi

mapfile -t containers < <(docker ps -a --format "{{.Names}} {{.Status}}" | awk '!/^('"${filter}"')/{print $1,$2}')

out=''
for i in "${!containers[@]}"; do
	IFS=" " read -r name status <<<"${containers[$i]}"
	status=$(colorMatch "${status}" 'Up')
	out+="${name}|${status,,}|"
	(($(((i + 1) % columns)) == 0)) && out+='\n'
done
if [[ -z "${out}" ]]; then
	out='none'
fi
out+='\n'

echo 'docker containers:'
echo -e "${out}" | column -ts '|' | sed -e 's/^/  /'
