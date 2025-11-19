# OpenBAS_ITPG

----

## Resources:
**Pre-built scenarios** that we can use in our simulations and as references for our custom scenarios.

- [XTM-Hub](https://hub.filigran.io/cybersecurity-solutions/open-bas-scenarios)

**Pre-made malware payloads** that we can use within our simulations and as references to create our custom payloads.

- [Atomic Red Teaming](https://www.atomicredteam.io/atomic-red-team)

**Adversary Emulation Library**

- [Center For Threat Informed Defense](https://github.com/center-for-threat-informed-defense/adversary_emulation_library)

----

## Notes

### Attacks included in the simulation diagram**

- [x] UAC bypass (common, bypass Windows restrictions using fodhelper.exe etc.)

- [x] running winpeas (common tool for enumerating vulnerable windows machines, defender should detect it)

- [x] download a (powershell based?) ransomware, encrypt some bogus files [source](https://youtu.be/LsUapxGAigE?si=8FFMYvI-EXpZ_jRf&t=864)

- [x] wmic.exe for lateral movement (common way to perform lateral movement)

- [x] kerberoasting (common, a way to get service account hashes that we can crack; no actual cracking though because we don't need to)

- [x] dump browser passwords (common, chrome recently added a security feature though, so not as reliable; can be bypassed)

- [x] SMB share discovery across every machine (common, passwords in SMB shares are still gold)

### Attacks implemented in OpenBAS

- [ ] placeholder

### Possible attacks to add into the simulation

- [ ] responder.py (common, llmnr/netbios poisoning, opens the path to relay and password cracking attacks)

- [ ] asrep-roasting (common, a way to get password hashes for accounts that have pre-auth disabled)

- [ ] delegation stuff (common, enumerate constrained, unconstrained, and resource based delegation)

- [ ] shadow creds (advanced, useful in many scenarios like webdav exploits, persistence, and a password change alternative)

- [ ] adcs stuff (less common, run things like certipy or certify, almost guarenteed that the target is vulnerable if they had a pentest/redteam)

- [ ] evil twin stuff (no real need, man in the middle attacks)

- [ ] updating script path object - genericall in bloodhound (advanced, a way to establish persistence or gain privesc)

- [ ] port forward with ssh (less common but important, port forwards and proxies are used by every competent threat actor, ssh port forwarding must not be allowed)

- [ ] download dpapi cred files (commonish, useful stuff for dumping browser secrets like cookies and passwords and decrypting some windows credentials)

- [ ] download malware like mimikatz, rubeus (common malware, windows def. should detect them immediately)

- [ ] load powershell malware directly into memory (common evasion technique)

- [ ] zip concatenation attacks with winrar to evade email scanners (niche technique for phishing, mainly here because I'm amazed by the concept)

- [ ] unpac-the-hash (a commonish way to get usable credentials from kerberos tgs)

- [ ] timeroasting (niche, really unlikely privesc vector)

- [ ] search for creds in file shares (common, almost every company leaks credentials in public smb shares)

- [ ] creating computer account (really common technique for exploiting many vulnerabilities, active directory allows users to add computer accoutns by default)

- [ ] password, hash sprays (common technique for testing valid passwords against a list of users to abuse password reuse)

- [ ] adding dns entries (niche, active directory allows users to add dns entries that can cause dns spoofing)

- [ ] scan for webdav clients (a technique advanced threat actors would use)

- [ ] disable AMSI (inc. in diagram) (common way to bypass powershell detection, should get caught by defender)

- [ ] change an application's run command (advanced attackers can easily modify the command that is used to run an executable to establish stealthy persistence and privesc)

- [ ] rubeus and kekeo's tgtdeleg (advancedish technique to get a valid kerberos tgt after getting command execution on a target without knowing a users password)

- [ ] ntlmrelay2self with rbcd technique (advanced technique, instant SYSTEM level access if webdav client is enabled, no fix available as far as I'm aware)

- [ ] run windows exploit suggester (common, scan the compromised host for CVEs - should get detected by windows defender)

- [ ] password spray over kerberos (use kerberos instead of smb or whatever else for stealth)

- [ ] prompt the user for password (common technique called local phishing, everyone falls for this attack, Cobalt Strike has a command called Askpassword)

- [ ] extract clipboard history for passwords etc. using Screenclip (advanced technique for stealthy password dump)

- [ ] extract notepad history for sensitive data (niche, I saw a john hammond video)

- [ ] general credential dump of the RunAs.exe or the RDP process (saw a Weekly Purple Team video)

- [ ] enumerate, brute force mssql. when successful xp_cmdshell/xp_dirtree and whatever else. xp_cmdshell generally pops alerts in SIEM, brute-forcing mssql does not [source](https://www.youtube.com/watch?v=eDnvZ1NIr_w) there are also the NETSPI articles
