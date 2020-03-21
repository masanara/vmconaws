#!/bin/bash

source env.txt

# Login to CSP
RESULTS=$(curl -s -X POST -H "application/x-www-form-urlencoded" "https://console.cloud.vmware.com/csp/gateway/am/api/auth/api-tokens/authorize" -d "refresh_token=$REFRESH_TOKEN")

# Retrieve Access Token
CSP_ACCESS_TOKEN=$(echo $RESULTS | jq -r .access_token)

# Get connected_account_id

RESULTS=$(curl -s -X GET -H "application/x-www-form-urlencoded" -H "csp-auth-token: ${CSP_ACCESS_TOKEN}" "https://vmc.vmware.com/vmc/api/orgs/${ORGID}/account-link/connected-accounts")

ACCOUNT_ID=$(echo $RESULTS | jq -r ".[] | select( .account_number == \"${AWS_ACCOUNT_NUMBER}\" ) | .id")

# Create SDDC params
BODY=$(cat << EOS
{
  "account_link_config": { "delay_account_link": false },
  "account_link_sddc_config": [ {
    "connected_account_id": "${ACCOUNT_ID}",
    "customer_subnet_ids": [ "${AWS_SUBNET_ID}" ]
  } ],
  "deployment_type": "SingleAZ",
  "name": "${SDDC_NAME}",
  "num_hosts": 1,
  "provider": "AWS",
  "region": "US_WEST_2",
  "sddc_template_id": null,
  "sddc_type": "1NODE",
  "skip_creating_vxlan": true,
  "vpc_cidr": "${MGMT_CIDR}"
}
EOS
)

#                     #
# *** Create SDDC *** #
#                     #
echo "Creating SDDC..."

RESULTS=$(echo $BODY | curl -s -X POST -H "Content-Type: application/json" -H "csp-auth-token: ${CSP_ACCESS_TOKEN}" "https://vmc.vmware.com/vmc/api/orgs/${ORGID}/sddcs" -d @-)

# Get Task ID
TASKID=$(echo $RESULTS | jq -r .id)
echo TaskId\:$TASKID

# Get Task Status
RESULTS=$(curl -s -X GET -H "csp-auth-token: ${CSP_ACCESS_TOKEN}" "https://vmc.vmware.com/vmc/api/orgs/${ORGID}/tasks/${TASKID}")
TASK_TYPE=$(echo $RESULTS | jq -r .task_type)
TASK_STATUS=$(echo $RESULTS | jq -r .status)
PROGRESS=$(echo $RESULTS | jq -r .progress_percent)
TIMEREMAINS=$(echo $RESULTS | jq -r .estimated_remaining_minutes)
echo TaskType\: $TASK_TYPE, Status\: $TASK_STATUS, Progress\: $PROGRESS\%, TimeToComplete\: $TIMEREMAINS
