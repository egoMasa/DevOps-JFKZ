# ============================================================
# Terraform – Variables globales
# ------------------------------------------------------------
# Ce fichier centralise :
# - la configuration Proxmox
# - les paramètres réseau
# - les paramètres VM
# ============================================================

# ============================================================
# PROXMOX – API & AUTHENTIFICATION
# ============================================================

variable "proxmox_api_url" {
  type        = string
  description = "URL complète de l'API Proxmox (ex: https://ip:8006)"
}

variable "proxmox_token_id" {
  type        = string
  description = "ID du token API Proxmox (format: user@realm!token)"
}

variable "proxmox_token_secret" {
  type        = string
  description = "Secret associé au token API Proxmox"
  sensitive   = true        # Empêche l'affichage en clair dans les logs Terraform
}

# ============================================================
# PROXMOX – NODE & TEMPLATE
# ============================================================

variable "proxmox_node" {
  type        = string
  default     = "proxmox"
  description = "Nom du node Proxmox cible où seront créées les VMs"
}

variable "template_vmid" {
  type        = number
  default     = 9000
  description = "VMID de la template Proxmox utilisée pour le clonage"
}

# ============================================================
# VMs – IDENTITÉ & NOMBRE
# ============================================================

variable "vmid_start" {
  type        = number
  default     = 9100
  description = "VMID de départ pour la première VM créée"
}

variable "worker_count" {
  type        = number
  default     = 2
  description = "Nombre de nœuds Kubernetes workers à créer"
}

variable "vm_name_prefix" {
  type        = string
  default     = "tf-vm"
  description = "Préfixe commun pour le nom des VMs"
}

# ============================================================
# RÉSEAU – ADRESSAGE IP STATIQUE
# ============================================================

variable "vm_ip_base" {
  type        = string
  default     = "192.168.122."
  description = "Base du réseau IP (sans le dernier octet)"
}

variable "vm_ip_start" {
  type        = number
  default     = 150
  description = "Dernier octet IP de la première VM"
}

variable "vm_cidr" {
  type        = number
  default     = 24
  description = "Masque CIDR du réseau (ex: /24)"
}

variable "vm_gateway" {
  type        = string
  default     = "192.168.122.1"
  description = "Passerelle réseau par défaut"
}

variable "vm_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Bridge réseau Proxmox utilisé par les VMs"
}

# ============================================================
# SSH – ACCÈS & AUTOMATISATION
# ============================================================

variable "ssh_public_key" {
  type        = string
  description = "Clé SSH publique injectée via cloud-init dans les VMs"
}
