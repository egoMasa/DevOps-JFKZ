# ============================================================
# Terraform – Variables d'environnement (tfvars)
# ------------------------------------------------------------
# Ce fichier contient les valeurs spécifiques à l'infrastructure
# - Contient des SECRETS → ne jamais le publier
# - À exclure du dépôt Git (.gitignore)
# ============================================================

# ------------------------------------------------------------
# Connexion à l'API Proxmox
# ------------------------------------------------------------
# URL complète de l'API Proxmox
# Format : https://<IP_ou_FQDN>:8006
# ------------------------------------------------------------
proxmox_api_url = "https://192.168.122.108:8006"

# ------------------------------------------------------------
# Authentification via token API
# ------------------------------------------------------------
# Format du token ID :
#   <user>@<realm>!<token_name>
# ------------------------------------------------------------
proxmox_token_id = "terraform@pve!provider"

# ------------------------------------------------------------
# Secret du token API
# ------------------------------------------------------------
proxmox_token_secret = "5b66063c-8db3-43e8-a98a-b99affe29ae9"

# ------------------------------------------------------------
# Clé SSH injectée dans les VMs via cloud-init
# ------------------------------------------------------------
# Utilisée pour :
# - accès initial aux VMs
# - automatisation Ansible
# ------------------------------------------------------------
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8iPlirgXN/0JSS/qVpiO+1coIQp866Akv5Ix8G10XR maison"

# ------------------------------------------------------------
# Template Proxmox utilisée pour le clonage
# ------------------------------------------------------------
template_vmid = 9000
