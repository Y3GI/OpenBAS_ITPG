# INSTALLATION GUIDE

Note: This installation assumes you already have a working OpenBAS server on a Linux machine.

1. Run the Azure setup script to install the 2 Windows machines required by the simulation into your Azure environment.

2. Log into the computer that runs OpenBAS and download [webserver_for_hosting_malware](https://github.com/Y3GI/OpenBAS_ITPG/blob/main/webserver_for_hosting_malware.zip).

3. After step 2, find the downloaded zip and run the following commands to execute the webserver required by the simulation.

```bash
$ unzip ./webserver_for_hosting_malware.zip  
$ cd ./webserver_for_hosting_malware.zip
$ sudo ./init.sh
$ netstat -nltp  # you should see port 8443 open for 0.0.0.0
```

4. Log into both Computer A and B with the credentials “Administrator:Passw0rd!” and install the agents by running the [agent_install.ps1](https://github.com/Y3GI/OpenBAS_ITPG/blob/main/agent_install.ps1) script. Make sure you follow the instructions in the script. 

```text
Usage:
powershell -ep bypass /c .\agent_install.ps1 openbas_base_url openbas_username openbas_password

Note:
`$openbas_base_url must have the same value as in OpenBAS's .env file (OPENBAS_BASE_URL) without a back slash at the end.
If this is a `$openbas_base_url contains a DNS name, make sure this computer can resolve it.

Example:
powershell -ep bypass /c .\agent_install.ps1 http://172.16.2.3:8080 test@test.com Test_Pass123
```

5. Log into your OpenBAS server (localhost:8080) and import scenario [OpenBAS Adversary Emulation](https://github.com/Y3GI/OpenBAS_ITPG/blob/main/Generic%20Adversary%20Emulation%20-%20Assumed%20Breach_2026-01-11T15_06_24.407710056Z_(with_teams%20%26%20with_players%20%26%20with_variable_values).zip) into your OpenBAS server. 

6. From the imported scenario, choose injects and Modify Assets accordingly:

    a. Inject 1–2 → Computer A

    b. Inject 3–5 → Computer B

    Note: Inject 2 (Delivery with WMI) requires you to set the "node" parameter to the IP of Computer B in your environment yourself. By default, it is set to 192.168.2.4 which was the IP address of Computer B in our     environment. This is the only parameter that requires its the default value to be changed.

8. Execute simulation 
