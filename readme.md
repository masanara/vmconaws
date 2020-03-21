## VMware Cloud on AWS SDDC scripts

Scripts for provisioning VMware Cloud on AWS SDDC.

- [VMware Cloud on AWS API](https://code.vmware.com/apis/920/vmware-cloud-on-aws)

### Usage

#### Create configuration file(env.txt).

```txt
REFRESH_TOKEN=<API Token for VMware Cloud Service>
ORGID=<VMware Cloud Service Organization ID>
AWS_ACCOUNT_NUMBER=<AWS Account ID>
AWS_SUBNET_ID=<AWS Subnet ID>
SDDC_NAME=<SDDC Name>
MGMT_CIDR=10.2.0.0/16
FW_SRCS='"123.123.123.123", "111.111.111.111", "222.222.222.222"'
```

```bash
$ ls -l
total 56
-rwxr-xr-x  1 masanara  staff  1904  3 20 15:04 create_sddch.sh
-rwxr-xr-x  1 masanara  staff  1690  3 20 15:04 delete_sddc.sh
-rw-r--r--  1 masanara  staff   302  3 20 15:04 env.txt
-rwxr-xr-x  1 masanara  staff   882  3 20 15:04 get_credential.sh
-rwxr-xr-x  1 masanara  staff  1618  3 20 15:04 get_status.sh
-rwxr-xr-x  1 masanara  staff  2078  3 20 15:04 openfw.sh
-rw-r--r--@ 1 masanara  staff  2005  3 20 15:04 readme.md
```

#### Provision SDDC

Provision SDDC with following parameters.

```json
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
```

```bash
$ ./create_sddch.sh
Creating SDDC...
TaskId: 61fba93c-c667-4abc-81c7-c66c2118793a
TaskType: SDDC-PROVISION, Status: STARTED, Progress: 1%, TimeToComplete: 121
```

#### Check provisioning task status

```bash
$ ./get_status.sh 61fba93c-c667-4abc-81c7-c66c2118793a
TaskType: SDDC-PROVISION, Status: STARTED, Progress: 1%, TimeToComplete: 120

$ ./get_status.sh 61fba93c-c667-4abc-81c7-c66c2118793a
TaskType: SDDC-PROVISION, Status: STARTED, Progress: 21%, TimeToComplete: 95

$ ./get_status.sh 61fba93c-c667-4abc-81c7-c66c2118793a
TaskType: SDDC-PROVISION, Status: STARTED, Progress: 68%, TimeToComplete: 38

$ ./get_status.sh 61fba93c-c667-4abc-81c7-c66c2118793a
TaskType: SDDC-PROVISION, Status: STARTED, Progress: 91%, TimeToComplete: 10

$ ./get_status.sh 61fba93c-c667-4abc-81c7-c66c2118793a
TaskType: SDDC-PROVISION, Status: FINISHED, Progress: 100%, TimeToComplete: 0
```

#### Open Gateway Firewall

Configure managemet gateway firewall from ${FW_SRCS} to vCenter.

```bash
$ ./openfw.sh
Creating MGMT group...
Creating management firewall policy...
```

#### Get SDDC Credentail

```bash
$ ./get_credentail.sh
https://vcenter.sddc-xxx-xxx-xxx-xxx.vmwarevmc.com/
cloudadmin@vmc.local
xxxxxxxxxxxxxxxxx
```

#### Delete SDDC

```bash
$ ./delete_sddc.sh
Deleting SDDC...
TaskId:357a8099-3c21-4477-adac-b3f9b19e3ca9
TaskType: SDDC-DELETE, Status: STARTED, Progress: 0%, TimeToComplete: -1
```

#### Deletion task status 

```bash
$ ./get_status.sh 357a8099-3c21-4477-adac-b3f9b19e3ca9
TaskType: SDDC-DELETE, Status: STARTED, Progress: 0%, TimeToComplete: -1

$ ./get_status.sh 357a8099-3c21-4477-adac-b3f9b19e3ca9
TaskType: SDDC-DELETE, Status: FINISHED, Progress: 100%, TimeToComplete: 0
```

