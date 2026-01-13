Deployment Guide: Azure Windows Lab Environment
1. Overview
This automation package deploys a lab environment in Microsoft Azure consisting of two identical Windows Server 2019 Virtual Machines (BASVM1 and BASVM2).

The deployment automatically handles:

Infrastructure: Resource Groups, Virtual Networks, Subnets, and Security Groups.

Networking: Public IPs and open ports for RDP (3389) and SMB (445).

Configuration: Creates a custom administrator account (Admin2) and enables file sharing firewall rules on both VMs automatically.

2. Prerequisites
Before running the deployment, ensure your system has the following installed:

Ansible (Core 2.11 or higher)

Azure CLI (az)

Python (with azure-cli and ansible[azure] libraries)

3. Configuration Guide
You must update the azure_deploy_two_vms.yml file with your specific Azure credentials before running it.

Step 1: Open the Playbook
Open the file in any text editor (Notepad, VS Code, or Nano).

Step 2: Update IDs (Required)
Locate the vars section at the top of the file. Replace the placeholders with your unique Azure IDs.

YAML

vars:
Replace these values with your actual Azure IDs
  azure_tenant_id: "YOUR_TENANT_ID_GOES_HERE"
  azure_subscription_id: "YOUR_SUBSCRIPTION_ID_GOES_HERE"
Tip: You can find your IDs by running this command in your terminal: az account show --query "{tenant:tenantId, subscription:id}"

Step 3: Set a Unique Random ID (Recommended)
To prevent naming conflicts with previous deployments, change the random_id variable to a unique number for every new deployment.

YAML

  # Change this number for every fresh deployment (e.g., "101", "102")
  random_id: "951"
Step 4: Verify VM Size (Optional)
The script is configured for Standard_DC2s_v3. If you are deploying in a region that does not support this size, change it to a generic size like Standard_D2s_v3.

4. Deployment Instructions
1. Login to Azure
Authenticate your terminal with Azure. Run the following command and complete the browser login process:

Bash

az login
2. Run the Playbook
Execute the Ansible playbook using the command below:

Bash

ansible-playbook azure_deploy_two_vms.yml
3. Wait for Completion
The process typically takes 3 to 5 minutes.

Success: The script will output the Public IP addresses for both VMs at the end.

Failure: If the script fails due to "PublicIPCountLimitReached", you must delete old resource groups to free up your quota.

5. Access Information
Once deployed, you can log in to both Virtual Machines immediately.

Connection Method: Remote Desktop Protocol (RDP)

IP Address: Printed in the terminal output (e.g., 20.10.x.x)

Username: openbasadmin

Password: FontysBas123!

Note:The script automatically created Admin2 for you with full administrative privileges. You can access it from the VM.

6. Cleanup (Crucial)
To avoid unnecessary costs or hitting subscription limits, delete the environment as soon as you are finished.

Run the following command (replacing 951 with the ID you used in the script):

Bash

az group delete --name rg-openbas-win-951 --yes --no-wait
