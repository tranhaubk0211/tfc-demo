# sentinel.hcl

policy "cost-limit" {
  source            = "./cost-limit.sentinel"
  enforcement_level = "soft-mandatory" 
  # Soft-mandatory lets authorized organization managers override the block with a justification note.
}
