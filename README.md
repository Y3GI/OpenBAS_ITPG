# OpenBAS Adversary Emulation

This project is an adversary emulation scenario for OpenBAS. It simulates a series of attacks that an adversary might perform in a real-world environment.

## Prerequisites

- A working OpenBAS server on a Linux machine.
- An Azure environment to host the 2 Windows machines required by the simulation.

## Installation Guide

Refer to [INSTALL.md](https://github.com/Y3GI/OpenBAS_ITPG/blob/main/INSTALL.md)

## Cyber Kill Chain Coverage

This simulation covers the following stages of the Cyber Kill Chain:

-   **Discovery:** Computer and SMB share discovery.
-   **Delivery:** Lateral movement using `wmic.exe`.
-   **Exploitation:** Dumping OS passwords (SAM, LSA, SECURITY).
-   **Installation:** Downloading a custom, PowerShell-based ransomware over HTTP filelessly.
-   **Actions on Objective:** Executing the downloaded ransomware to encrypt files.

## General User Advice

-   The provided ransomware is for simulation purposes only and encrypts bogus files.
-   When configuring the injects, double-check that you have assigned the correct assets and updated the IP address for Inject 2.

## Resources

- [OpenBAS Scenarios Hub](https://hub.filigran.io/cybersecurity-solutions/open-bas-scenarios)
- [Atomic Red Team](https://www.atomicredteam.io/atomic-red-team)
- [Center For Threat Informed Defense Adversary Emulation Library](https://github.com/center-for-threat-informed-defense/adversary_emulation_library)
