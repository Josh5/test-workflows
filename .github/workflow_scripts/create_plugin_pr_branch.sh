#!/usr/bin/env bash
###
# File: create_plugin_pr_branch copy.sh
# Project: workflow_scripts
# File Created: Friday, 26th August 2022 8:17:10 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Friday, 26th August 2022 8:51:34 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###
#
# Generate a plugin PR for the official repo
#
###

official_git_repo="git@github.com:Unmanic/unmanic-plugins.git"
repo_root_path=$(readlink -e $(dirname "${BASH_SOURCE[0]}")/../../)

plugin_id="${@}"
plugin_location="${repo_root_path}/build/plugin.${plugin_id}"

if [[ -z ${plugin_id} ]]; then
    echo "You forgot to provide the ID of one of your plugins..."
    exit 1
fi


########################################################################
### UPDATE SUBMODULES
pushd "${plugin_location}" &> /dev/null
# Update any submodules
echo -e "\n*** Pulling plugin submodules"
git submodule update --init --recursive 
popd &> /dev/null


########################################################################
### PATCH PROJECT
pushd "${plugin_location}" &> /dev/null
# Apply any patches
if [[ -d ./patches ]]; then
    echo -e "\n*** Patching project"
    find ./patches -type f -name "*.patch" -exec patch -p1 --input="{}" --forward --verbose \;
fi
popd &> /dev/null


########################################################################
### BUILD/INSTALL
pushd "${repo_root_path}" &> /dev/null
# Install/update plugin files
echo -e "\n*** Installing files from plugin git repo to this repository's source directory"
rsync -avh --delete \
    --exclude='.git/' \
    --exclude='.gitmodules' \
    --exclude='.idea/' \
    "${plugin_location}/" "${repo_root_path}/source/${plugin_id}"
# Read plugin version
plugin_version=$(cat ${plugin_location}/info.json | jq -rc '.version')
[[ ${plugin_version} == "null" ]] && echo "Failed to fetch the plugin's version from the info.json file. Exit!" && exit 1;
popd &> /dev/null


########################################################################
### COMMIT
pushd "${repo_root_path}" &> /dev/null
echo -e "\n*** Commit changes in unmanic-plugins repository"
commit_message="[${plugin_id}] v${plugin_version}"
echo ${commit_message}
git add .
git commit -m "${commit_message}"
if [[ $? -gt 0 ]]; then
    echo
    echo "No commit created. Possibly because there was nothing to commit!"
    echo "PR branch will not be pushed." 
    exit 1
fi
popd &> /dev/null
