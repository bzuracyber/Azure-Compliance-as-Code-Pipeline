# Azure Compliance-as-Code with Terraform  

![Terraform](https://img.shields.io/badge/Terraform-Azure-blue?logo=terraform)  
![Azure](https://img.shields.io/badge/Microsoft-Azure-0089D6?logo=microsoftazure&logoColor=white)  
![IaC](https://img.shields.io/badge/IaC-Infrastructure%20as%20Code-green)  
![License](https://img.shields.io/badge/License-MIT-yellow)  

This repository provides **Terraform modules and Azure Policy definitions** to enforce cloud security best practices.  
Each configuration encodes compliance requirements so that misconfigurations are caught at deployment time.  

---

## 📑 Table of Contents

| File | Control | Why It Matters | Related CVE(s) |
|------|---------|----------------|----------------|
| `Secure-Storage-Account.tf` | Enforce HTTPS + TLS 1.2 + block public access | Prevents data exposure by ensuring storage is encrypted in transit and not publicly accessible. | [CVE-2019-0708](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-0708) (example TLS exploitation class), OWASP A6: Sensitive Data Exposure |
| `KeyVault-PurgeProtection-PrivateEndpoint.tf` | Require purge protection, soft delete, and private endpoints | Prevents accidental or malicious key deletion and enforces private connectivity. | [CVE-2021-42306](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-42306) (Azure Key Vault information disclosure) |
| `AzureSQL-TDE-PrivateAccess.tf` | Transparent Data Encryption (TDE), public access disabled, threat detection | Protects data at rest and reduces attack surface for SQL injection or brute force attacks. | [CVE-2012-2552](https://nvd.nist.gov/vuln/detail/CVE-2012-2552) (SQL Server privilege escalation), mitigates data exposure risks |
| `No-RDP-SSH-From-Internet.tf` | Deny RDP/SSH from Internet (only allow from admin CIDRs) | Prevents brute-force attacks and worms like BlueKeep from compromising VMs. | [CVE-2019-0708](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-0708) (BlueKeep RDP), [CVE-2016-10033](https://nvd.nist.gov/vuln/detail/CVE-2016-10033) (brute force SSH) |
| `Deny-Public-IP-On-NIC.tf` | Azure Policy to block NICs with public IPs | Eliminates shadow IT exposure to the Internet and reduces attack surface. | [CVE-2021-27065](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-27065) (Exchange exposed to Internet — misconfiguration risks) |
| `Require-PrivateEndpoints-Storage.tf` | Policy: Storage accounts must use private endpoints | Ensures all storage traffic stays inside trusted network boundaries. | [CVE-2020-0618](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2020-0618) (SQL RCE from exposed endpoints — demonstrates exposure risk) |
| `Require-Core-Tags.tf` | Policy Initiative requiring `Owner` and `Environment` tags | Improves accountability and governance, ties resources to owners. | Not CVE-specific (compliance / governance requirement) |
| `Azure-Policy-Assignment-ASB.tf` | Assigns Azure Security Benchmark initiative | Enforces a broad set of CIS/NIST-like controls automatically. | Broad coverage (multiple mitigations across CVEs & attack surfaces) |
| `Diagnostic-Settings-To-LAW.tf` | Forward logs/metrics to Log Analytics | Centralizes monitoring, enables detection of anomalous activity. | [CVE-2020-0601](https://nvd.nist.gov/vuln/detail/CVE-2020-0601) (CurveBall) — detection possible with good telemetry |

---
- **Storage & Encryption**: Misconfigured storage accounts are a top cloud breach vector (public blobs → data leaks). Enforcing HTTPS, TLS, and private endpoints reduces this risk.  
- **Key Vault Protection**: Purge protection stops attackers from deleting audit trails and keys during an incident.  
- **Azure SQL Security**: TDE + private access ensures databases remain confidential and available only from internal networks.  
- **Network Access Controls**: Blocking RDP/SSH from the Internet is critical to stop brute force and wormable exploits.  
- **Public Exposure Controls**: Denying public IPs and requiring private endpoints prevents accidental exposure.  
- **Governance Tags**: Helps compliance teams track resource ownership for audits and incident response.  
- **Security Benchmark**: Azure Security Benchmark is Microsoft’s CIS-like standard; assigning it covers 80%+ of baseline compliance needs.  
- **Centralized Logging**: Without logging, you can’t prove compliance or detect breaches. Sending logs to LAW enables SIEM integration.  
