#!/bin/bash

# === CONFIGURATION ===

# !!! IMPORTANT !!!
# Replace "YOUR_USERNAME" with the username you use to SSH into your VMs.
# (This is often your Google Cloud username, e.g., 'johndoe').
SSH_USER="jfellows"

# List of your 8 VM IP addresses
HOST_IPS=(
            "10.138.0.42"
                "10.138.0.29"
                    "10.138.0.30"
                        "10.138.0.31"
                            "10.138.0.32"
                                "10.138.0.33"
                                    "10.138.0.37"
                                        "10.138.0.39"
                                )

                                # The command to execute on each remote host
                                CMD_TO_RUN="sudo /sbin/sysctl vm.drop_caches=3"

                                # === EXECUTION ===

                                echo "Connecting to all 8 hosts in PARALLEL to drop caches..."
                                echo "--------------------------------------------"

                                for IP in "${HOST_IPS[@]}"; do
                                            echo "--- Launching command for $IP (in background) ---"
                                                
                                                # -T disables pseudo-terminal allocation
                                                    # -n prevents reading from stdin (which can mess up loops)
                                                        # The '&' at the end runs this command in the background,
                                                            # allowing the loop to continue to the next IP immediately.
                                                                ssh -T -n ${SSH_USER}@${IP} "${CMD_TO_RUN}" &
                                                                    
                                                        done

                                                        echo
                                                        echo "--- Waiting for all background commands to complete ---"

                                                        # The 'wait' command pauses the script here until ALL background
                                                        # jobs (the 8 SSH commands) have finished.
                                                        wait

                                                        echo "--------------------------------------------"
                                                        echo "Cache drop command sent to all hosts."
