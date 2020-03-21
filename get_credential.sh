#!/bin/bash

source env.txt

# Login to CSP
RESULTS=$(curl -s -X POST -H "application/x-www-form-urlencoded" "https://console.cloud.vmware.com/csp/gateway/am/api/auth/api-tokens/authorize" -d "refresh_token=$REFRESH_TOKEN")

# Retrieve Access Token
CSP_ACCESS_TOKEN=$(echo $RESULTS | jq -r .access_token)

# Get SDDCs
RESULTS=$(curl -s -X GET -H "csp-auth-token: ${CSP_ACCESS_TOKEN}" "https://vmc.vmware.com/vmc/api/orgs/${ORGID}/sddcs")

# Get SDDC info
VC_URL=$(echo  $RESULTS | tr -d '[:cntrl:]' | jq -r ".[] | select( .name == \"${SDDC_NAME}\" ) | .resource_config.vc_url")
VC_USER=$(echo $RESULTS | tr -d '[:cntrl:]' | jq -r ".[] | select( .name == \"${SDDC_NAME}\" ) | .resource_config.cloud_username")
VC_PASS=$(echo $RESULTS | tr -d '[:cntrl:]' | jq -r ".[] | select( .name == \"${SDDC_NAME}\" ) | .resource_config.cloud_password")

echo $VC_URL
echo $VC_USER
echo $VC_PASS
