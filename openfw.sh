#!/bin/bash

source env.txt

# Login to CSP
RESULTS=$(curl -s -X POST -H "application/x-www-form-urlencoded" "https://console.cloud.vmware.com/csp/gateway/am/api/auth/api-tokens/authorize" -d "refresh_token=$REFRESH_TOKEN")

# Retrieve Access Token
CSP_ACCESS_TOKEN=$(echo $RESULTS | jq -r .access_token)

# Get SDDCs
RESULTS=$(curl -s -X GET -H "csp-auth-token: ${CSP_ACCESS_TOKEN}" "https://vmc.vmware.com/vmc/api/orgs/${ORGID}/sddcs")

# Get NSX Policy API URL
NSX_API=$(echo $RESULTS | tr -d '[:cntrl:]' | jq -r ".[] | select( .name == \"${SDDC_NAME}\" ) | .resource_config.nsx_api_public_endpoint_url")


# Create Group for management firewall policy
BODY=$(cat << EOS
{
  "resource_type": "Group",
  "id": "MGMT",
  "display_name": "MGMT",
  "path": "/infra/domains/mgw/groups/MGMT",
  "parent_path": "/infra/domains/mgw",
  "relative_path": "MGMT",
  "marked_for_delete": false,
  "expression": [
    {
      "resource_type": "IPAddressExpression",
      "marked_for_delete": false,
      "ip_addresses": [ ${FW_SRCS} ]
    }
  ]
}
EOS
)

echo "Creating MGMT group..."
RESULTS=$(echo ${BODY} | curl -s -X PUT -d @- -H "Content-type: application/json" -H "csp-auth-token: ${CSP_ACCESS_TOKEN}" $NSX_API/policy/api/v1/infra/domains/mgw/groups/MGMT)


# Create Rule for management firewall policy
BODY=$(cat << EOS
{
  "resource_type": "Rule",
  "id": "MGMT-ACCESS",
  "display_name": "MGMT-ACCESS",
  "path": "/infra/domains/mgw/gateway-policies/default/rules/MGMT-ACCESS",
  "parent_path": "/infra/domains/mgw/gateway-policies/default",
  "relative_path": "MGMT-ACCESS",
  "marked_for_delete": false,
  "sequence_number": 0,
  "source_groups": [
    "/infra/domains/mgw/groups/MGMT"
  ],
  "logged": false,
  "destination_groups": [
    "/infra/domains/mgw/groups/VCENTER"
  ],
  "scope": [
    "/infra/labels/mgw"
  ],
  "action": "ALLOW",
  "services": [
    "/infra/services/HTTPS"
  ]
}
EOS
)

echo "Creating management firewall policy..."
RESULTS=$(echo ${BODY} | curl -s -X PUT -d @- -H "Content-type: application/json" -H "csp-auth-token: ${CSP_ACCESS_TOKEN}" $NSX_API/policy/api/v1/infra/domains/mgw/gateway-policies/default/rules/MGMT-ACCESS)
