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

5. Log into your OpenBAS server (localhost:8080) and import scenario [OpenBAS Adversary Emulation](https://github.com/Y3GI/OpenBAS_ITPG/blob/main/Generic%20Adversary%20Emulation%20-%20Assumed%20Breach_2026-01-11T15_06_24.407710056Z_(with_teams%20%26%20with_players%20%26%20with_variable_values).zip) into your OpenBAS server. 

6. From the imported scenario, choose injects and Modify Assets accordingly:

  a. Inject 1–2 → Computer A agent 

  b. Inject 3–5 → Computer B agent 

7. Execute simulation 
