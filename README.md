# DevOps---JFKZ
  
# 1) Présentation générale  
Dans le cadre de l’unité d’enseignement DevOps du **Master 2 Réseaux et Télécommunications**, ce projet a pour objectif de mettre en œuvre une infrastructure complète intégrant les notions fondamentales de **conteneurisation**, **orchestration** et **automatisation de la configuration**. Ces concepts constituent aujourd’hui des piliers incontournables des architectures modernes utilisées en entreprise, notamment dans les environnements de production à forte exigence de disponibilité, de scalabilité et de sécurité.

L’évolution des systèmes d’information vers des architectures distribuées, dynamiques et fortement automatisées a profondément modifié les pratiques d’exploitation. Les approches traditionnelles, basées sur des configurations manuelles et spécifiques à chaque serveur, montrent rapidement leurs limites face à la complexité croissante des infrastructures. Dans ce contexte, les démarches **DevOps** visent à rapprocher les équipes de développement et d’exploitation autour de processus automatisés, reproductibles et contrôlés, réduisant les erreurs humaines et accélérant les cycles de mise en production.

L’objectif principal de ce projet est donc de **concevoir et déployer une infrastructure système réaliste**, inspirée des bonnes pratiques observées en milieu professionnel. Cette infrastructure doit permettre :
- le provisionnement automatique des ressources systèmes,
- la configuration homogène des machines,
- le déploiement applicatif conteneurisé,
- et la montée en charge dynamique des services en fonction de la demande.

Pour répondre à ces enjeux, le projet s’appuie sur une chaîne d’outils représentative des stacks DevOps modernes. Terraform (ou OpenTofu) est utilisé pour le provisionnement de l’infrastructure virtuelle, Ansible pour l’automatisation de la configuration des systèmes, Podman pour la conteneurisation, et Kubernetes pour l’orchestration et la gestion du cycle de vie applicatif. Cette combinaison permet de couvrir l’ensemble du cycle, depuis la création des machines virtuelles jusqu’à l’exploitation d’une application scalable en production.

Au-delà de la simple mise en œuvre technique, ce projet vise également à **comprendre les principes sous-jacents** à ces outils : pourquoi ils sont utilisés, quels problèmes ils résolvent, et comment ils s’articulent entre eux. L’approche retenue privilégie une infrastructure déclarative, reproductible et documentée, capable d’être redéployée intégralement sans intervention manuelle, conformément aux exigences actuelles des environnements professionnels.

![Maquette](https://github.com/egoMasa/DevOps-JFKZ/blob/main/images/Maquette.png)

# 2) Cahier des charges  
  Le cahier des charges du projet définit les briques techniques nécessaires à la construction de l’infrastructure cible. Chaque composant a été choisi afin de répondre à un besoin précis tout en respectant une logique de cohérence globale et d’alignement avec les pratiques industrielles.

| Domaine                            | Outil / Technologie   | Rôle dans le projet                                              |
| ---------------------------------- | --------------------- | ---------------------------------------------------------------- |
| Hyperviseur                        | Proxmox               | Hébergement des machines virtuelles constituant l’infrastructure |
| Infrastructure as Code             | Terraform / OpenTofu  | Provisionnement automatisé des ressources (VM, réseau, stockage) |
| Moteur de conteneurisation         | Podman                | Exécution sécurisée des conteneurs applicatifs                   |
| Automatisation de la configuration | Ansible               | Configuration et orchestration des machines et services          |
| Orchestration de conteneurs        | Kubernetes            | Déploiement, exposition et montée en charge des applications     |
| Service applicatif                 | Wiki.js (prioritaire) | Application métier déployée sur le cluster                       |

Initialement, plusieurs services applicatifs ont été envisagés (Nextcloud, GLPI). Toutefois, au cours du projet, **Wiki.js** a été retenu comme application principale. Ce choix s’explique par plusieurs facteurs :
- une architecture représentative d’une application web moderne,
- une dépendance à une base de données externe,
- une documentation officielle orientée Kubernetes,
- et des contraintes réelles en matière de déploiement, d’initialisation et de scalabilité.

Wiki.js constitue ainsi un cas d’étude pertinent pour illustrer les problématiques de déploiement applicatif sur un cluster Kubernetes, notamment en ce qui concerne la phase d’initialisation contrôlée, l’exposition via Ingress et la montée en charge automatisée.

# Structure du projet
```
.
├── ansible
│   ├── 1-deploy-k8s-master.yaml
│   ├── 2-deploy-k8s-workers.yaml
│   ├── 3-deploy-db-postgres.yaml
│   ├── 4-deploy-metallb.yaml
│   ├── 5-deploy-ingress-nginx.yaml
│   ├── 6-deploy-metrics-server.yaml
│   ├── 7-deploy-wikijs-init.yaml
│   ├── 8-deploy-wikijs-scale.yaml
│   ├── artifacts
│   │   └── join-workers.sh
│   ├── cis_ubuntu24_audit.yml
│   ├── inventory.ini
│   ├── inventory.template.ini
│   ├── reports
│   │   ├── tf-k8s-master
│   │   │   └── cis_audit_result_03_01_2026_18h08.txt
│   │   ├── tf-k8s-node-1
│   │   │   └── cis_audit_result_03_01_2026_18h08.txt
│   │   └── tf-k8s-node-2
│   │       └── cis_audit_result_03_01_2026_18h08.txt
│   ├── roles
│   │   ├── ubuntu24_cis
│   │   └── ubuntu24_cis_audit
│   ├── terraform.tfstate
│   └── ubuntu24_hardening_nv1.yml
├── k8s
│   ├── 00-metallb
│   │   └── metallb-config.yaml
│   ├── 01-ingress-nginx
│   │   └── kustomization.yaml
│   └── 02-wikijs
│       └── values-wikijs.yaml
├── Maquette.drawio
├── README.md
└── terraform
    ├── inventory.tftpl
    ├── main.tf
    ├── outputs.tf
    ├── terraform.tfstate
    ├── terraform.tfvars
    ├── variables.tf
    └── versions.tf
```

--- 

# Worflow finale à suivre pour déployer le lab
```
cd /devops/terraform/
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate terraform.tfstate.backup
rm -rf .terraform .terraform.lock.hcl
terraform init
terraform plan
terraform apply

---

ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.150'
ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.151'
ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.152'
ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.153'

---

cd /devops/ansible/
ansible-playbook -i inventory.ini 1-deploy-k8s-master.yaml
ansible-playbook -i inventory.ini 2-deploy-k8s-workers.yaml
ansible-playbook -i inventory.ini 3-deploy-db-postgres.yaml
ansible-playbook -i inventory.ini 4-deploy-metallb.yaml
ansible-playbook -i inventory.ini 5-deploy-ingress-nginx.yaml
ansible-playbook -i inventory.ini 6-deploy-metrics-server.yaml
ansible-playbook -i inventory.ini 7-deploy-wikijs-init.yaml

- EMAIL : test@gmail.com
- Password : azerty123
- URL : http://wikijs.lab
  
ansible-playbook -i inventory.ini 8-deploy-wikijs-scale.yaml

--- Vérifications 
ssh ansible@192.168.122.150
kubectl get nodes,pods,svc,ingress,ep,pvc,hpa -A
```

# Partie 1 : Hyperviseur Proxmox
## 1.1) Notion d'hyperviseur
Dans toute architecture informatique moderne, la virtualisation constitue un **socle technique fondamental**. Elle permet de découpler les ressources matérielles physiques (CPU, mémoire, stockage, réseau) des systèmes d’exploitation et des services qui les exploitent. Cette abstraction est rendue possible grâce à un composant clé : **l’hyperviseur**.

Un hyperviseur est une couche logicielle chargée de créer, exécuter et isoler plusieurs **machines virtuelles (VM)** sur un même serveur physique. Chaque machine virtuelle dispose de son propre système d’exploitation, de ses ressources allouées et de son environnement d’exécution, tout en partageant le matériel sous-jacent avec d’autres VM.

Cette approche présente plusieurs avantages majeurs dans un contexte professionnel :
- **Optimisation des ressources matérielles**, en évitant la sous-utilisation des serveurs physiques,
- **Isolation forte** entre les environnements (sécurité, stabilité),
- **Flexibilité opérationnelle**, avec la possibilité de créer, détruire ou migrer des VM dynamiquement,
- **Reproductibilité**, essentielle dans les démarches DevOps et Infrastructure as Code.
    
### **Hyperviseurs de type 1 et type 2**

On distingue classiquement deux grandes familles d’hyperviseurs, selon leur mode d’intégration au système hôte.

Les **hyperviseurs de type 2**, dits _hosted_, s’exécutent au-dessus d’un système d’exploitation classique (Windows, Linux, macOS). Ils sont généralement utilisés dans des contextes de développement ou de test. Des solutions comme VirtualBox ou VMware Workstation en sont des exemples. Bien que simples à mettre en œuvre, ces hyperviseurs introduisent une couche supplémentaire qui dégrade les performances et limite les usages en production.

À l’inverse, les **hyperviseurs de type 1**, dits _bare-metal_, s’exécutent directement sur le matériel physique, sans système d’exploitation intermédiaire. L’hyperviseur devient lui-même le système central de la machine. Cette architecture permet :
- de réduire la latence et les surcoûts liés à la virtualisation,
- d’améliorer les performances globales,
- d’offrir un niveau d’isolation et de fiabilité adapté aux environnements de production.

Dans les infrastructures professionnelles (datacenters, clouds privés, plateformes d’hébergement), **les hyperviseurs de type 1 sont la norme**.

### **Pourquoi Proxmox dans ce projet**

Dans le cadre de ce laboratoire, le choix s’est porté sur **Proxmox VE**, un hyperviseur de type 1 open source, basé sur le noyau Linux et s’appuyant sur les technologies KVM (virtualisation matérielle) et LXC (conteneurs système).

Plusieurs raisons motivent ce choix.

Tout d’abord, Proxmox offre une **approche open source et souveraine** de la virtualisation. Contrairement à certaines solutions propriétaires, il permet de mettre en place une infrastructure complète sans dépendance à un modèle de licence contraignant. Ce point est particulièrement pertinent dans un contexte académique et professionnel, où les coûts et les évolutions de licences peuvent devenir un facteur bloquant.

Ensuite, Proxmox propose une **intégration native des briques essentielles** d’une plateforme de virtualisation moderne :
- gestion avancée des machines virtuelles,
- gestion du stockage (local, réseau, volumes),
- administration réseau (bridges, VLAN),
- snapshots, sauvegardes et migrations à chaud.

Enfin, le choix de Proxmox s’inscrit dans une logique de **réalisme industriel**. Les évolutions récentes des modèles économiques de certains acteurs historiques de la virtualisation, notamment VMware, ont mis en lumière les limites des solutions propriétaires à long terme. De nombreuses organisations se tournent aujourd’hui vers des alternatives open source afin de reprendre le contrôle de leur infrastructure et de réduire les coûts opérationnels.

### **Rôle de l’hyperviseur dans l’architecture du projet**

Dans ce projet, Proxmox constitue la **couche fondationnelle** de l’infrastructure. Il héberge l’ensemble des machines virtuelles nécessaires au laboratoire :
- le nœud maître Kubernetes,
- les nœuds workers Kubernetes,
- la machine dédiée à la base de données PostgreSQL.

L’hyperviseur n’intervient pas dans l’orchestration applicative ni dans la gestion des conteneurs, mais il fournit un environnement stable, isolé et reproductible sur lequel s’appuient les couches supérieures (Ansible, Kubernetes, Helm).

Cette séparation claire des responsabilités reflète une architecture conforme aux bonnes pratiques :
- **Proxmox** : gestion des ressources physiques et des VM,
- **Ansible** : automatisation de la configuration des systèmes,
- **Kubernetes** : orchestration des conteneurs et des services applicatifs.    

Ainsi, l’hyperviseur joue un rôle déterminant dans la cohérence globale du projet, en garantissant une base robuste, performante et alignée avec les pratiques professionnelles actuelles.
## 1.2) Installation de proxmox
Afin de mettre en place un hyperviseur, nous utilisons un PC basé sur Linux Mint sur lequel nous allons utilisé QEMU+KVM (capot) via Virt Manager (interface) pour déployer une VM Hyperviseur dans lequel sera hébergé tout le lab. 

Lien Proxmox VE 9.1 ISO : https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso
1. Installation de QEMU KVM et virt manager
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install qemu-system virt-manager
```
2. Lancer `Gestionnaire de machines virtuelles`
3. Fichier > Créer une nouvelle machine virtuelle > Média d'installation local (ISO) 
	1. Média d'installation : proxmox.iso
	2. Système d'exploitation installer : Debian 13
	3. Mémoire : 8128
	4. CPU : 6
	5. Image disque : 150 GiB
	6. Nom : Proxmox
	7. Réseau : NAT 
4. Suivre l'installation jusqu'au reboot de la VM
5. Se rendre sur l'interface web de proxmox : https://IP:8006

Option	Value
Filesystem:	ext4
Disk(s):	/dev/vda
Country:	France
Timezone:	Europe/Paris
Keymap:	fr
Email:	jeremyfournier203@gmail.com
Management Interface:	nic0
Hostname:	proxmox
IP CIDR:	192.168.122.108/24
Gateway:	192.168.122.1
DNS:	192.168.122.1

Maintenant nous avons installé proprement Proxmox sur un VM dédié et nous allons par la suite configuré proprement, ajouter des composants manquants et mettre en place le lab.

## 1.3) Configuration du routage et des accès SSH
* Sur promox activer le routage pour permettre au poste d'administration d'accéder au VMs
```bash
echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf
sysctl -p
```
* Sur le poste configure une route statique vers le réseau proxmox
```bash
sudo nmcli con modify "virbr0" +ipv4.routes "192.168.122.0/24 192.168.122.108"
sudo nmcli con down "virbr0"
sudo nmcli con up "virbr0"
```
## 1.4) Création d'une VM template dupliquable (golden)

### 1.4.1) Choix de l'OS golden image
La prochaine étape consiste à sélectionner l'OS qui servira de socle à nos machines virtuelles. Pour un cluster Kubernetes, l'OS hôte doit répondre à trois exigences critiques : la gestion des **cgroups** (via systemd), la compatibilité avec la **glibc** (bibliothèque C standard) et un support mature de **Cloud-Init** pour l'automatisation via Terraform.

Pour effectuer ce choix, plusieurs écoles s'affrontent :
- **L'ultra-légèreté (Alpine Linux) :** Alpine est la référence pour les images de conteneurs grâce à sa taille dérisoire (5-10 Mo). Cependant, son utilisation comme **OS hôte** pour Kubernetes est risquée. Son architecture basée sur `musl libc` (au lieu de `glibc`) et l'absence de `systemd` posent des problèmes de compatibilité majeurs avec les binaires officiels de `kubelet` et certains plugins réseau (CNI). Le gain de légèreté ne justifie pas la complexité de maintenance engendrée.
- **L'ultra-compatibilité (Ubuntu Server ISO) :** C'est le choix de la sécurité. Ubuntu bénéficie du support le plus vaste de la communauté Kubernetes. Toutefois, l'installation via une image ISO classique est inadaptée à notre workflow automatisé : elle est lourde, inclut des services inutiles (snaps, outils de diagnostic) et le processus d'installation manuel est chronophage.
- **L'approche "Cloud-Native" (Images Cloud / Minimal) :** Des distributions comme Debian, Rocky Linux ou Ubuntu Cloud-Image proposent des versions "nues", pré-configurées pour être déployées de façon éphémère et automatisée.

|Caractéristiques|Alpine Linux|Debian 12 (Cloud)|Ubuntu 24.04 (Minimal Cloud)|Rocky Linux 9|
|---|---|---|---|---|
|**Poids (Image)**|~10 Mo|~300 Mo|~350 Mo|~600 Mo|
|**Init System**|OpenRC|Systemd|Systemd|Systemd|
|**Bibliothèque C**|musl libc|glibc|glibc|glibc|
|**Support K8s**|Faible (Expérimental)|Excellent|**Natif / Standard**|Très bon (Enterprise)|
|**Cloud-Init**|Partiel|Natif|**Natif (Optimisé)**|Natif|
|**Vitesse Boot**|Instantanée|Rapide|Rapide|Modérée|
Nous avons délibérément choisi l'utilisation d'une **Cloud Image officielle (.img)**. Ce choix repose sur deux piliers fondamentaux de la philosophie DevOps :
- **Valorisation de l'Infrastructure as Code (IaC) :** En partant d'une image vierge, nous déplaçons toute l'intelligence de la configuration vers nos **playbooks Ansible**. Si nous utilisions une image pré-configurée (où Podman ou K8s seraient déjà installés), la valeur ajoutée de l'automatisation serait masquée. Ici, le code Ansible devient la seule "source de vérité", capable de transformer n'importe quelle instance nue en un nœud de production sécurisé.
- **Lutte contre le "Configuration Drift" :** Les images personnalisées manuellement ont tendance à devenir des "boîtes noires" dont on perd la trace des modifications. L'utilisation d'une image Cloud standard garantit une **reproductibilité totale** : pour mettre à jour le système ou modifier un paramètre de sécurité, il suffit de mettre à jour le playbook Ansible et de redéployer, assurant ainsi une infrastructure saine et immuable.

Notre choix s'est porté sur **Ubuntu 24.04 LTS (Noble Numbat) en version "Minimal Cloud Image"**. C’est le compromis parfait entre légèreté logicielle (suppression des paquets inutiles), stabilité du noyau Linux pour Kubernetes et interopérabilité native avec les modules Cloud-Init de Proxmox.

* ***Fichier retenu :** `ubuntu-24.04-minimal-cloudimg-amd64.img`
* Lien : https://cloud-images.ubuntu.com/minimal/releases/noble/release/

### 1.4.2) Principe de gestion des clés SSH (approche production)
Dans un environnement professionnel, on distingue **deux types de clés SSH** :
🔑 **Clé de build (temporaire)**  
Utilisée uniquement pour :
  - accéder à la VM lors de sa phase de construction (premier boot)
  - appliquer le hardening CIS via Ansible
  - Supprimer avant la mise en template

🔐 **Clé runtime (production)**  
Injectée dynamiquement lors du déploiement final par Terraform.
* Permet d'exécuter des playbook ansible d'installation,configuration, administration
* Clef permanente qui est le seul moyen de connexion aux VM (aucun mot de passe)

⚠️ **Aucune clé SSH de production ne doit être figée dans un template.**  
Pour rappel, la VM template est complètement vidé avant sa transformation en template afin de n'avoir aucune clef résiduelle, c'est à Terraform de gérer lors du déploiement, l'injection des clefs ssh sur les utilisateurs auquel on doit se connecter, ici `ansible` est le seul utilisateur sur lequel on pourra se connecter, uniquement via clef ssh. 

Le workflow est donc le suivant :
1. Injection d’une **clé SSH temporaire** via Cloud-Init
2. Démarrage unique de la VM
3. Application du hardening CIS avec Ansible
4. Suppression de la clé de build et nettoyage Cloud-Init
5. Transformation de la VM en template
6. Injection de la clé SSH définitive par Terraform lors du clonage

### 1.4.3) Configuration hyperviseur
Plutôt que d'installer un OS à la main, nous créons une **machine "moule"**. Nous prenons un disque dur virtuel déjà installé par Ubuntu (le fichier `.img`), nous le glissons dans une enveloppe matérielle virtuelle (la VM), et nous ajoutons un "cerveau de configuration" (**Cloud-Init**). Une fois figée en **Template**, cette VM ne démarrera plus jamais, mais servira de source pour cloner les 3 VMs en quelques secondes.

1. Activer le stockage des snippets Cloud-Init
```bash
pvesm set local --content images,rootdir,iso,vztmpl,backup,snippets
mkdir -p /var/lib/vz/snippets
```
2. Création du fichier Cloud-Init de base
```bash
cd /var/lib/vz/snippets
echo "" > /var/lib/vz/snippets/ubuntu-template-build.yaml
nano /var/lib/vz/snippets/ubuntu-template-build.yaml
```

```yaml
#cloud-config
# ==========================================================
# Cloud-Init – Phase BUILD uniquement (Proxmox Cloud-Init)
# ----------------------------------------------------------
# Objectif :
# - Fournir un accès SSH TEMPORAIRE pour la phase de build
# - Permettre l’automatisation (Ansible, SSH, provisioning)
# - Installer les composants nécessaires à Proxmox
#
# Important :
# - L’utilisateur créé ici est SUPPRIMÉ avant la conversion
#   de la VM en template
# - La clé SSH associée est également temporaire
# ==========================================================

# ==========================================================
# Création d’un utilisateur temporaire de provisioning
# ==========================================================
users:
  - name: proxmoxinit                     # Utilisateur dédié au build (non persistant)
    shell: /bin/bash                      # Shell standard pour compatibilité scripts
    sudo: ALL=(ALL) NOPASSWD:ALL          # Sudo sans mot de passe (automatisation)
    ssh_authorized_keys:
      # Clé SSH TEMPORAIRE utilisée uniquement pour :
      # - le provisioning
      # - le hardening
      # - la préparation du template
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8iPlirgXN/0JSS/qVpiO+1coIQp866Akv5Ix8G10XR maison

# ==========================================================
# Sécurisation de l’accès SSH
# ==========================================================

disable_root: true        # Désactive toute connexion directe en root (CIS / best practice)
ssh_pwauth: false         # Désactive l’authentification par mot de passe (clé SSH uniquement)

# ==========================================================
# Gestion des mises à jour lors du premier boot
# ==========================================================

package_update: true      # Mise à jour de l’index APT (apt update)
package_upgrade: false    # Pas de upgrade automatique (maîtrise des versions)

# ==========================================================
# Paquets requis pour Proxmox
# ==========================================================

packages:
  - qemu-guest-agent      # Agent Proxmox :
                           # - remontée IP / hostname
                           # - shutdown propre
                           # - meilleure intégration hyperviseur

# ==========================================================
# Commandes exécutées à la fin du cloud-init
# ==========================================================

runcmd:
  # Activation de l’agent Proxmox au démarrage
  - systemctl enable qemu-guest-agent

  # Démarrage immédiat de l’agent sans reboot
  - systemctl start qemu-guest-agent

```
5. Téléchargement de l’image Ubuntu Cloud
```bash
cd /tmp
wget https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img
```
6. Création de la VM template Proxmox
```bash
qm create 9000 --name ubuntu-2404-template \
  --memory 2048 --cores 2 \
  --cpu host \
  --ostype l26 \
  --net0 virtio,bridge=vmbr0
```
7. Import du disque cloud
```bash
qm importdisk 9000 ubuntu-24.04-minimal-cloudimg-amd64.img local-lvm
```
8. Attachement Cloud-Init et options système
```bash
qm set 9000 \
  --scsihw virtio-scsi-pci \
  --scsi0 local-lvm:vm-9000-disk-0 \
  --ide2 local-lvm:cloudinit \
  --boot order=scsi0 \
  --serial0 socket \
  --vga serial0 \
  --ipconfig0 ip=192.168.122.50/24,gw=192.168.122.1 \
  --nameserver 1.1.1.1 \
  --agent enabled=1 \
  --cicustom "user=local:snippets/ubuntu-template-build.yaml"
```
9. Extension du disque
```
qm disk resize 9000 scsi0 +18G
```
10. Démarrage unique de la VM pour exécution initiale de cloud-init
```bash
qm start 9000
```
### 1.4.4) Configuration VM template
* Se connecter en SSH sur la VM template 
```bash
ssh proxmoxinit@192.168.122.50
```
8. Générer les clefs SSH hôtes pour éviter l'alerte MITM 
```bash
sudo ssh-keygen -A
```
9. Nettoyage de la VM avant transformation en template
```bash
sudo systemd-run --unit=template-cleanup --collect /bin/bash -c '
pkill -u proxmoxinit || true
sleep 2
userdel -r proxmoxinit || true
cloud-init clean --logs --seed
rm -rf /var/lib/cloud/*
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
shutdown -h now
'
```
9. Arreter et transformer la VM en template
```bash
qm set 9000 --delete cicustom
qm template 9000
```
> ⚠️ **Ne jamais transformer une VM en template si elle est en cours d’exécution**

La VM template est maintenant :
- ✅ Cloud-Init ready
- ✅ Sécurisée (SSH clé-only)
- ✅ Sans état applicatif
- ✅ Optimisée pour le clonage
- ✅ Compatible Terraform / API / GUI

Lors du déploiement des VMs finales, **Terraform injectera dynamiquement**
les clés SSH de production via Cloud-Init, garantissant :
- séparation build / runtime
- rotation simple des clés
- conformité aux bonnes pratiques de sécurité
# Partie 2 : Infra-as-code Terraform

## 2.1) Outils d'infra-as-code (Terraform vs OpenTofu)
Dans le paradigme DevOps moderne, le déploiement manuel d'infrastructures est considéré comme une **dette technique majeure**. L'instabilité générée par l'erreur humaine, le "configuration drift" (dérive de configuration) et le manque de reproductibilité constituent des risques opérationnels critiques. L'approche **Infrastructure-as-Code (IaC)** répond à ces problématiques en traitant la définition du matériel et du réseau avec la même rigueur que le code applicatif.

### 2.1.1) Les piliers théoriques de l'IaC
L'adoption d'un outil comme Terraform ou OpenTofu repose sur trois concepts fondamentaux que nous avons intégrés à ce projet :
- **L'Idempotence :** C'est la capacité de l'outil à exécuter le même script plusieurs fois en garantissant un résultat identique, sans créer de doublons ou d'erreurs. Si l'infrastructure cible correspond déjà à la définition du code, l'outil n'entreprend aucune action.
- **L'Approche Déclarative :** Contrairement aux scripts impératifs (Bash, Python) où l'on décrit _comment_ faire (étapes par étapes), nous utilisons ici un langage déclaratif pour décrire _ce que nous voulons_ (l'état final). L'outil se charge de calculer la différence entre l'existant et la cible.
- **La Gestion d'État (State Management) :** C'est la "mémoire" de l'infrastructure. Terraform conserve un fichier (`.tfstate`) qui sert de source de vérité unique, permettant de mapper les ressources réelles sur l'hyperviseur Proxmox avec les définitions logiques du code.

### 2.1.2) Le langage HCL (HashiCorp Configuration Language)
L'IaC dans ce projet repose sur le **HCL**. Bien que Terraform puisse interpréter du JSON, le HCL est privilégié car il offre un équilibre parfait entre lisibilité humaine et puissance programmatique. Il permet d'introduire de la logique (boucles `for_each`, structures conditionnelles, variables dynamiques) là où un format purement séquentiel échouerait à gérer la complexité d'un cluster Kubernetes.

### 2.1.3) Étude comparative : La scission Terraform / OpenTofu
Le choix de l'orchestrateur est aujourd'hui marqué par une séparation nette au sein de l'écosystème open-source :
1. **Terraform (HashiCorp) :** Leader historique et industriel. Son écosystème de "providers" est le plus vaste au monde. Cependant, en août 2023, HashiCorp a fait passer la licence du projet de **MPL** (Mozilla Public License) à la **BUSL** (Business Source License). Ce changement restreint l'usage commercial du code source par des concurrents, transformant Terraform en un produit "source-available" plutôt qu'en un logiciel libre au sens strict.
2. **OpenTofu (Linux Foundation) :** En réaction à ce changement de licence, la communauté et de grandes entreprises (Gruntwork, Spacelift, Harness) ont créé un "fork" sous l'égide de la Linux Foundation. OpenTofu est un moteur d'IaC 100% open-source, dirigé par la communauté, qui garantit la neutralité du projet à long terme.

### 2.1.4) Synthèse et stratégie retenue
Le tableau suivant résume les critères ayant influencé notre choix pour ce projet :

| Critère           | Terraform (v1.x)         | OpenTofu (v1.x)                              |
| ----------------- | ------------------------ | -------------------------------------------- |
| **Gouvernance**   | Privée (HashiCorp)       | Communautaire (Linux Foundation)             |
| **Licence**       | Semi-propriétaire (BUSL) | Open-Source (Apache 2.0)                     |
| **Écosystème**    | Standard du marché       | Entièrement compatible (Drop-in replacement) |
| **Documentation** | Omniprésente et éprouvée | Excellente mais plus récente                 |

## 2.2) Solution d'infra-as-code Terraform
Terraform n'agit pas simplement comme un script de création, mais comme un **gestionnaire d'état** et un **orchestrateur de ressources**. Son rôle est de traduire nos besoins métier (ex: "un cluster Kubernetes de 3 nœuds") en appels API compréhensibles par l'hyperviseur Proxmox.

### 2.2.1) Provisionnement vs Configuration : La Séparation des Responsabilités
Une confusion classique en ingénierie DevOps consiste à mélanger le rôle de Terraform avec celui d'Ansible. Pour garantir une infrastructure saine, nous appliquons ici le principe de **Séparation des Préoccupations (Separation of Concerns)** :
- **Terraform (Provisioning) :** Il s'occupe de la couche "basse". Il interagit avec l'hyperviseur pour réserver les ressources physiques (CPU, RAM, Disque, NIC). Il livre une machine "nue" mais accessible via le réseau.
- **Ansible (Configuration Management) :** Il s'occupe de la couche "haute". Une fois la machine provisionnée par Terraform, Ansible intervient pour installer les packages, configurer les services (Docker, Kubeadm) et durcir la sécurité de l'OS.

### 2.2.2) Décomposition des Composants de Configuration
Pour que nos machines virtuelles soient optimisées pour un usage intensif (type cluster Kubernetes), chaque paramètre hardware défini dans nos fichiers `.tf` a été choisi avec précision :
- **Ressources de calcul (Compute) :** Nous définissons le nombre de _vCPUs_ et de _sockets_. L'utilisation du type de processeur `host` est ici critique : elle permet à la machine virtuelle de voir et d'utiliser les instructions spécifiques du processeur physique (AES-NI pour le chiffrement, VT-x pour la virtualisation), optimisant ainsi les performances de calcul.
- **Gestion de la Mémoire (RAM) :** Au-delà de la simple allocation (ex: 2048 Mo), Terraform permet de gérer le **Memory Ballooning**. Cette technologie permet à l'hyperviseur de récupérer dynamiquement la mémoire inutilisée par une VM pour la redistribuer à d'autres, optimisant ainsi la densité du serveur Proxmox.
- **Sous-système de Stockage (Storage) :** Nous utilisons l'interface **VirtIO SCSI**. C'est le standard de performance pour les environnements virtualisés Linux, offrant des débits supérieurs et une gestion fine des files d'attente d'E/S (IO Queues). Le choix du _datastore_ (ex: `local-lvm`) définit la persistance et la redondance des données.
- **Topologie Réseau (Networking) :** Les VMs sont rattachées à un pont virtuel (`vmbr0`), agissant comme un commutateur (switch) logiciel. Nous utilisons le modèle de carte réseau `virtio` pour minimiser l'overhead CPU lors des transferts de paquets réseau, ce qui est indispensable pour la communication inter-nœuds d'un cluster.

### 2.2.3) Cloud-Init : Le pont entre Hardware et Software
Le composant le plus stratégique de notre configuration Terraform est le bloc **Cloud-Init**. Sans lui, la VM créée reste une "boîte noire" inaccessible. Cloud-init permet d'injecter des métadonnées dès le premier démarrage :
1. **Bootstrapping Réseau :** Configuration de l'IP statique et de la passerelle (Gateway) pour assurer la connectivité immédiate.
2. **Authentification :** Injection de clés publiques SSH, rendant tout mot de passe obsolète et sécurisant l'accès dès la première seconde.
3. **Personnalisation OS :** Création de l'utilisateur système `ansible` et mise à jour des dépôts.

### 2.2.4) Le Cycle de Vie d'une Ressource
Terraform gère ce que l'on appelle le **Resource Graph**. Il comprend les dépendances entre les objets (ex: ne pas configurer le réseau tant que la VM n'est pas créée). Ce cycle se décompose en quatre phases :

| Phase       | Action Technique                             | Résultat                                                 |
| ----------- | -------------------------------------------- | -------------------------------------------------------- |
| **Refresh** | Lecture de l'état actuel sur Proxmox.        | Synchronisation du fichier `.tfstate`.                   |
| **Plan**    | Comparaison entre le code HCL et la réalité. | Génération d'un différentiel (calcul des modifications). |
| **Apply**   | Appels API vers Proxmox (POST/PUT).          | Création ou modification des VMs.                        |
| **Destroy** | Suppression propre des ressources (DELETE).  | Libération des ressources de l'hyperviseur.              |

## 2.3) Choix du provider terraform proxmox : telmate vs bpg
Le **Provider** constitue la couche d'abstraction logicielle indispensable à Terraform. Son rôle est de traduire les ressources définies en HCL en appels de méthodes de l'API REST de Proxmox VE. Dans le cadre de ce projet, le choix du provider n'est pas une simple préférence syntaxique, mais une décision stratégique impactant la stabilité du cycle de vie de nos machines virtuelles.

### 2.3.1) Provider Telmate (`telmate/proxmox`)
Historiquement, le provider Telmate a été le pionnier de l'IaC pour Proxmox. Cependant, l'évolution technologique de l'hyperviseur (notamment depuis Proxmox 8.x et l'actuelle 9.x) a mis en exergue des limites structurelles :
- **Dette Technique et API Legacy :** Telmate repose sur des bibliothèques de communication vieillissantes qui peinent à interpréter les nouvelles réponses JSON de l'API Proxmox. Cela se traduit souvent par des erreurs de "parsing" lors du déploiement.
- **Le Problème du "State Drift" (Dérive d'état) :** L'une des faiblesses majeures de Telmate réside dans sa gestion des chaînes de caractères pour Cloud-Init (ex: le paramètre `ipconfig0`). Terraform n'étant pas capable de valider structurellement ces chaînes, il détecte fréquemment des changements fictifs entre le code et la réalité, forçant des recréations de VMs non souhaitées.
- **Manque de Granularité :** La définition des ressources (disques, réseaux) est souvent globale et peu flexible, rendant difficile la gestion de configurations complexes comme le multi-disque ou les interfaces réseau avancées.

### 2.3.2) Le Provider BPG (`bpg/proxmox`)
Le provider **BPG** (en version **0.90.0** pour ce projet) représente une rupture technologique. Il a été conçu avec une approche "Cloud-Native" pour offrir une parité quasi totale avec les fonctionnalités de l'interface graphique de Proxmox.
- **Architecture Typée et Schémas HCL2 :** Contrairement à son prédécesseur, BPG utilise des blocs de configuration fortement typés. Au lieu de passer des arguments sous forme de texte brut, nous définissons des objets (blocs `disk`, `network_device`, `initialization`). Cela permet à Terraform de valider la syntaxe et la logique des ressources localement avant d'envoyer la moindre requête à l'hyperviseur.
- **Gestion Native de Cloud-Init :** BPG traite Cloud-Init comme une entité structurée. Il gère intelligemment la génération du lecteur CD-ROM Cloud-Init et l'injection des données (utilisateurs, clés SSH, réseaux), garantissant que la VM est configurée correctement dès le premier "boot" sans intervention manuelle.
- **Contrôle fin du Cycle de Vie :** Il permet des opérations de maintenance avancées, comme le redimensionnement de disques à chaud ou la modification de la mémoire sans interruption de service, là où d'autres providers imposeraient un redémarrage.

### 2.3.3) Synthèse Technique et Comparaison
Le tableau ci-dessous expose les différentiels techniques observés lors de nos tests comparatifs :

| Caractéristique               | Telmate (Legacy)                       | BPG (Moderne / Retenu)                      |
| ----------------------------- | -------------------------------------- | ------------------------------------------- |
| **Compatibilité Proxmox 8/9** | Instable (Bugs d'API fréquents)        | Native (Optimisée pour le SDK Go)           |
| **Logique de Configuration**  | Orientée "Attributs" (Strings)         | Orientée "Blocs" (Objets typés)             |
| **Gestion des Disques**       | Rigide (souvent limitée à 1-2 disques) | Granulaire (Support illimité, types variés) |
| **Stabilité du State**        | Sujet au "Drift" intempestif           | Haute fidélité entre Code et Réalité        |
| **Interface API**             | API REST v1 (limitée)                  | API REST v2 (complète)                      |

### 2.3.4) Justification du Choix Final
Pour ce projet de déploiement d'un cluster Kubernetes, la fiabilité du réseau et du stockage est non négociable. Le choix du provider **BPG 0.90.0** s'est imposé pour trois raisons majeures :
1. **Prévisibilité :** La capacité de BPG à refléter exactement l'état de la VM dans le `terraform.tfstate` élimine les comportements erratiques lors des phases de mise à jour (`apply`).
2. **Sécurité :** L'injection rigoureuse des clés SSH via le bloc `user_account` de Cloud-Init assure une surface d'attaque réduite dès le provisionnement.
3. **Performance :** L'utilisation de l'interface VirtIO SCSI et du type CPU `host`, parfaitement supportés par BPG, garantit que nos nœuds Kubernetes disposent des performances maximales offertes par l'hyperviseur.

> **Conclusion :** En migrant notre infrastructure de Telmate vers BPG, nous passons d'un bricolage de scripts à une véritable solution d'**Infrastructure-as-Code de classe entreprise**, prête pour la production et facile à maintenir.

## 2.4) Schéma d'architecture deployée
{IMAGE DU LAB COMPLET}
## 2.5) Création compte et token Terraform
* Configuration du compte terraform, associé à un rôle avec les droits et un token relié.
```bash
pveum user add terraform@pve
pveum role add Terraform -privs "Realm.AllocateUser, VM.PowerMgmt, VM.GuestAgent.Unrestricted, Sys.Console, Sys.Audit, Sys.AccessNetwork, VM.Config.Cloudinit, VM.Replicate, Pool.Allocate, SDN.Audit, Realm.Allocate, SDN.Use, Mapping.Modify, VM.Config.Memory, VM.GuestAgent.FileSystemMgmt, VM.Allocate, SDN.Allocate, VM.Console, VM.Clone, VM.Backup, Datastore.AllocateTemplate, VM.Snapshot, VM.Config.Network, Sys.Incoming, Sys.Modify, VM.Snapshot.Rollback, VM.Config.Disk, Datastore.Allocate, VM.Config.CPU, VM.Config.CDROM, Group.Allocate, Datastore.Audit, VM.Migrate, VM.GuestAgent.FileWrite, Mapping.Use, Datastore.AllocateSpace, Sys.Syslog, VM.Config.Options, Pool.Audit, User.Modify, VM.Config.HWType, VM.Audit, Sys.PowerMgmt, VM.GuestAgent.Audit, Mapping.Audit, VM.GuestAgent.FileRead, Permissions.Modify"
pveum aclmod / -user terraform@pve -role Terraform
pveum user token add terraform@pve provider --privsep=0
```

┌──────────────┬───────────────────────────────────
│ key          │ value                             
╞══════════════╪═══════════════════════════════════
│ full-tokenid │ terraform@pve!provider            
├──────────────┼───────────────────────────────────
│ info         │ {"privsep":"0"}                   
├──────────────┼───────────────────────────────────
│ value        │ 3e93580b-12be-4e93-b0a0-a2f1c3e2de
└──────────────┴───────────────────────────────────

## 2.6) Installation des outils Terraform/OpenTofu

### 2.6.1) Installation de Terraform
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt-get install terraform
```
* Vérification de l'installation
```bash
terraform version

Terraform v1.14.3
on linux_amd64
```
### 2.6.2) Installation de OpenTofu
```bash
# Download the installer script:
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
# Alternatively: wget --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh

# Give it execution permissions:
chmod +x install-opentofu.sh

# Please inspect the downloaded script

# Run the installer:
./install-opentofu.sh --install-method deb

# Remove the installer:
rm -f install-opentofu.sh
```
* Vérification de l'installation
```bash
tofu --version

OpenTofu v1.11.2
on linux_amd64

```
## 2.7) Déploiement de 4 VMs template 
* Remise à zéro de l'environnement Terraform et les historiques
```bash
cd ~/devops/terraform/
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate terraform.tfstate.backup
rm -rf .terraform .terraform.lock.hcl
```
* Execution du déploiement de l'infrastructure
```
terraform init
terraform plan
terraform apply
```
* Extrait des retours terraform
```bash
proxmox_virtual_environment_vm.vm[0]: Creation complete after 53s [id=9100]
proxmox_virtual_environment_vm.vm[1]: Creation complete after 54s [id=9101]
proxmox_virtual_environment_vm.vm[3]: Creation complete after 55s [id=9103]
proxmox_virtual_environment_vm.vm[2]: Creation complete after 56s [id=9102]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

db_ip = "192.168.122.153"
master_ip = "192.168.122.150"
worker_ips = [
  "192.168.122.151",
  "192.168.122.152",
]
```
* Suppression de l'infrastructure déployé 
```bash
terraform destroy
```
* Test de connexion sur les VM depuis le poste d'administration
```bash
ssh ansible@192.168.122.150 #VM Master
ssh ansible@192.168.122.151 #VM Node1
ssh ansible@192.168.122.152 #VM Node2
ssh ansible@192.168.122.153 #VM DB
```
# Partie 3 : Automatisation et configuration système (Ansible)
## 3.1) Notion d’automatisation de configuration
Dans la continuité de la démarche DevOps adoptée dans ce projet, l’automatisation de la configuration des systèmes constitue un enjeu central. Lorsqu’un environnement comporte plusieurs machines — virtuelles dans notre cas — il devient rapidement difficile, voire risqué, de maintenir une homogénéité de configuration par des actions manuelles. Chaque intervention humaine augmente le risque d’erreur, de dérive de configuration (_configuration drift_) et rend la reproductibilité de l’infrastructure plus complexe.

C’est dans ce contexte qu’intervient **Ansible**, un outil d’automatisation et de gestion de configuration largement utilisé dans les environnements professionnels. Ansible permet de décrire, sous forme déclarative, l’état souhaité d’un système et d’automatiser l’exécution de tâches sur un ensemble de machines distantes. Contrairement à d’autres outils du même domaine, Ansible adopte une approche dite _agentless_ : aucune installation spécifique n’est requise sur les machines cibles. Les opérations sont réalisées principalement via des connexions SSH, ce qui simplifie considérablement le déploiement et la maintenance de la solution.

Le fonctionnement d’Ansible repose sur des **playbooks**, qui sont des fichiers décrits en YAML. Un playbook correspond à un enchaînement structuré de tâches (_tasks_), chacune décrivant une action à effectuer sur un ou plusieurs hôtes : installation de paquets, modification de fichiers de configuration, gestion de services, exécution de commandes, etc. L’un des principes fondamentaux d’Ansible est l’**idempotence** : une tâche peut être exécutée plusieurs fois sans modifier l’état du système si celui-ci correspond déjà à l’état attendu. Cette propriété est essentielle pour garantir des déploiements fiables, répétables et non destructifs.

Dans le cadre de ce laboratoire, Ansible a été utilisé comme **outil d’orchestration de la configuration** des différentes machines virtuelles composant l’infrastructure Kubernetes. Il permet notamment d’automatiser des opérations qui seraient fastidieuses et sources d’erreurs si elles étaient réalisées manuellement, tout en offrant un retour précis sur l’état d’exécution de chaque tâche (succès, modification, échec, ou action ignorée).

Les cas d’usage d’Ansible dans ce projet illustrent bien la polyvalence de l’outil. Il a tout d’abord été employé pour des tâches de **préparation et de durcissement des systèmes**. Dans un contexte professionnel, le niveau de sécurité d’un système d’exploitation est souvent évalué à l’aide de référentiels tels que les _CIS Benchmarks_ (Center for Internet Security). Ces référentiels définissent un ensemble de bonnes pratiques de configuration visant à réduire la surface d’attaque d’un système. Bien que le présent projet soit réalisé dans un cadre de laboratoire, Ansible permettrait très facilement d’implémenter automatiquement ces recommandations à grande échelle, en s’appuyant sur des playbooks communautaires existants. Les benchmarks CIS sont généralement déclinés en plusieurs niveaux, allant d’un niveau 1, axé sur une sécurité de base sans impact significatif sur l’exploitation, à un niveau 2, plus restrictif et destiné à des environnements où la sécurité prime sur le confort d’utilisation.

Ansible a également été utilisé pour l’**installation et la configuration de services applicatifs**. Dans ce projet, cela inclut notamment le déploiement des composants nécessaires au cluster Kubernetes (nœud maître, nœuds workers), l’installation d’outils complémentaires comme MetalLB, l’ingress NGINX ou encore le serveur de métriques (_metrics-server_). Chaque service est déployé de manière contrôlée, reproductible et cohérente sur l’ensemble du cluster, ce qui permet de reconstruire intégralement l’infrastructure à partir des playbooks sans intervention manuelle.

Enfin, Ansible s’avère particulièrement adapté à la **gestion des tâches d’administration courantes**. Il est fréquent de créer des playbooks dédiés à des opérations spécifiques telles que la mise à jour des systèmes, la modification centralisée de fichiers de configuration, la gestion des utilisateurs ou encore la mise en place de procédures de sauvegarde. Dans le cadre de ce laboratoire, cette logique a été appliquée pour structurer le déploiement de Wiki.js en plusieurs phases distinctes : une phase d’initialisation permettant l’installation et la configuration initiale de l’application, suivie d’une phase de mise à l’état final intégrant la montée en charge et l’activation de l’autoscaling.

Le ciblage des machines sur lesquelles s’exécutent les playbooks est assuré par un **système d’inventaire**. L’inventaire Ansible est généralement défini dans un fichier, souvent nommé `inventory.ini`, qui regroupe les hôtes par catégories fonctionnelles (par exemple : nœud maître, nœuds workers, base de données). Cette organisation permet d’appliquer un playbook à un sous-ensemble précis de l’infrastructure. Dans ce projet, l’inventaire Ansible n’est pas défini manuellement : il est généré automatiquement à partir des sorties de Terraform (ou OpenTofu), garantissant ainsi une cohérence totale entre la phase de provisionnement des machines virtuelles et la phase de configuration logicielle.

L’installation d’Ansible sur le poste d’administration est relativement simple et illustre l’accessibilité de l’outil :
```bash
sudo apt install ansible
```
En résumé, Ansible joue dans ce projet un rôle clé en tant que **chaînon entre l’infrastructure virtuelle provisionnée par Terraform et les services applicatifs déployés sur Kubernetes**. Il permet de traduire une architecture théorique en une infrastructure fonctionnelle, reproductible et documentée, tout en s’inscrivant pleinement dans les bonnes pratiques DevOps modernes.

## 3.2) Structuration des playbooks et logique d’exécution
Afin de rendre le déploiement reproductible et lisible, le répertoire `ansible/` est organisé autour d’une série de playbooks numérotés, reflétant l’ordre d’exécution nécessaire à la mise en service complète du laboratoire. Cette numérotation n’est pas purement esthétique : elle matérialise les dépendances techniques entre composants. Certaines briques ne peuvent être configurées que si les précédentes sont opérationnelles (par exemple, un service applicatif ne peut être exposé via un Ingress que si un contrôleur Ingress est installé, et l’autoscaling via HPA n’est possible que si les métriques sont disponibles).

Le premier playbook, `1-deploy-k8s-master.yaml`, établit les fondations du cluster Kubernetes. Il prépare le nœud maître (control plane), installe les dépendances nécessaires, initialise le cluster (kubeadm) et met en place l’accès administratif (kubeconfig) afin de permettre l’administration via `kubectl`. À l’issue de cette étape, le cluster existe, mais il n’est pas encore pleinement exploitable tant que des nœuds de calcul n’ont pas été joints et qu’un plugin réseau n’assure pas la connectivité inter-pods.

Le playbook `2-deploy-k8s-workers.yaml` poursuit logiquement en ajoutant les nœuds workers au cluster. Cette étape automatise la jonction des nœuds au control plane et garantit que l’ensemble des machines prévues participe bien à l’exécution des charges de travail. À ce stade, le cluster devient distribué et capable d’héberger des applications, mais l’environnement n’est pas encore complet sur le plan “plateforme”, car il manque les briques nécessaires à l’exposition réseau et à certains services transverses.

Le playbook `3-deploy-db-postgres.yaml` déploie ensuite la base de données PostgreSQL sur une machine dédiée, hors du cluster Kubernetes. Ce choix permet de découpler le stockage persistant du cycle de vie des pods et de simplifier la gestion de la donnée dans un contexte de laboratoire (stabilité, visibilité, dépannage facilité). Le playbook prépare le service de base de données (création de la base, utilisateur, mot de passe et paramètres), puis vérifie que l’instance est accessible depuis le cluster. Cette étape est volontairement placée avant le déploiement applicatif afin que Wiki.js puisse se connecter à une base déjà prête et stable.

Le playbook `4-deploy-metallb.yaml` ajoute une brique essentielle dans un environnement on-premise : la capacité à disposer de Services Kubernetes de type `LoadBalancer`. Dans les clouds publics, cette fonctionnalité est fournie nativement par l’infrastructure. Dans un lab local, MetalLB remplit ce rôle en attribuant des adresses IP virtuelles à certains services, offrant ainsi une exposition réseau “propre” et cohérente avec les standards Kubernetes. Cette étape est positionnée avant l’ingress car le contrôleur Ingress doit être exposé vers l’extérieur via un service `LoadBalancer` (ou équivalent).

Le playbook `5-deploy-ingress-nginx.yaml` installe ensuite le contrôleur Ingress NGINX. Il constitue le point d’entrée HTTP/HTTPS du cluster et permet de router les requêtes vers les services applicatifs internes selon un modèle standard (host/path). L’Ingress Controller est un composant structurant : sans lui, l’accès aux applications se ferait via des NodePorts ou des port-forwardings, ce qui est moins représentatif des architectures réelles. Une fois cette brique en place, le cluster dispose d’un mécanisme stable pour publier des applications via un nom de domaine et des règles de routage.

Le playbook `6-deploy-metrics-server.yaml` complète la couche “plateforme” en installant `metrics-server`, qui expose les métriques CPU/RAM via l’API `metrics.k8s.io`. Cette brique est indispensable pour deux raisons : d’une part pour diagnostiquer et observer la consommation de ressources (`kubectl top`), et d’autre part pour activer l’autoscaling horizontal (HPA). L’ordre est important : l’HPA ne peut pas fonctionner tant que les métriques ne sont pas disponibles et stabilisées.

Le playbook `7-deploy-wikijs-init.yaml` déploie ensuite Wiki.js via Helm dans une configuration d’initialisation. La logique est volontairement prudente : conformément aux recommandations Wiki.js, une instance unique est utilisée lors de la phase de setup afin d’éviter des comportements incohérents (initialisation concurrente, états de configuration divergents). Le playbook automatise l’installation (chart Helm, namespace, valeurs de configuration, connexion à la base externe et création de l’Ingress), puis s’arrête volontairement au moment où l’interface web est accessible pour finaliser la configuration initiale via l’assistant de setup.

Enfin, `8-deploy-wikijs-scale.yaml` correspond à la mise en “configuration finale” du service. Une fois l’initialisation validée, ce playbook applique les paramètres de montée en charge : augmentation du nombre de réplicas, définition de ressources minimales/maximales et, si souhaité, activation d’un autoscaler (HPA) avec un seuil de déclenchement basé sur l’utilisation CPU. Cette séparation en deux playbooks (init vs scale) reflète une logique proche des pratiques industrielles : on distingue une phase de bootstrap contrôlée d’une phase d’exploitation et de dimensionnement.

Ainsi, l’enchaînement des playbooks ne correspond pas seulement à une progression technique, mais à une structuration méthodique : d’abord la création du cluster, ensuite les services “plateforme” nécessaires (réseau, exposition, observabilité), puis le déploiement applicatif avec une phase d’initialisation maîtrisée, et enfin la mise à l’échelle. Cette approche permet d’obtenir un laboratoire reproductible, stable et proche des architectures observées en production.
```
ansible/
├── 1-deploy-k8s-master.yaml
├── 2-deploy-k8s-workers.yaml
├── 3-deploy-db-postgres.yaml
├── 4-deploy-metallb.yaml
├── 5-deploy-ingress-nginx.yaml
├── 6-deploy-metrics-server.yaml
├── 7-deploy-wikijs-init.yaml
├── 8-deploy-wikijs-scale.yaml
├── artifacts
│   └── join-workers.sh
├── cis_ubuntu24_audit.yml
├── inventory.ini
├── inventory.template.ini
├── reports
│   ├── tf-k8s-master
│   │   └── cis_audit_result_03_01_2026_18h08.txt
│   ├── tf-k8s-node-1
│   │   └── cis_audit_result_03_01_2026_18h08.txt
│   └── tf-k8s-node-2
│       └── cis_audit_result_03_01_2026_18h08.txt
├── roles
│   ├── ubuntu24_cis
│   └── ubuntu24_cis_audit
├── terraform.tfstate
```
## 3.3) Tache 0 : Audit du niveau de sécurité CIS (optionnnel)
 Il existe plusieurs outils pour connaitre son niveaux de conformité face aux benchmarks CIS, certains sont payants d'autres complètement open-source et gratuit et certains se basent sur d'autres critères. Dans notre cas nous utiliserons l'outil de vérification : 
 * UBUNTU24-CIS-Audit (GOSS) : L'outil directement fournit avec notre playbook d'hardening ansible fait par `Ansible-lockdown`, il permet de vérifier le niveau de conformité avec tous les détails nécessaire

Il faut donc installer via Ansible les outils pour effectuer le scoring sur chaque VM 

Le but ici est de déployer sur l'ensemble des VMs du cluster l'outil `UBUNTU24-CIS-Audit` pour connaitre leur score de conformité et ensuite comparer l'évolution après la phase de hardening. Pour cela nous avons mis en place un playbook ansible qui se connecte en SSH sur les agents et va venir effectuer ces actions : 
0. Installer rsync pour le transfert
1. Préparer l'environnement d'audit
2. Télécharger le binaire GOSS
3. Synchroniser les tests CIS
4. Lancer l'audit CIS (Format Documentation)
5. Localiser le rapport généré par le script
6. Créer le dossier de stockage local
7. Rapatrier le rapport avec date au format français
8. Résumé de l'audit

Et nous aurons à la toute fin un fichier pour chaque VMs avec le rapport complet avec la date. Nous pouvons le conserver histoire d'avoir un historique du niveau de sécurité ou bien prouvé par la suite que le hardening a bien fonctionné.

* Exécution du playbook
```bash
cd ~/devops/ansible
ansible-playbook -i inventory.ini cis_ubuntu24_audit.yml
```
* Consulter les rapports générés avec les détails + score à la fin.
```bash
tree reports/
reports/
├── tf-k8s-master
│   └── cis_audit_result_03_01_2026_00h17.txt
├── tf-k8s-node-1
│   └── cis_audit_result_03_01_2026_00h17.txt
└── tf-k8s-node-2
    └── cis_audit_result_03_01_2026_00h17.txt
```

| Score   | Avant hardening | Après hardening |
| ------- | --------------- | --------------- |
| Failed  | 338             | 74              |
| Success | 368             | 665             |
| Skipped | 50              | 17              |
| Total   | 756             | 756             |
| **%**   | **48,7 %**      | **88,0 %**      |


# Partie 4 : Conteneurisation — Concepts, Outils et Choix Techniques

## 4.1) Notion de conteneurisation

La conteneurisation représente une évolution majeure par rapport à la virtualisation matérielle classique. Là où une machine virtuelle émule un matériel complet avec son propre noyau, un conteneur opère une **virtualisation au niveau du système d'exploitation** : il isole des processus en partageant le noyau de la machine hôte.

Cette isolation repose sur trois primitives fondamentales du noyau Linux.

**Les Namespaces** constituent la barrière d'isolation principale. Le noyau alloue à chaque conteneur ses propres instances de structures de données système : `PID` pour les processus, `NET` pour la pile réseau, `MNT` pour les points de montage, `UTS` pour le nom d'hôte, `IPC` pour les communications inter-processus, et `USER` pour l'isolation des identifiants utilisateurs. Un processus à l'intérieur d'un conteneur se croit seul sur le système, sans visibilité sur l'hôte ni sur les autres conteneurs.

**Les Control Groups (cgroups)** complètent l'isolation en limitant ce que le conteneur peut *consommer*. Ils permettent une gestion granulaire des ressources (CPU, RAM, I/O disque, bande passante réseau), garantissant qu'un conteneur ne puisse pas saturer l'hôte — phénomène dit du *noisy neighbor*. La version 2 des cgroups (`cgroups v2`), désormais standard sur Ubuntu 22.04+, unifie la hiérarchie et améliore significativement la gestion des ressources en mode rootless.

**Le système de fichiers en couches (UnionFS / OverlayFS)** permet aux conteneurs de partager une image de base immuable tout en y superposant des couches de modifications propres à chaque instance. Le mécanisme *Copy-on-Write* (CoW) garantit qu'une couche de base n'est stockée qu'une seule fois sur l'hôte, même si cent conteneurs s'en servent simultanément.

Le conteneur devient ainsi une unité de distribution logicielle universelle : il embarque l'application avec l'intégralité de ses dépendances, éliminant la dérive entre environnements de développement, de qualification et de production.

---

## 4.2) La pile de conteneurisation — architecture en couches

Avant de comparer les outils, il est essentiel de comprendre que la "conteneurisation" n'est pas un outil unique mais une **pile de composants distincts**, chacun ayant un rôle précis et des interfaces standardisées.

```
┌─────────────────────────────────────────────────────────┐
│            Container Engine (usage humain)              │
│         Docker CLI  /  Podman CLI  /  nerdctl           │
├─────────────────────────────────────────────────────────┤
│         Container Runtime CRI (usage orchestrateur)     │
│              containerd  /  CRI-O                       │
├─────────────────────────────────────────────────────────┤
│         OCI Runtime (interaction noyau)                 │
│                  runc  /  crun                          │
├─────────────────────────────────────────────────────────┤
│                   Noyau Linux                           │
│         Namespaces · cgroups · OverlayFS                │
└─────────────────────────────────────────────────────────┘
```

Chaque couche communique avec la suivante via un **contrat standardisé** :

- Le Container Engine parle à son runtime CRI via une socket Unix propriétaire (Docker) ou en appel direct (Podman).
- Le kubelet de Kubernetes parle au runtime CRI via l'**interface CRI**, spécification gRPC définie par le projet Kubernetes.
- Le runtime CRI parle à l'OCI Runtime via la **spécification OCI**, un fichier `config.json` décrivant le conteneur à créer.
- L'OCI Runtime appelle directement le noyau Linux via des syscalls (`clone()`, `setrlimit()`, `pivot_root()`).

Cette séparation en couches interchangeables est la clé de compréhension de tout l'écosystème.

---

## 4.3) Les Container Engines — outils orientés utilisateur

Un **Container Engine** est une suite logicielle complète conçue pour qu'un humain (développeur, administrateur, script CI) puisse interagir avec des conteneurs sans se préoccuper des mécanismes bas niveau. Il fournit : une CLI, la gestion des images (pull, build, push), la gestion des volumes et du réseau, et l'orchestration locale de conteneurs.

Docker et Podman sont les deux Container Engines dominants. Ils ciblent le **même usage** — manipulation de conteneurs en local — mais avec des architectures fondamentalement différentes.

### 4.3.1) Docker — le pionnier et ses limites structurelles

Docker a démocratisé les conteneurs à partir de 2013 en proposant une interface unifiée et simple. Son architecture repose sur un **modèle client-serveur** centralisé autour du daemon `dockerd`.

```
docker CLI  ──socket──►  dockerd (root)  ──►  containerd  ──►  runc  ──►  noyau
```

Ce modèle présente trois limites structurelles identifiées.

**Point de défaillance unique (SPOF).** Le daemon dockerd gère en permanence l'état global de tous les conteneurs, images, volumes et réseaux. Si ce processus s'interrompt — crash, mise à jour, OOM killer — l'intégralité de la flotte de conteneurs devient orpheline ou s'arrête. Ce comportement est incompatible avec une infrastructure à haute disponibilité.

**Surface d'attaque par le daemon root.** Le daemon tourne en permanence avec les privilèges `root`. Une vulnérabilité de type *container escape* — dont plusieurs ont été documentées dans les CVE de l'OCI — donne à un attaquant un accès root immédiat sur l'hôte physique. Ce modèle viole le principe de moindre privilège.

**Exclusion de l'écosystème Kubernetes.** Docker ne parlait pas nativement l'interface CRI. Kubernetes maintenait une couche de traduction ad hoc appelée `dockershim` uniquement pour Docker, représentant une dette technique considérable. Cette couche a été définitivement supprimée en **Kubernetes 1.24 (mai 2022)**. Docker comme runtime Kubernetes n'est plus possible sans adaptateur tiers.

### 4.3.2) Podman — rupture architecturale et sécurité par conception

Podman (Pod Manager), développé par Red Hat, adopte une architecture radicalement différente : **daemonless et rootless par défaut**.

```
podman CLI  ──fork/exec──►  crun  ──►  noyau
                (pas de daemon intermédiaire)
```

Chaque conteneur Podman est un processus enfant direct de l'outil, géré de manière autonome par le noyau. Il n'existe aucun processus central intermédiaire.

**Mode Rootless natif.** Podman exploite les `User Namespaces` du noyau pour mapper les UID/GID via `/etc/subuid` et `/etc/subgid`. Un utilisateur `root` à l'intérieur du conteneur correspond à un utilisateur standard sans droits sur l'hôte. En cas de compromission, l'attaquant reste confiné dans l'espace de noms utilisateur sans capacité d'escalade de privilèges.

**Intégration Systemd native.** Podman délègue la gestion du cycle de vie des conteneurs à Systemd via des unit files générés automatiquement (`podman generate systemd`). Le redémarrage automatique, la gestion des dépendances entre services et la journalisation centralisée via `journald` sont ainsi gérés par le superviseur standard de l'OS, sans couche applicative supplémentaire.

**Convergence native avec Kubernetes.** Podman implémente nativement le concept de Pod et peut générer des manifestes YAML Kubernetes directement depuis un pod en cours d'exécution (`podman generate kube`). Cette capacité permet de tester localement des topologies identiques à celles du cluster cible et de produire les fichiers de déploiement utilisés ensuite par Helm ou kubectl.

**Conformité OCI totale.** Toutes les images construites avec Docker sont compatibles avec Podman et inversement — le format d'image OCI est un standard commun. Podman s'affranchit de la licence commerciale de Docker Desktop, qui a évolué vers un modèle payant pour les entreprises de plus de 250 employés depuis 2022.

### 4.3.3) Tableau comparatif Docker vs Podman

| Critère | Docker | Podman |
|---|---|---|
| Architecture | Client-serveur (daemon central) | Daemonless (fork/exec) |
| Privilèges par défaut | Daemon root permanent | Rootless natif |
| SPOF | Oui — crash dockerd = tout s'arrête | Non — chaque conteneur est indépendant |
| Intégration Systemd | Contournée (propre init) | Native (unit files générés) |
| Compatibilité images OCI | Oui | Oui |
| Concept de Pod natif | Non | Oui |
| Génération manifestes K8s | Non | Oui (`podman generate kube`) |
| Licence | Docker Desktop payant (entreprises) | Apache 2.0, entièrement libre |
| Runtime K8s possible | Non (depuis K8s 1.24) | Non (pas de socket CRI) |

**Conclusion sur les Container Engines :** Podman est objectivement supérieur à Docker sur les critères de sécurité, d'intégration système et de convergence avec Kubernetes. Il est adopté comme standard dans les environnements Red Hat/Fedora et gagne du terrain dans les équipes qui ont migré de Docker. Dans ce projet, Podman est l'outil utilisé **sur le poste d'administration** pour manipuler des conteneurs en local, tester des configurations et générer des manifestes avant déploiement sur le cluster.

---

## 4.4) Les runtimes Kubernetes — ce que l'orchestrateur utilise réellement

Un point fondamental à comprendre : **Kubernetes n'utilise pas de Container Engine**. Il n'a besoin ni de Docker ni de Podman. Ces outils sont conçus pour une interaction humaine — ils ont une CLI, une gestion d'état locale, des fonctionnalités de build. Kubernetes, lui, a besoin d'un composant serveur minimal qui répond à des appels programmatiques pour créer et détruire des conteneurs à très grande échelle.

La pile réellement déployée sur chaque nœud worker d'un cluster Kubernetes est la suivante :

```
kube-apiserver (master)
        │
        │  API Kubernetes (HTTP/gRPC)
        ▼
    kubelet (agent sur chaque nœud)
        │
        │  Interface CRI (socket Unix, gRPC)
        ▼
  Runtime CRI  ──────────────────────────────────────
  containerd  ou  CRI-O                              │
        │                                            │
        │  OCI Runtime Spec (config.json)            │
        ▼                                            │
  OCI Runtime                                        │
  runc  ou  crun                                     │
        │                                            │
        │  syscalls Linux                            │
        ▼                                            │
    Noyau Linux                                      │
  (namespaces · cgroups · overlayfs) ────────────────┘
```

### 4.4.1) L'interface CRI — le contrat entre Kubernetes et le runtime

La **Container Runtime Interface (CRI)** est une spécification gRPC définie par le projet Kubernetes. Elle expose exactement les opérations dont le kubelet a besoin, ni plus, ni moins :

- `RunPodSandbox` — créer l'espace réseau isolé d'un pod
- `CreateContainer` / `StartContainer` — créer et démarrer un conteneur dans ce sandbox
- `StopContainer` / `RemoveContainer` — cycle de vie
- `PullImage` — télécharger une image depuis un registry
- `ListContainers` / `ContainerStatus` — inspection de l'état

Le kubelet ne sait pas et ne se soucie pas de ce qui implémente CRI derrière le socket. C'est un contrat pur — n'importe quelle implémentation conforme est interchangeable.

### 4.4.2) Les implémentations CRI — containerd vs CRI-O

Deux implémentations dominent le marché.

**containerd** a été extrait du code de Docker en 2017 et donné à la CNCF, dont il est aujourd'hui un projet *graduated* (niveau de maturité maximum). Il implémente CRI via un plugin interne et expose en parallèle sa propre API gRPC publique, permettant des usages au-delà de Kubernetes : build d'images, inspection de conteneurs, intégration avec des outils tiers comme BuildKit ou Trivy. Cette polyvalence est son principal avantage opérationnel — sur un nœud de cluster, un administrateur peut utiliser `ctr` ou `nerdctl` pour inspecter manuellement ce qui tourne, sans passer par kubectl.

**CRI-O** a été créé par Red Hat en 2016 avec un objectif documenté explicitement : *"to provide an integration path between OCI conformant runtimes and the kubelet"*, rien de plus. CRI-O n'a pas de CLI utilisateur, pas d'API publique, pas de fonctionnalités hors Kubernetes. Si Kubernetes est arrêté, CRI-O est inutile. Cette spécialisation extrême réduit la surface d'attaque à son minimum absolu et maintient une synchronisation de version exacte avec Kubernetes (CRI-O 1.29 est certifié pour K8s 1.29). C'est le runtime par défaut d'OpenShift.

| Critère | containerd | CRI-O |
|---|---|---|
| Origine | Extrait de Docker → CNCF graduated | Red Hat, créé pour K8s uniquement |
| Périmètre | Runtime K8s + API publique + usage standalone | Runtime K8s exclusivement |
| CLI utilisateur | `ctr`, `nerdctl` | Aucune (debug via `crictl` seulement) |
| Surface d'attaque | Modérée (code supplémentaire) | Minimale par conception |
| Versioning | Indépendant de K8s | Synchronisé exactement avec K8s |
| Adoption | GKE, EKS, AKS, k3s — standard de fait | OpenShift, environnements Red Hat |
| Utilisation dans ce projet | ✅ Retenu | — |

**Synthèse :** les deux runtimes CRI sont techniquement solides. containerd est retenu dans ce projet pour sa polyvalence opérationnelle — la possibilité d'inspecter les conteneurs directement sur les nœuds sans passer par l'API Kubernetes est un avantage réel en contexte de lab et en débogage de production.

### 4.4.3) L'OCI Runtime — runc vs crun

L'OCI Runtime est la couche la plus basse de la pile. Il reçoit une spécification de conteneur sous forme de fichier JSON normalisé par l'Open Container Initiative et effectue les appels syscalls Linux nécessaires à la création effective du conteneur : création des namespaces, configuration des cgroups, isolation du système de fichiers.

**runc** est l'implémentation de référence de l'OCI, écrite en Go, créée par Docker et donnée à l'OCI en 2015. Sa conformité est garantie — c'est lui qui définit le comportement attendu par la spécification.

**crun** est une réimplémentation en C développée par Red Hat. Les mesures de performance publiées et reproduites indépendamment montrent des différences significatives :

| Critère | runc | crun |
|---|---|---|
| Langage | Go | C |
| Temps de démarrage d'un conteneur | ~100–150 ms | ~30–50 ms |
| Empreinte mémoire RSS | ~15 Mo | ~3–4 Mo |
| Support cgroups v2 | Ajouté tardivement | Natif dès l'origine |
| Rootless containers | Support limité | Support natif et complet |
| Conformité OCI | Référence | Complète + extensions |

crun est objectivement plus rapide et plus léger sur tous les critères mesurables. Ces écarts ont un impact réel en production : sur un cluster qui démarre plusieurs centaines de pods simultanément (mise à l'échelle brutale, redémarrage de nœud), la différence de temps de démarrage s'accumule. runc reste dominant uniquement par inertie historique — containerd l'utilise par défaut parce qu'il vient du même écosystème Docker, et ce défaut n'a jamais été modifié à l'échelle de l'infrastructure mondiale.

---

## 4.5) Interchangeabilité des composants et configuration optimisée

Un point critique à comprendre : les couches CRI et OCI Runtime sont **entièrement interchangeables**. Il n'existe aucune contrainte technique qui force l'association containerd+runc ou CRI-O+crun. Ces paires dominent uniquement parce que chaque projet embarque le runtime de son écosystème d'origine par défaut.

La configuration de containerd pour utiliser crun se résume à trois lignes dans `/etc/containerd/config.toml` :

```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  BinaryName = "/usr/bin/crun"
```

La matrice complète des combinaisons valides et utilisées en production :

| Runtime CRI | OCI Runtime | Contexte d'usage |
|---|---|---|
| containerd | runc | Défaut historique — majorité des clusters cloud |
| containerd | crun | Optimal — polyvalence + performance, adoption croissante |
| containerd | gVisor (runsc) | Isolation renforcée niveau syscall — GKE Sandbox |
| containerd | kata-containers | Isolation niveau VM — workloads multi-tenant sensibles |
| CRI-O | crun | Standard Red Hat / OpenShift |
| CRI-O | runc | Valide mais rare |

### 4.5.1) Modèle retenu dans ce projet : containerd + crun

Le modèle **containerd + crun** est retenu pour ce projet sur la base des critères suivants.

containerd offre la polyvalence opérationnelle nécessaire dans un environnement de lab et de production on-premise : inspection directe des conteneurs sur les nœuds, compatibilité avec les outils de l'écosystème CNCF (Trivy, BuildKit, Falco), et support de runtimes alternatifs pour des besoins futurs.

crun remplace runc comme OCI Runtime pour bénéficier de temps de démarrage de pods réduits (~3× plus rapide), d'une empreinte mémoire minimale et d'un support natif et complet de cgroups v2 et du mode rootless — cohérent avec la philosophie de sécurité défendue dans ce projet.

Ce choix correspond au modèle identifié comme optimal par les benchmarks de la communauté Kubernetes pour les déploiements on-premise en 2024-2026, et préfigure l'évolution probable des defaults des distributions Kubernetes dans les années à venir.

---

## 4.6) Positionnement de Podman dans l'architecture globale du projet

Il convient de clarifier explicitement la place de chaque outil dans l'architecture :

| Outil | Catégorie | Rôle dans ce projet | Présent sur |
|---|---|---|---|
| Podman | Container Engine | Manipulation de conteneurs en local, test de pods, génération de manifestes YAML | Poste d'administration |
| containerd | Runtime CRI | Gestion du cycle de vie des conteneurs dans le cluster K8s | Chaque nœud K8s |
| crun | OCI Runtime | Exécution effective des conteneurs via syscalls Linux | Chaque nœud K8s |
| Docker | Container Engine | Non utilisé dans ce projet | — |
| CRI-O | Runtime CRI | Non retenu — écosystème Red Hat/OpenShift | — |

Podman et containerd ne sont pas en compétition — ils opèrent à des niveaux différents pour des usages différents. Podman est l'outil de développement et d'administration locale ; containerd est le composant serveur intégré dans le cluster. Cette séparation reflète précisément les bonnes pratiques de l'industrie : les Container Engines sont des outils humains, les runtimes CRI sont des composants d'infrastructure.

# Partie 5 : Orchestration de conteneurs Kubernetes
## 5.1) Notions fondamentales de Kubernetes

Kubernetes est une plateforme d’orchestration de conteneurs conçue pour automatiser le déploiement, la mise à l’échelle et l’exploitation d’applications conteneurisées. Là où un moteur de conteneurisation comme Podman ou Docker permet d’exécuter un conteneur sur une machine donnée, Kubernetes introduit une **abstraction distribuée** : l’application n’est plus liée à un hôte précis, mais devient une charge de travail orchestrée à l’échelle d’un cluster.

Un cluster Kubernetes repose sur une architecture maître-agents. Le **nœud maître** (ou _control plane_) centralise les fonctions de pilotage du cluster : il maintient l’état désiré de l’infrastructure, planifie les charges de travail et expose l’API Kubernetes, qui constitue le point d’entrée unique pour toute interaction administrative. Les **nœuds workers**, quant à eux, sont responsables de l’exécution effective des applications. Ils hébergent les conteneurs et fournissent les ressources CPU, mémoire et réseau nécessaires à leur fonctionnement.

L’unité fondamentale de déploiement dans Kubernetes est le **Pod**. Un pod représente une ou plusieurs instances de conteneurs partageant un même contexte d’exécution (espace réseau, volumes, configuration). Dans la majorité des cas, un pod contient un seul conteneur applicatif, ce qui simplifie la gestion et le cycle de vie. Cependant, Kubernetes autorise également des pods multi-conteneurs lorsque plusieurs processus doivent être étroitement couplés et fonctionner comme une entité logique unique (par exemple, un conteneur principal accompagné d’un conteneur auxiliaire chargé de la journalisation ou du proxying).

Cette approche permet à Kubernetes de gérer finement la disponibilité et la résilience des applications. Les pods sont considérés comme **éphémères** : ils peuvent être créés, détruits ou déplacés automatiquement par le scheduler en fonction de l’état du cluster. Cette caractéristique impose une séparation claire entre l’application elle-même et ses données persistantes.

La question du **stockage** est donc centrale. Kubernetes propose des mécanismes de volumes persistants (PV/PVC) permettant d’abstraire les ressources de stockage internes au cluster. Toutefois, dans le cadre de ce laboratoire, un choix volontairement plus simple et plus lisible a été retenu : la base de données est **externalisée** du cluster. Cette approche facilite la compréhension des flux, stabilise les données face au cycle de vie des pods et reflète un modèle très courant en production, où les bases de données critiques sont souvent isolées des plateformes d’orchestration applicative.

Pour permettre la communication entre les différents composants, Kubernetes introduit la notion de **Service**. Un service fournit une adresse réseau stable (IP virtuelle et DNS interne) pour accéder à un ensemble dynamique de pods. Il masque ainsi la nature éphémère des pods et assure un mécanisme de répartition de charge basique entre les réplicas d’une même application.

Lorsque l’application doit être exposée vers l’extérieur du cluster, Kubernetes s’appuie sur le concept d’**Ingress**. Un Ingress définit des règles de routage HTTP/HTTPS basées sur des noms de domaine et des chemins, et délègue leur application à un contrôleur Ingress (comme NGINX). Cette approche permet de centraliser l’exposition réseau, d’éviter l’ouverture de ports multiples et de se rapprocher des architectures web modernes.

Enfin, Kubernetes intègre des mécanismes natifs de **mise à l’échelle automatique**. Le _Horizontal Pod Autoscaler_ (HPA) ajuste dynamiquement le nombre de pods d’une application en fonction de métriques, typiquement l’utilisation CPU ou mémoire. Ce mécanisme repose sur la disponibilité d’un composant dédié, le **metrics-server**, chargé de collecter et d’exposer les métriques de consommation des nœuds et des pods. L’autoscaling permet ainsi d’adapter automatiquement les ressources allouées à une application en fonction de la charge, sans intervention humaine.

## 5.2 Traduction de ces notions dans l’architecture du laboratoire

Dans le cadre de ce projet, Kubernetes est utilisé comme **socle d’orchestration applicative**, déployé sur un cluster composé d’un nœud maître et de plusieurs nœuds workers. Cette topologie permet de dissocier clairement les fonctions de pilotage et d’exécution, tout en offrant une base réaliste pour l’hébergement d’applications distribuées.

L’application Wiki.js est déployée sous forme de pods répliqués sur les nœuds workers. Chaque pod exécute un conteneur Wiki.js et se connecte à une base PostgreSQL hébergée sur une machine dédiée, en dehors du cluster. Ce choix illustre un compromis volontaire entre simplicité, stabilité des données et représentativité des architectures professionnelles.

L’exposition réseau repose sur une chaîne de composants complémentaires. Dans un environnement on-premise, Kubernetes ne fournit pas nativement de services de type `LoadBalancer`. Pour combler ce manque, **MetalLB** est déployé afin d’attribuer des adresses IP virtuelles aux services nécessitant une exposition externe. Le contrôleur **Ingress NGINX** s’appuie ensuite sur cette adresse pour router les requêtes HTTP vers les services internes du cluster, en fonction du nom de domaine configuré.

La supervision minimale et l’autoscaling sont rendus possibles par l’installation de **metrics-server**, qui alimente à la fois les commandes d’observation (`kubectl top`) et le HPA. Une fois l’application initialisée, Wiki.js peut ainsi être déployée avec plusieurs réplicas et bénéficier d’une montée en charge automatique en fonction de l’utilisation CPU.

## 5.3) Automatisation du déploiement du cluster avec Ansible

Dans ce projet, Kubernetes n’est jamais installé manuellement. L’intégralité de la mise en place du cluster est automatisée à l’aide d’Ansible, afin de garantir la reproductibilité du déploiement et de limiter les erreurs humaines.

L’approche adoptée consiste à découper le déploiement en **playbooks indépendants mais ordonnés**, chacun correspondant à une brique fonctionnelle précise du cluster. Cette organisation permet de rejouer tout ou partie du déploiement sans impacter les composants déjà en place.

## 5.4) Mise en place des services “plateforme” du cluster

Un cluster Kubernetes minimal, bien que fonctionnel, n’est pas directement exploitable dans un contexte réaliste. Plusieurs services complémentaires sont nécessaires, notamment dans un environnement on-premise.

MetalLB est utilisé pour fournir des adresses IP de type `LoadBalancer`, fonctionnalité normalement assurée par les clouds publics. Le contrôleur Ingress NGINX permet ensuite d’exposer les applications via HTTP/HTTPS, en s’appuyant sur des règles de routage standardisées. Enfin, `metrics-server` est indispensable pour collecter les métriques CPU et mémoire, condition préalable à toute politique d’autoscaling.

Ces briques constituent la **couche plateforme** du cluster, sur laquelle pourront ensuite s’appuyer les déploiements applicatifs.

## 5.5) Partie pratique – Déploiement complet du cluster Kubernetes

Cette section présente le **workflow réel** utilisé pour déployer le cluster Kubernetes à partir d’un environnement vierge. Les commandes suivantes sont exécutées depuis le poste d’administration disposant d’Ansible et de l’inventaire généré par Terraform.

### **Étape 1 – Initialisation du nœud maître**
```bash
cd ~/devops/ansible ansible-playbook -i inventory.ini 1-deploy-k8s-master.yaml
```
Ce playbook prépare le nœud maître du cluster :
- installation des dépendances Kubernetes,
- initialisation du control plane,
- configuration de l’accès administrateur via `kubectl`.

À l’issue de cette étape, le cluster existe mais ne dispose encore d’aucun nœud de calcul.

### **Étape 2 – Ajout des nœuds workers**
```bash
ansible-playbook -i inventory.ini 2-deploy-k8s-workers.yaml
```
Ce playbook automatise la jonction des nœuds workers au cluster.  
Une fois terminé, le cluster devient distribué et capable d’exécuter des charges applicatives.

### **Étape 3 – Déploiement de la base de données PostgreSQL (hors cluster)**
```bash
ansible-playbook -i inventory.ini 3-deploy-db-postgres.yaml
```
La base de données est déployée sur une machine dédiée, en dehors du cluster Kubernetes.  
Ce choix permet de garantir la persistance des données indépendamment du cycle de vie des pods applicatifs.

### **Étape 4 – Mise en place de MetalLB**
```bash
ansible-playbook -i inventory.ini 4-deploy-metallb.yaml
```
MetalLB est installé afin de permettre l’utilisation de services Kubernetes de type `LoadBalancer` dans un environnement on-premise. Cette étape est indispensable pour exposer proprement des services vers le réseau local.

### **Étape 5 – Installation du contrôleur Ingress NGINX**
```bash
ansible-playbook -i inventory.ini 5-deploy-ingress-nginx.yaml
```
Le contrôleur Ingress NGINX est déployé et exposé via MetalLB.  
Il devient le point d’entrée HTTP/HTTPS du cluster et permet de publier les applications à l’aide de règles Ingress standardisées.

### **Étape 6 – Activation des métriques Kubernetes**
```bash
ansible-playbook -i inventory.ini 6-deploy-metrics-server.yaml
```
Le `metrics-server` est installé afin de collecter les métriques CPU et mémoire des pods et des nœuds.  
Cette étape permet notamment l’utilisation de commandes d’observation (`kubectl top`) et l’activation de l’autoscaling horizontal.

### **État final du cluster**
À l’issue de ces étapes, le cluster Kubernetes est pleinement opérationnel. Son état peut être vérifié à l’aide de la commande suivante :
```bash
kubectl get nodes,pods,svc,ingress,ep,hpa -A
```
Cette commande offre une vision synthétique de l’ensemble des composants du cluster : nœuds, workloads, services, ingress et mécanismes d’autoscaling.

# **Partie 6 : Déploiement applicatif avec Helm – Cas de Wiki.js**

## **6.1 Enjeux du déploiement applicatif sur Kubernetes**
Une fois la plateforme Kubernetes opérationnelle, la problématique ne se limite plus à l’orchestration des conteneurs, mais concerne désormais le **déploiement applicatif cohérent, maintenable et évolutif**. Kubernetes fournit nativement les briques nécessaires à l’exécution d’une application (pods, services, ingress), mais il ne dicte pas la manière d’organiser un déploiement applicatif complexe.

Dans le cas d’une application telle que Wiki.js, plusieurs contraintes apparaissent rapidement : dépendance à une base de données externe, phase d’initialisation unique, exposition web sécurisée, sondes de santé, paramètres de montée en charge, et gestion des mises à jour. Décrire manuellement l’ensemble de ces éléments sous forme de manifestes Kubernetes indépendants devient vite fastidieux, peu lisible et source d’erreurs.

C’est dans ce contexte qu’intervient **Helm**, qui apporte une couche d’abstraction supplémentaire dédiée au packaging et au cycle de vie applicatif sur Kubernetes.

## **6.2 Helm : gestionnaire de paquets pour Kubernetes**
Helm peut être comparé à un gestionnaire de paquets tel que `apt` ou `yum`, mais appliqué à Kubernetes. Il permet de déployer des applications complètes sous forme de **charts**, qui regroupent :
- les manifestes Kubernetes nécessaires (Deployments, Services, Ingress, Secrets, etc.),
- des templates dynamiques,
- et un fichier de configuration centralisé (`values.yaml`) permettant d’adapter le déploiement sans modifier les templates.

Cette approche présente plusieurs avantages majeurs :
- **Centralisation de la configuration** : l’ensemble des paramètres applicatifs est regroupé dans un fichier unique.
- **Standardisation** : les charts officiels sont maintenus par les éditeurs ou la communauté, garantissant le respect des bonnes pratiques.
- **Gestion du cycle de vie** : Helm versionne chaque déploiement, facilitant les mises à jour, les rollbacks et les évolutions progressives.
- **Lisibilité et maintenabilité** : l’infrastructure applicative devient plus simple à comprendre et à faire évoluer.

Dans le cas de Wiki.js, l’utilisation de Helm n’est pas seulement recommandée : **elle constitue la méthode officielle préconisée par la documentation du projet** pour un déploiement Kubernetes fiable.

## **6.3 Spécificités de Wiki.js et nécessité d’un déploiement contrôlé**

Wiki.js présente une contrainte importante lors de son déploiement : une **phase d’initialisation unique** est requise. Durant cette phase, l’application :
- écrit sa configuration initiale en base de données,
- crée les comptes par défaut,
- initialise les structures internes nécessaires à son fonctionnement.

Si plusieurs instances de Wiki.js sont lancées simultanément avant la fin de cette initialisation, des incohérences peuvent apparaître : conflits de configuration, états divergents entre pods, ou blocages fonctionnels. Ce comportement impose une stratégie de déploiement en deux temps.
Le chart Helm officiel de Wiki.js permet précisément de gérer cette contrainte en séparant :
1. une **phase d’initialisation avec un seul replica** ;
2. une **phase de mise à l’échelle**, une fois l’application correctement configurée.

Cette distinction reflète des pratiques industrielles courantes, où l’on dissocie volontairement le bootstrap applicatif de la phase d’exploitation.

## **6.4 Déploiement de Wiki.js : approche en deux phases**
Le déploiement applicatif de Wiki.js dans ce projet est structuré autour de deux playbooks Ansible distincts.
La première phase correspond à l’**initialisation**. Le chart Helm est déployé avec un fichier `values.yaml` spécifique définissant :
- un seul replica,
- la connexion à la base PostgreSQL externe,
- l’exposition via un Ingress,
- et des paramètres minimaux garantissant un fonctionnement stable    

Cette phase s’arrête volontairement lorsque l’interface web devient accessible, afin de permettre la finalisation manuelle de la configuration via l’assistant graphique.

La seconde phase correspond à la **mise en configuration finale**. Une fois l’initialisation validée, le déploiement est mis à jour avec de nouveaux paramètres : montée en charge, définition des ressources, et activation de l’autoscaling horizontal. Helm permet d’appliquer ces changements sans redéployer l’application depuis zéro.

## **6.5 Partie pratique – Déploiement de Wiki.js avec Helm**
Cette section présente le **workflow réel** utilisé pour déployer Wiki.js sur le cluster Kubernetes précédemment mis en place.

### **Étape 1 – Déploiement initial de Wiki.js (phase d’initialisation)**
```bash
cd ~/devops/ansible
ansible-playbook -i inventory.ini 7-deploy-wikijs-init.yaml
```

Ce playbook automatise les actions suivantes :
- installation de Helm sur le nœud maître (si nécessaire),
- ajout du dépôt officiel `requarks`,
- déploiement du chart Wiki.js avec un fichier `values.yaml` configuré pour un seul replica,
- création du namespace dédié,    
- exposition de l’application via un Ingress.

À l’issue de cette étape, l’interface web de Wiki.js est accessible via l’URL définie :
```
http://wikijs.lab
```

### **Étape 2 – Initialisation de l’application via l’interface web**
L’utilisateur finalise la configuration directement depuis le navigateur :
- **Adresse email administrateur** : `test@gmail.com`
- **Mot de passe** : `azerty123`
- **URL du site** : `http://wikijs.lab`

Cette étape permet de valider la connexion à la base de données, de créer le compte administrateur et d’initialiser l’état applicatif persistant.

### **Étape 3 – Mise à l’échelle et configuration finale**
Une fois l’initialisation terminée, l’application peut être mise à l’échelle.
```bash
ansible-playbook -i inventory.ini 8-deploy-wikijs-scale.yaml
```
Ce playbook applique la configuration finale :
- augmentation du nombre de réplicas,
- définition de ressources CPU/mémoire,
- activation d’un Horizontal Pod Autoscaler (HPA) basé sur l’utilisation CPU.

Grâce à Helm, cette mise à jour est effectuée via une opération d’upgrade, sans interruption majeure du service.

### **Vérification de l’état final**
L’état de l’application et du cluster peut être vérifié à l’aide des commandes suivantes :

```bash
kubectl get pods,svc,ingress,hpa -n wikijs
kubectl top pods -n wikijs
```

Ces commandes permettent de confirmer :
- la présence de plusieurs réplicas,
- le bon fonctionnement de l’Ingress,
- et l’activation effective de l’autoscaling.    


## **6.5 Logique de fonctionnement du cluster – Du navigateur au pod applicatif**

Une fois l’ensemble des composants du cluster Kubernetes déployés et opérationnels, il est essentiel de comprendre **le chemin exact parcouru par une requête utilisateur**, depuis l’accès via un navigateur web jusqu’au conteneur applicatif exécutant Wiki.js. Cette section décrit pas à pas la chaîne de responsabilité des différents composants, en précisant pour chacun **ce qu’il connaît, ce qu’il ne connaît pas, et le rôle qu’il joue dans le traitement de la requête**.

### **Étape 1 – Résolution du nom et accès à l’IP virtuelle**
L’utilisateur accède à l’application via l’URL suivante :
```
http://wikijs.lab
```

Ce nom de domaine est résolu (via le fichier `/etc/hosts` ou un DNS local) vers une **adresse IP virtuelle** :
```
192.168.122.200
```

Cette adresse IP ne correspond à **aucune machine physique ni virtuelle** du cluster. Elle est fournie dynamiquement par **MetalLB**, qui joue le rôle de fournisseur de services de type `LoadBalancer` dans un environnement Kubernetes on-premise.

### **Étape 2 – Rôle de MetalLB : exposition réseau d’un Service**
MetalLB ne distribue **pas** des adresses IP aux pods.  
Il attribue une adresse IP **exclusivement à un objet Kubernetes de type `Service`** configuré en `LoadBalancer`.

Dans ce projet, MetalLB assigne l’adresse `192.168.122.200` au Service suivant :
```
Service ingress-nginx-controller (type LoadBalancer)
```

**Ce que MetalLB connaît :**
- le Service Kubernetes auquel il a attribué une IP,
- la plage d’adresses IP disponibles.

**Ce que MetalLB ne connaît pas :**
- les pods,
- les applications,
- les règles HTTP ou les noms de domaine.

MetalLB se limite strictement à un rôle **réseau (L2/L3)** : rendre un Service Kubernetes accessible depuis l’extérieur du cluster.

### **Étape 3 – Le Service LoadBalancer : distribution vers les pods NGINX**

Le Service `ingress-nginx-controller` agit comme un **point d’entrée réseau** du cluster.  
Il dispose :
- d’une IP virtuelle (MetalLB),
- d’une liste d’**endpoints**, correspondant aux pods NGINX Ingress Controller actuellement disponibles.

Dans ce laboratoire, le contrôleur Ingress NGINX est déployé avec **deux réplicas**, ce qui signifie que le Service LoadBalancer est relié à deux pods NGINX distincts.

**Ce que le Service connaît :**
- la liste dynamique des pods associés (endpoints),
- leurs adresses IP internes (IP de pod).

**Ce que le Service ne connaît pas :**
- le contenu HTTP,
- les règles de routage,
- les applications finales.

À ce stade, le Service effectue un **équilibrage de charge de niveau réseau (L4)** et transmet la requête TCP à l’un des pods NGINX disponibles.

### **Étape 4 – Le contrôleur Ingress NGINX : routage HTTP**

Le pod NGINX Ingress Controller reçoit maintenant la requête HTTP.  
C’est **le premier composant de la chaîne à comprendre le protocole HTTP**.
Le contrôleur Ingress :
- écoute en permanence l’API Kubernetes,
- observe les objets `Ingress`, `Service` et `Endpoints`,
- génère dynamiquement sa configuration NGINX interne.

Dans ce projet, un objet `Ingress` définit une règle de routage :
- **Host** : `wikijs.lab`
- **Service cible** : `wikijs`

Lorsqu’une requête arrive avec l’en-tête HTTP :
```
Host: wikijs.lab
```

le contrôleur NGINX applique la règle correspondante.

**Ce que NGINX connaît :**
- les règles Ingress,
- les Services Kubernetes cibles,
- l’état des endpoints associés aux Services.

**Ce que NGINX ne connaît pas directement :**
- les pods applicatifs individuellement,
- leur charge CPU ou mémoire,
- leur emplacement exact sur les nœuds.

NGINX agit donc comme un **reverse proxy applicatif**, en redirigeant la requête vers le Service Kubernetes approprié.

### **Étape 5 – Le Service applicatif Wiki.js : répartition vers les pods**

Le Service `wikijs` est de type `ClusterIP`.  
Il fournit une **adresse réseau stable interne** pour l’application Wiki.js.

Ce Service connaît :
- la liste des pods Wiki.js actuellement actifs,
- leurs adresses IP internes.

À partir de cette liste, le Service effectue un **équilibrage de charge interne** et redirige la requête vers **l’un des pods Wiki.js** disponibles.

C’est seulement à cette étape que la requête atteint le conteneur applicatif exécutant Wiki.js, qui la traite et génère la réponse HTTP.

### **Chaîne complète de traitement d’une requête**

On peut résumer la logique complète de la façon suivante :

```
Navigateur
   ↓
IP virtuelle MetalLB (192.168.122.200)
   ↓
Service ingress-nginx-controller (LoadBalancer)
   ↓
Pod NGINX Ingress Controller
   ↓
Service wikijs (ClusterIP)
   ↓
Pod Wiki.js
```

Chaque composant agit **selon son périmètre de responsabilité**, sans connaissance globale du système :

- MetalLB gère l’exposition réseau,
- le Service LoadBalancer répartit le trafic réseau,
- NGINX gère le routage HTTP,
- les Services applicatifs assurent la distribution vers les pods,
- les pods exécutent l’application.

Cette séparation stricte des rôles est au cœur de la robustesse et de la scalabilité de Kubernetes.
