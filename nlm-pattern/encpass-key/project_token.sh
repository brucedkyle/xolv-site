#!/bin/sh

. encpass.sh
export PROJECT_TOKEN=$(get_secret project_token.sh project_token)

echo "PROJECT_TOKEN=\$(get_secret project_token.sh project_token)"
echo "PROJECT_TOKEN = $PROJECT_TOKEN"
echo ""
