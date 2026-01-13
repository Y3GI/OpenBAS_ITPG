# Deployment Guide: Azure Windows Lab Environment

## 1. Overview

This automation package deploys a lab environment in **Microsoft Azure** consisting of two identical **Windows Server 2019** Virtual Machines:

* **BASVM1**
* **BASVM2**

The deployment automatically handles:

* **Infrastructure**: Resource Groups, Virtual Networks, Subnets, and Network Security Groups (NSGs)
* **Networking**: Public IP addresses and open ports for:

  * RDP (`3389`)
  * SMB (`445`)
* **Configuration**:

  * Creates a custom administrator account (**Admin2**)
  * Enables file-sharing firewall rules on both VMs automatically

---

## 2. Prerequisites

Before running the deployment, ensure your system has the following installed:

* **Ansible** (Core `2.11` or higher)
* **Azure CLI** (`az`)
* **Python**, including:

  * `azure-cli`
  * `ansible[azure]`

---

## 3. Configuration Guide

You must update the `azure_deploy_two_vms.yml` file with your specific Azure credentials before running the deployment.

### Step 1: Open the Playbook

Open the file in any text editor, such as:

* Notepad
* Visual Studio Code
* Nano

### Step 2: Update Azure IDs (Required)

Locate the `vars` section at the top of the file and replace the placeholders with your own Azure identifiers.

```yaml
vars:
  # Replace these values with your actual Azure IDs
  azure_tenant_id: "YOUR_TENANT_ID_GOES_HERE"
  azure_subscription_id: "YOUR_SUBSCRIPTION_ID_GOES_HERE"
```

**Tip:** You can retrieve your Azure IDs by running the following command in your terminal:

```bash
az account show --query "{tenant:tenantId, subscription:id}"
```

### Step 3: Set a Unique Random ID (Recommended)

To prevent naming conflicts with previous deployments, update the `random_id` variable for each new deployment.

```yaml
# Change this number for every fresh deployment (e.g., "101", "102")
random_id: "951"
```

### Step 4: Verify VM Size (Optional)

The playbook uses the VM size:

```
Standard_DC2s_v3
```

If your chosen Azure region does not support this size, you may change it to a more commonly available option, such as:

```
Standard_D2s_v3
```

---

## 4. Deployment Instructions

### Step 1: Log in to Azure

Authenticate your terminal with Azure by running:

```bash
az login
```

Complete the browser-based login process when prompted.

### Step 2: Run the Ansible Playbook

Execute the deployment using the following command:

```bash
ansible-playbook azure_deploy_two_vms.yml
```

### Step 3: Wait for Completion

* Deployment time: **3–5 minutes** (approximately)

**Success:**

* The public IP addresses for both VMs will be printed in the terminal output.

**Failure:**

* If you encounter a `PublicIPCountLimitReached` error, delete unused resource groups to free up your Azure quota.

---

## 5. Access Information

Once deployment is complete, you can immediately connect to both Virtual Machines.

* **Connection Method**: Remote Desktop Protocol (RDP)
* **IP Address**: Displayed in the terminal output (e.g., `20.10.x.x`)
* **Username**: `openbasadmin`
* **Password**: `FontysBas123!`

**Note:**
The script automatically creates an additional administrator account named **Admin2** with full administrative privileges. This account can be accessed from within the VM.

---

## 6. Cleanup (Crucial)

To avoid unnecessary costs and Azure subscription limits, delete the deployed resources when you are finished.

Run the following command, replacing `951` with the `random_id` value you used:

```bash
az group delete --name rg-openbas-win-951 --yes --no-wait
```

---

**End of Deployment Guide**
