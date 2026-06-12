

    ███╗   ██╗████████╗██╗ ██████╗     ██████╗███████╗███╗   ██╗████████╗███████╗██████╗ 
    ████╗  ██║╚══██╔══╝██║██╔════╝    ██╔════╝██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
    ██╔██╗ ██║   ██║   ██║██║         ██║     █████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝
    ██║╚██╗██║   ██║   ██║██║         ██║     ██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
    ██║ ╚████║   ██║   ██║╚██████╗    ╚██████╗███████╗██║ ╚████║   ██║   ███████╗██║  ██║
    ╚═╝  ╚═══╝   ╚═╝   ╚═╝ ╚═════╝     ╚═════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
    

# 🌍 Infrastructure Hybride Multi-Cloud NTIC CENTER

[![Terraform](https://img.shields.io/badge/Terraform-1.15.5-844FBA?logo=terraform)](https://terraform.io)
[![Ansible](https://img.shields.io/badge/Ansible-10.7.0-EE0000?logo=ansible)](https://ansible.com)
[![AWS](https://img.shields.io/badge/AWS-eu--west--1-FF9900?logo=amazonaws)](https://aws.amazon.com)
[![Azure](https://img.shields.io/badge/Azure-swedencentral-0078D4?logo=microsoftazure)](https://azure.microsoft.com)
[![VMware](https://img.shields.io/badge/VMware-vSphere%208-607078?logo=vmware)](https://vmware.com)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?logo=ubuntu)](https://ubuntu.com)

---

## 📖 À propos du projet

Ce dépôt constitue l'**œuvre maîtresse d'ingénierie** d'un Mastère Expert en Réseaux, Infrastructures et Sécurité (ERIS). Il démontre la maîtrise des pratiques d'**Infrastructure as Code (IaC)** et de **gestion de configuration** à travers le déploiement d'une infrastructure hybride hétérogène pour le compte du client fictif **NTIC CENTER CORPORATION**.

| Implantation | Rôle Technique | Contrainte Majeure |
|--------------|----------------|--------------------|
| **Paris (Siège)** | Serveurs internes, AD, Intranet | Souveraineté, latence, on-premise legacy |
| **Abidjan (Agence)** | Site web client, API, Base de données | Exposition Internet, scalabilité élastique |
| **Supervision Globale** | Monitoring Zabbix, Alerting, Observabilité | Centralisation inter-plateformes |

**Philosophie d'ingénierie appliquée :**
- **Cattle not Pets** : Machines virtuelles jetables et recréables à l'identique (`terraform apply` + `ansible-playbook`).
- **État distant et verrouillé** via Terraform Cloud (collaboration multi-ingénieur, historique des versions).
- **Abstraction de la configuration** : Une seule clé SSH pour trois clouds, un seul playbook Ansible pour trois OS hétérogènes.
- **Pragmatisme Hybride** : Architecture `split-state` assumée pour vCenter local (non exposé sur Internet), contournée par exécution locale dédiée.

---

## 🏛️ Architecture Technique

graph TD
    Paris["🏢 Paris (On-Premise)<br/>VM web-paris<br/>1 vCPU / 1 Go RAM<br/>IP: 192.168.1.17"]
    AWS["☁️ Abidjan (AWS eu-west-1)<br/>EC2 web-abidjan t3.micro<br/>IP: 3.252.52.40 (Nginx)<br/>RDS MySQL db.t3.micro"]
    Azure["📊 Supervision (Azure swedencentral)<br/>VM zabbix-monitor Standard_D2s_v3<br/>IP: 4.223.71.179 (Zabbix)"]
    TFC["Terraform Cloud<br/>État centralisé (AWS+Azure)"]
    Local["État local (vSphere)"]
    Ansible["Ansible<br/>Playbook Nginx"]
    SSH["SSH (même clé partout)"]

    TFC --> AWS
    TFC --> Azure
    Local --> Paris
    Ansible --> SSH
    SSH --> Paris
    SSH --> AWS
    SSH --> Azure

    classDef aws fill:#ff9900,stroke:#232f3e,color:white;
    classDef azure fill:#0078d4,stroke:#00188f,color:white;
    classDef onprem fill:#607078,stroke:#39424a,color:white;
    classDef tool fill:#844fba,stroke:#4a148c,color:white;

    class AWS aws;
    class Azure azure;
    class Paris onprem;
    class TFC,Local,Ansible,SSH tool;

### Tableau de synthèse des environnements

| Composant | 📍 Paris (On-Premise) | ☁️ Abidjan (AWS) | 📊 Supervision (Azure) |
|---|---|---|---|
| **Provider** | VMware vSphere 8 | AWS (`eu-west-1`) | Azure (`swedencentral`) |
| **Ressources** | VM `web-paris` (1 vCPU, 1 Go RAM, clone cloud-init) | VPC `10.0.0.0/16`, 2 subnets publics, IGW, Route Table, EC2 `t3.micro` + RDS MySQL `t3.micro` | RG `RG-Monitoring`, VNet `10.1.0.0/16`, NSG, VM `Standard_D2s_v3` |
| **Stockage** | Datastore unique, disque thin-provisioned 20 Go | EBS (chiffrement plateforme) + RDS 20 Go (gp2) | Disque OS Standard_LRS |
| **Accès** | `guestinfo` cloud-init (clé SSH injectée) | `aws_key_pair` (même clé publique que Paris) | `admin_ssh_key` (même clé) |
| **Configuration** | Ansible (Nginx) via SSH | Ansible via SSH (après Elastic IP recommandée) | Ansible via SSH (port 22, tunnel local si EDR) |
| **État Terraform** | Local (`terraform.tfstate`) — exécution manuelle depuis poste réseau | Distant (Terraform Cloud, workspace `infra-hybride`) | Distant (Terraform Cloud) |

**Flux applicatifs (HTTP/80) :**
- **Paris** : Non exposé (Intranet)
- **Abidjan** : Exposé via IP publique (Security Group autorise `0.0.0.0/0`)
- **Supervision** : Par défaut bloqué par NSG (à ouvrir via règle dédiée, voir Recommandations de durcissement)

---

## 📁 Arborescence du dépôt

```
ntic-center-infra/
├── .gitignore                     # Ignore terraform.tfvars, .terraform/
├── README.md                      # Ce document
├── DAT_NTIC_CENTER_CORPORATION.md # Document d'Architecture Technique détaillé (Soutenance)
│
├── main.tf                        # Orchestration des 3 modules (vsphere-vm, aws-ec2, azure-monitoring)
├── providers.tf                   # Providers et versions épinglées (vsphere 2.6.1, aws 5.0.0, azurerm 3.88.0)
├── variables.tf                   # Variables globales (dont sensibles : db_password, vsphere_password)
├── outputs.tf                     # Sorties publiques (ip_abidjan, ip_zabbix, ip_paris commentée)
├── backend.tf                     # Configuration backend distant Terraform Cloud (organisation ntic-center-corp)
├── terraform.tfvars               # ⚠️ Secrets en clair — NE PAS COMMITER (rotation recommandée)
│
├── modules/                       # Modules Terraform réutilisables par provider
│   ├── aws-ec2/                   # VPC multi-AZ + EC2 (Nginx) + RDS MySQL (db.t3.micro)
│   ├── azure-monitoring/          # Resource Group, VNet, NSG, VM Zabbix (Standard_D2s_v3)
│   └── vsphere-vm/                # Module VMware : clone depuis template, cloud-init via guestinfo
│
├── ansible/                       # Configuration applicative post-déploiement
│   ├── inventory.ini              # Inventaire statique (hôtes paris, abidjan, monitoring)
│   └── site.yml                   # Playbook : install Nginx + page personnalisée (Jinja2)
│
└── docs/                          # Captures d'écran pour README et DAT
    ├── architecture.png
    ├── vcenter_web_paris.png
    ├── aws_console_ec2.png
    ├── azure_vm_zabbix.png
    └── nginx_page_abidjan.png
```

---

## ⚙️ Fonctionnalités & Ingénierie avancée

<details>
<summary><strong>🔐 Authentification unique cross-cloud (même clé SSH partout)</strong></summary>

Le projet uniformise l'authentification SSH sur **trois clouds radicalement différents** :

- **vSphere** : Injection de la clé publique dans `guestinfo.userdata` via cloud-init.
- **AWS** : Ressource `aws_key_pair` liée à l'EC2 par `key_name`.
- **Azure** : Bloc `admin_ssh_key` dans la ressource `azurerm_linux_virtual_machine`.

➡️ L'opérateur Ansible utilise une **même clé privée** (`~/.ssh/id_rsa`) pour les trois hôtes, malgré l'hétérogénéité des mécanismes d'injection.

</details>

<details>
<summary><strong>🏗️ Split-State Architecture (vSphere local vs Cloud distant)</strong></summary>

Le vCenter de Paris (`vcenter.ntic-paris.local`) est **inaccessible depuis Terraform Cloud** (réseau privé on-premise).  
Pour contourner cette limite, le projet implémente une **architecture d'état hybride** :

- **Modules AWS/Azure** : État distant centralisé dans le workspace `infra-hybride` de Terraform Cloud.
- **Module vSphere** : État local (`terraform.tfstate`) exécuté depuis un poste disposant d'un accès réseau au vCenter.

Cette stratégie, documentée dans le DAT, reflète une **contrainte réelle d'ingénierie multi-cloud** et sa solution pragmatique.

</details>

<details>
<summary><strong>🔄 Immutabilité des EC2 et gestion dynamique des IP (Cattle vs Pets)</strong></summary>

L'ajout de la paire de clés SSH sur l'EC2 `web-abidjan` a provoqué un **remplacement forcé** de l'instance (`-/+ destroy and create replacement`).  
L'instance recréée a reçu une **nouvelle IP publique** (car `map_public_ip_on_launch = true`, sans Elastic IP).  
L'inventaire Ansible référençait l'ancienne IP → échec de connexion SSH.

**Solution documentée** :
- Immédiate : mise à jour manuelle de `inventory.ini` après `terraform output ip_abidjan`.
- Structurelle : ajouter une ressource `aws_eip` + `aws_eip_association` pour rendre l'IP stable (recommandation #9 du DAT).

➡️ Cet incident illustre concrètement le **principe "Cattle not Pets"** et l'importance d'une conception d'adressage résiliente.

</details>

<details>
<summary><strong>🌐 Contournement de restrictions réseau (tunnel SSH pour Azure)</strong></summary>

Lorsque la VM `zabbix-monitor` (Azure) se trouve derrière un **filtrage EDR/XDR ou un NAT asymétrique**, l'accès direct à l'interface web Nginx (port 80) peut être impossible depuis Internet.  
**Workaround ingénierie** :

```bash
ssh -L 8080:localhost:80 ansible@4.223.71.179 -i ~/.ssh/id_rsa
```

Un tunnel SSH local (`-L 8080`) redirige le trafic depuis `localhost:8080` vers `zabbix-monitor:80`.  
L'interface web devient accessible via `http://localhost:8080`.

> Cette technique est documentée dans le DAT comme solution de contournement temporaire dans les environnements de laboratoire fortement contraints.

</details>

---

## 🚀 Prérequis et Déploiement (Quick Start)

### 1. Cloner le dépôt et initialiser les sous-modules

```bash
git clone https://github.com/ntic-center-corp/ntic-center-infra.git
cd ntic-center-infra
```

### 2. Installer les outils (CLI)

- **Terraform** (>= 1.5) : [Download](https://developer.hashicorp.com/terraform/downloads)
- **Ansible** (>= 9.0) : via WSL (Windows) ou `pip install ansible`
- **AWS CLI**, **Azure CLI**, **PowerCLI** (optionnel, pour debug)

### 3. Configurer les secrets et variables

Créez un fichier `terraform.tfvars` (non versionné) à la racine :

```hcl
# Identifiants vSphere (Paris)
vsphere_server   = "192.168.1.51"
vsphere_user     = "administrator@vsphere.local"
vsphere_password = "VOTRE_MOT_DE_PASSE"

# Identifiants AWS (Abidjan)
aws_region       = "eu-west-1"
aws_access_key   = "AKIA..."  # (ou variables d'environnement AWS_ACCESS_KEY_ID)
aws_secret_key   = "..."

# Identifiants Azure (Supervision)
azure_location   = "swedencentral"
db_password      = "NticDB2024x!"  # Mot de passe RDS MySQL
```

> ⚠️ Ne **jamais commiter** `terraform.tfvars`. Ajoutez-le à votre `.gitignore`.

### 4. Déployer l'infrastructure AWS + Azure (depuis Terraform Cloud)

```bash
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve
```

Les sorties `ip_abidjan` et `ip_zabbix` seront affichées.

### 5. Déployer la VM vSphere Paris (exécution locale)

```bash
cd modules/vsphere-vm
terraform init
terraform apply -var-file="../../terraform.tfvars" -auto-approve
cd ../..
```

> L'état de `web-paris` est stocké localement. Cette VM n'est **pas** supervisée par Terraform Cloud.

### 6. Mettre à jour l'inventaire Ansible

Copiez les IP récupérées dans `ansible/inventory.ini` :

```ini
[paris]
web_paris ansible_host=192.168.1.17 ansible_user=ubuntu

[abidjan]
web_abidjan ansible_host=3.252.52.40 ansible_user=ubuntu

[monitoring]
zabbix_server ansible_host=4.223.71.179 ansible_user=ansible

[all:vars]
ansible_ssh_private_key_file = ~/.ssh/id_rsa
ansible_ssh_common_args = '-o StrictHostKeyChecking=no'
```

### 7. Configurer les serveurs avec Ansible

```bash
cd ansible
ansible-playbook -i inventory.ini site.yml
```

Le playbook :
- Met à jour le cache `apt`
- Installe Nginx
- Crée une page `index.html` personnalisée (avec `inventory_hostname` via Jinja2)
- Active et démarre Nginx

### 8. Valider le déploiement

- **Abidjan** : `curl http://3.252.52.40` → "Site web-abidjan"
- **Paris (réseau interne)** : `curl http://192.168.1.17` → "Site web-paris"
- **Supervision** : Tunnel SSH + `curl http://localhost:8080` → "Site zabbix-monitor"

---

## ✅ Validation et Recette

| Test | Commande / Action | Résultat attendu | Preuve |
|---|---|---|---|
| Connexion SSH Ansible | `ansible all -i inventory.ini -m ping` | `pong` sur les 3 hôtes | `[Insérer la capture d'écran : ping Ansible multi-cloud]` |
| Playbook Ansible | `ansible-playbook -i inventory.ini site.yml` | `failed=0` | `[Insérer la capture d'écran : sortie playbook]` |
| Page Nginx Abidjan | Navigateur → `http://3.252.52.40` | Page "Site web-abidjan" | `[Insérer la capture d'écran : Déploiement de la page web Nginx d'Abidjan]` |
| Page Nginx Paris | Navigateur (réseau interne) → `http://192.168.1.17` | Page "Site web-paris" | `[Insérer la capture d'écran : Déploiement de la page web Nginx Paris]` |
| Accès RDS | `mysql -h <RDS endpoint> -u admin -p nticdb` | Connexion établie | `[Insérer la capture d'écran : Dashboard de l'infrastructure sur AWS (EC2 + RDS)]` |
| Idempotence Terraform | `terraform plan -var-file=terraform.tfvars` | "No changes" | `[Insérer la capture d'écran : terraform plan idempotent]` |

---

## 👤 Auteur & Licence

**Mainteneur** : Steeve WOMO, Ingénieur Expert ERIS — NTIC CENTER CORPORATION (fictif)  
**Contact professionnel** : `womo.steeven@gmail.com`

**Licence** : Ce projet est fourni à des fins pédagogiques et de démonstration technique. Toute utilisation commerciale est soumise à autorisation préalable.

---

<p align="center">
  <i>« L'infrastructure comme code n'est pas une option — c'est la nouvelle norme de résilience et de gouvernance. »</i>
</p>

