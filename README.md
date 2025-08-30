# 🚀 Azure Compliance-as-Code with Terraform  

![Terraform](https://img.shields.io/badge/Terraform-Azure-blue?logo=terraform)  
![Azure](https://img.shields.io/badge/Microsoft-Azure-0089D6?logo=microsoftazure&logoColor=white)  
![IaC](https://img.shields.io/badge/IaC-Infrastructure%20as%20Code-green)  
![License](https://img.shields.io/badge/License-MIT-yellow)  

This repository contains **Terraform modules and Azure Policy definitions** to enforce security and compliance baselines in Microsoft Azure.  
All examples follow Infrastructure-as-Code (IaC) principles and can be integrated into CI/CD pipelines for **continuous compliance**.  

---

## 📂 Repository Structure  

### 🔒 Storage & Encryption
- **`Secure-Storage-Account.hcl`**  
  Creates a storage account with:  
  - HTTPS-only traffic  
  - TLS 1.2 minimum  
  - Block public access  

- **`KeyVault-PurgeProtection-PrivateEndpoint.hcl`**  
  Ensures Key Vaults have purge protection, soft-delete, and private endpoint access only.  

- **`AzureSQL-TDE-PrivateAccess.hcl`**  
  Deploys an Azure SQL Server + Database with:  
  - Transparent Data Encryption (TDE) enabled  
  - Public network disabled  
  - Threat detection enabled  

---

### 🌐 Networking & Access Controls
- **`No-RDP-SSH-From-Internet.hcl`**  
  NSG rules that **deny inbound RDP/SSH from the Internet** and only allow access from approved admin CIDRs.  

- **`Deny-Public-IP-On-NIC.hcl`**  
  Azure Policy that blocks NICs from being assigned public IPs.  

- **`Require-PrivateEndpoints-Storage.hcl`**  
  Custom Policy enforcing that all Storage Accounts must use private endpoints.  

---

### 🏷️ Governance & Tagging
- **`Require-Core-Tags.hcl`**  
  Policy Initiative that denies deployments missing required tags (`Owner`, `Environment`).  

- **`Azure-Policy-Assignment-ASB.hcl`**  
  Assigns the built-in **Azure Security Benchmark** initiative to a resource group or subscription.  

---

### 📊 Logging & Monitoring
- **`Diagnostic-Settings-To-LAW.hcl`**  
  Configures diagnostic settings for Storage Accounts (and other resources) to send logs and metrics to a centralized Log Analytics Workspace.  

---

## 🚀 Usage  

1. Initialize Terraform:
   ```bash
   terraform init
