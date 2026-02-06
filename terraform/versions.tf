# ============================================================
# Terraform – Versions & Providers
# ------------------------------------------------------------
# Objectif :
# - Verrouiller les versions pour garantir la reproductibilité
# - Éviter les changements de comportement involontaires
# ============================================================

terraform {
  # ----------------------------------------------------------
  # Version minimale de Terraform requise
  # ----------------------------------------------------------
  # On force Terraform >= 1.5.0 pour :
  # - bénéficier des dernières améliorations du langage
  # - assurer la compatibilité avec le provider Proxmox bpg
  # ----------------------------------------------------------
  required_version = ">= 1.5.0"

  # ----------------------------------------------------------
  # Providers requis par le projet
  # ----------------------------------------------------------
  required_providers {
    proxmox = {
      # Provider communautaire maintenu activement
      # Remplacement moderne de telmate/proxmox
      source  = "bpg/proxmox"

      # Version verrouillée :
      # - évite les breaking changes
      # - garantit un comportement stable en production
      version = "~> 0.90.0"
    }
  }
}
