#!/bin/bash

#Script para desbloquear e apagar VM

# Array of specific VM IDs to remove
locked_vms=(99 100 101 102 103 104 105 200 199)

# Function to check and unlock VMs
unlock_vm() {
    local vmid=$1
    echo "Unlocking VM ID: $vmid"
    if ! qm unlock $vmid; then
        echo "Failed to unlock VM ID: $vmid. Skipping removal."
        return 1
    fi
}

# Function to remove disks associated with a VM
remove_disks() {
    local vmid=$1
    echo "Removing disks for VM ID: $vmid"
    local disks=$(qm config $vmid | grep -oP 'virtio\d+: \K[^,]+')
    for disk in $disks; do
        if [[ $disk == *"vm-$vmid"* ]]; then
            echo "Removing disk: $disk"
            if ! qm disk-remove $vmid $disk --force; then
                echo "Failed to remove disk $disk for VM ID: $vmid. Please check manually."
            fi
        fi
    done
}

# Function to remove VM with its disks and configurations
remove_vm() {
    local vmid=$1
    remove_disks $vmid
    echo "Removing VM ID: $vmid with configurations"
    if ! qm destroy $vmid --purge --destroy-unreferenced-disks; then
        echo "Failed to remove VM ID: $vmid. Please check the logs for details."
        return 1
    fi
}

# Iterate over each specified VM ID and unlock it before removing
for vmid in "${locked_vms[@]}"; do
    if unlock_vm $vmid; then
        if remove_vm $vmid; then
            echo "VM ID: $vmid removed successfully."
        fi
    fi
    echo "---"
done

echo "Process completed."
