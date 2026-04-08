#!/bin/bash

############################################################################
# Store Jamf LAPS app config as ONE Keychain item in the logged-in user's
# login Keychain.
# Author:Deepak Gandhi
# Parameter 4: Jamf Pro URL
# Parameter 5: OAuth Client ID
# Parameter 6: OAuth Client Secret
# Parameter 7: Teams Webhook URL
############################################################################

CURRENT_USER=$(/usr/bin/stat -f %Su /dev/console)
CURRENT_UID=$(/usr/bin/id -u "$CURRENT_USER" 2>/dev/null)

JAMF_URL="${4:-}"
CLIENT_ID="${5:-}"
CLIENT_SECRET="${6:-}"
TEAMS_URL="${7:-}"

SERVICE_NAME="JamfLAPSUI"
ACCOUNT_NAME="config"
APP_PATH="/Applications/LAPSTool.app"
LOG_FILE="/Library/Logs/JamfLAPSUI_KeychainSetup.log"

log() {
  /bin/echo "$(/bin/date '+%Y-%m-%d %H:%M:%S') | $*" >> "$LOG_FILE"
}

run_as_user() {
  /bin/launchctl asuser "$CURRENT_UID" /usr/bin/sudo -u "$CURRENT_USER" "$@"
}

json_escape() {
  /usr/bin/python3 -c 'import json,sys; print(json.dumps(sys.argv[1])[1:-1])' "$1"
}

############################################################################
# Preconditions
############################################################################

/usr/bin/touch "$LOG_FILE"
/bin/chmod 600 "$LOG_FILE"

if [[ -z "$CURRENT_USER" || "$CURRENT_USER" == "root" || -z "$CURRENT_UID" ]]; then
  log "ERROR | No logged-in user detected"
  exit 1
fi

if [[ ! -d "$APP_PATH" ]]; then
  log "ERROR | App not found at path: $APP_PATH"
  exit 1
fi

if [[ -z "$JAMF_URL" || -z "$CLIENT_ID" || -z "$CLIENT_SECRET" ]]; then
  log "ERROR | Missing required parameters"
  exit 1
fi

log "START | user=${CURRENT_USER} | uid=${CURRENT_UID}"

############################################################################
# Build single JSON config blob
############################################################################

ESC_JAMF_URL=$(json_escape "$JAMF_URL")
ESC_CLIENT_ID=$(json_escape "$CLIENT_ID")
ESC_CLIENT_SECRET=$(json_escape "$CLIENT_SECRET")
ESC_TEAMS_URL=$(json_escape "$TEAMS_URL")

CONFIG_JSON="{\"jamfURL\":\"${ESC_JAMF_URL}\",\"clientID\":\"${ESC_CLIENT_ID}\",\"clientSecret\":\"${ESC_CLIENT_SECRET}\",\"teamsURL\":\"${ESC_TEAMS_URL}\"}"

############################################################################
# Recreate keychain item
############################################################################

run_as_user /usr/bin/security delete-generic-password \
  -a "$ACCOUNT_NAME" \
  -s "$SERVICE_NAME" >/dev/null 2>&1

run_as_user /usr/bin/security add-generic-password \
  -a "$ACCOUNT_NAME" \
  -s "$SERVICE_NAME" \
  -w "$CONFIG_JSON" \
  -T "$APP_PATH" \
  >/dev/null 2>&1

if [[ $? -eq 0 ]]; then
  log "SUCCESS | stored single config item"
else
  log "ERROR | failed storing single config item"
  exit 1
fi

log "END | Keychain config stored successfully"
exit 0
