#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Specify task id" 1>&2
  exit 1
fi

source env.txt
TASKID=$1

# Login to CSP
RESULTS=$(curl -s -X POST -H "application/x-www-form-urlencoded" "https://console.cloud.vmware.com/csp/gateway/am/api/auth/api-tokens/authorize" -d "refresh_token=$REFRESH_TOKEN")

# Retrieve Access Token
CSP_ACCESS_TOKEN=$(echo $RESULTS | jq -r .access_token)

# Get connected_account_id

RESULTS=$(curl -s -X GET -H "application/x-www-form-urlencoded" -H "csp-auth-token: ${CSP_ACCESS_TOKEN}" "https://vmc.vmware.com/vmc/api/orgs/${ORGID}/account-link/connected-accounts")

ACCOUNT_ID=$(echo $RESULTS | jq -r ".[] | select( .account_number == \"${AWS_ACCOUNT_NUMBER}\" ) | .id")

# Get Task Status
RESULTS=$(curl -s -X GET -H "csp-auth-token: ${CSP_ACCESS_TOKEN}" "https://vmc.vmware.com/vmc/api/orgs/${ORGID}/tasks/${TASKID}")
TASK_TYPE=$(echo $RESULTS | jq -r .task_type)
TASK_STATUS=$(echo $RESULTS | jq -r .status)
PROGRESS=$(echo $RESULTS | jq -r .progress_percent)
TIMEREMAINS=$(echo $RESULTS | jq -r .estimated_remaining_minutes)
echo TaskType\: $TASK_TYPE, Status\: $TASK_STATUS, Progress\: $PROGRESS\%, TimeToComplete\: $TIMEREMAINS
