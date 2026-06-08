# 🏗️ NTIC CENTER CORPORATION — Infrastructure Hybride Terraform

![Terraform](https://img.shields.io/badge/Terraform-v1.15-purple)
![AWS](https://img.shields.io/badge/AWS-eu--west--1-orange)
![Azure](https://img.shields.io/badge/Azure-francecentral-blue)
![VMware](https://img.shields.io/badge/VMware-vSphere%208-green)

## 📋 Description

Infrastructure hybride multi-cloud complète déployée avec Terraform Cloud, intégrant :
- **VMware vSphere 8** (Paris) — VMs internes AD et Web
- **AWS** (Abidjan) — EC2 Nginx + RDS MySQL Free Tier
- **Azure** (Supervision) — VM Zabbix + stockage
- **Ansible** — Post-configuration automatisée

## 🏛️ Architecture
[Terraform Cloud]
│
├── [VMware vSphere — Paris]
│     ├── Paris-DC / Paris-Cluster
│     ├── VM: AD_DNS (Active Directory + DNS)
│     └── VM: web-paris (Intranet)
│
├── [AWS eu-west-1 — Abidjan]
│     ├── VPC: 10.0.0.0/16
│     ├── EC2: web-abidjan (Nginx) t2.micro
│     └── RDS: db-abidjan (MySQL) db.t3.micro
│
└── [Azure francecentral — Supervision]
├── RG: RG-Monitoring
└── VM: zabbix-monitor Standard_B1s

## 📁 Structure du projet
ntic-center-infra/
├── main.tf                    # Orchestration des modules
├── providers.tf               # Providers AWS, Azure, vSphere
├── variables.tf               # Variables globales
├── outputs.tf                 # Sorties IPs
├── backend.tf                 # Terraform Cloud backend
├── modules/
│   ├── vsphere-vm/            # Module VMware Paris
│   ├── aws-ec2/               # Module AWS Abidjan
│   └── azure-monitoring/      # Module Azure Supervision
└── ansible/
├── inventory.ini          # Inventaire dynamique
└── site.yml               # Playbook Nginx

## 🚀 Déploiement

### Prérequis
- Terraform CLI >= 1.15
- Compte Terraform Cloud (org: ntic-center-corp)
- Accès AWS, Azure, vSphere

### Commandes
```bash
terraform init
terraform plan
terraform apply
```

### Post-déploiement Ansible
```bash
ansible-playbook -i ansible/inventory.ini ansible/site.yml
```

## 🔒 Sécurité
- Aucun secret dans le code — variables sensibles dans Terraform Cloud
- Authentification SSH par clé publique
- SSL/TLS sur tous les endpoints

## 👤 Auteur
**Yemah** — Mastère Expert Réseaux, Infrastructures et Sécurité  
NTIC CENTER CORPORATION — Projet de Synthèse Bloc 11