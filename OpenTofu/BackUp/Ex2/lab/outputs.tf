output virtual_machine_private_key {
  value       = module.virtual_machine.virtual_machine_private_key
  sensitive   = true
  description = "The private key assigned to the virtual machine."
  depends_on  = [
    module.virtual_machine
  ]
}