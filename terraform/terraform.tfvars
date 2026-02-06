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
proxmox_token_secret = "9ceb8af8-538e-41a5-b80e-f025e0057ea3"

# ------------------------------------------------------------
# Clé SSH injectée dans les VMs via cloud-init
# ------------------------------------------------------------
# Utilisée pour :
# - accès initial aux VMs
# - automatisation Ansible
# ------------------------------------------------------------
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMC5gaOBZq5n0LPPd80r5SzpdzZ209Dl2QI3ZuyUsrsx jeremy@omen"

# ------------------------------------------------------------
# Template Proxmox utilisée pour le clonage
# ------------------------------------------------------------
template_vmid = 9000
