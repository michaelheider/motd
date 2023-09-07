#!/bin/bash
set -euo pipefail

# Output CPU usage in percent.
# Includes a noticeable sleep time.

TOOL_PATH=$(realpath "$(dirname "$0")/../tools")
# shellcheck source-path=../tools
source "${TOOL_PATH}/colors.sh"

# return idle and total CPU time since system start
cpuStats() {
	read -r -a cpu <<<"$(grep '^cpu ' /proc/stat)"
	idle=$((cpu[4] + cpu[5]))
	unset 'cpu[0]'
	total=$((${cpu[@]/%/+}0))
	echo "$idle $total"
}

read -r -a start <<<"$(cpuStats)"
echo "measuring CPU load..." >&2
sleep 0.5 # making this longer gives a better average
echo -e "$LINE_UP$LINE_CLEAR$LINE_UP" >&2 # clear previous message
read -r -a end <<<"$(cpuStats)"

idle=$((end[0] - start[0]))
total=$((end[1] - start[1]))

cpuUsage=$((100 * (total - idle) / total)) # in percent

echo "${cpuUsage}"
