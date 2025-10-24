#!/bin/bash

# Function to get workspaces for hyprland
get_hyprland_workspaces() {
    hyprctl monitors -j | jq -r '.[] | "\(.activeWorkspace.name)"'
}

# Detect window manager and get workspaces
get_hyprland_workspaces

exit 1