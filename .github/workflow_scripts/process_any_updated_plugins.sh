#!/usr/bin/env bash
###
# File: process_any_updated_plugins.sh
# Project: scripts
# File Created: Friday, 26th August 2022 8:01:50 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Friday, 26th August 2022 8:07:21 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###


script_path=$(readlink -e $(dirname "${BASH_SOURCE[0]}")/)


# TODO: Read IDs from GitHub API
plugin_ids=(
    "notify_radarr"
)
for plugin_id in "${plugin_ids[@]}"; do
    "${script_path}"/create_plugin_pr_branch.sh "${plugin_id}"
done
