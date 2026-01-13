#!/bin/bash
set -euo pipefail

############################
# Config (edit as needed)  #
############################
# IMAGE: The source to pull from (URL is allowed here)
IMAGE="quay.io/russfellows-sig65/io500:latest"
# CONTAINER_NAME: The local name for the running instance (Must be simple, no '/' or ':')
CONTAINER_NAME="io500"

SSH_PORT=2222                         # container sshd port
VM_USER="ubuntu"                      # SSH user for the *hosts* (not containers)
HOSTS=(                               # internal IPs of your 8 VMs
  172.31.49.119
  172.31.59.137
  172.31.58.135
  172.31.50.180
  172.31.57.146
  172.31.56.112
  172.31.54.36
  172.31.55.115
)
RANKS_PER_NODE=8                      # e.g., 8 ranks per VM
# Toggle persistent container host keys (recommended = true)
PERSIST_HOST_KEYS=true
PERSIST_DIR="/opt/io500/sshkeys"      # where to keep host keys on each VM

###############################################
# SSH client options & job-specific knownhosts
###############################################
LAUNCHER_KEY="${HOME}/.ssh/aws-google-keypair.pem"
KNOWN="/opt/io500/mpi_known_hosts"

# Ensure key exists and has correct permissions on the HOST
if [[ ! -f "${LAUNCHER_KEY}" ]]; then
  echo "[Launcher] ERROR: Launcher key ${LAUNCHER_KEY} not found!"
  echo "Please ensure the .pem file is in ~/.ssh/ and named correctly."
  exit 1
fi
chmod 400 "${LAUNCHER_KEY}"

# Generate the Public Key string from the Private PEM (AWS doesn't give you a .pub file)
PUB="$(ssh-keygen -y -f ${LAUNCHER_KEY})"

SSH_OPTS=(
  -o IdentitiesOnly=yes
  -i "${LAUNCHER_KEY}"
  -o UserKnownHostsFile="${KNOWN}"
  -o StrictHostKeyChecking=no
  -o ConnectTimeout=5
)

# Prepare job-specific known_hosts (on launcher VM)
if [ -e "${KNOWN}" ]; then
    sudo rm -rf "${KNOWN}"
fi
sudo mkdir -p "$(dirname "${KNOWN}")"
sudo chown -R $(id -u):$(id -g) "$(dirname "${KNOWN}")"
touch "${KNOWN}"
chmod 600 "${KNOWN}"

############################
# Step 1: start containers #
############################
for H in "${HOSTS[@]}"; do
  echo "[VM ${H}] starting/restarting io500 container..."

  # (optional) persistent host keys on each VM so container host key doesn't change
  if [[ "${PERSIST_HOST_KEYS}" == "true" ]]; then
    ssh "${SSH_OPTS[@]}" "${VM_USER}@${H}" "sudo mkdir -p ${PERSIST_DIR};
      if ! sudo test -f ${PERSIST_DIR}/ssh_host_ed25519_key ; then
        sudo ssh-keygen -t ed25519 -N '' -f ${PERSIST_DIR}/ssh_host_ed25519_key;
        sudo chmod 600 ${PERSIST_DIR}/ssh_host_ed25519_key;
        sudo chmod 644 ${PERSIST_DIR}/ssh_host_ed25519_key.pub;
      fi"
    HOSTKEY_MOUNT="-v ${PERSIST_DIR}:/etc/ssh/keys:ro"
    USE_HOSTKEY='yes'
  else
    HOSTKEY_MOUNT=""
    USE_HOSTKEY='no'
  fi

  # 1a) Start the container as root
  ssh "${SSH_OPTS[@]}" "${VM_USER}@${H}" "sudo docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true;
    sudo docker run -d --name ${CONTAINER_NAME} --restart unless-stopped --network host --user 0:0 \
    -v /mnt/lustre:/mnt/lustre -v /mnt/data:/mnt/data \
    -v /tmp:/tmp ${HOSTKEY_MOUNT} ${IMAGE} bash -lc 'exec sleep infinity'"

  # 1b) Install openssh-server
  ssh "${SSH_OPTS[@]}" "${VM_USER}@${H}" "sudo docker exec -u 0 \
    -e DEBIAN_FRONTEND=noninteractive ${CONTAINER_NAME} bash -lc '
      set -e
      apt-get update -qq
      apt-get install -y -qq --no-install-recommends apt-utils openssh-server openssh-client procps iproute2
      mkdir -p /var/run/sshd /root/.ssh
      chmod 700 /root/.ssh
      rm -f /run/nologin
      rm -rf /var/lib/apt/lists/*
    '"

  # 1c) Configure sshd
  ssh "${SSH_OPTS[@]}" "${VM_USER}@${H}" "sudo docker exec -u 0 ${CONTAINER_NAME} bash -lc 'echo Configuring SSHD...'"

  if [[ "${USE_HOSTKEY}" == "yes" ]]; then
    ssh "${SSH_OPTS[@]}" "${VM_USER}@${H}" "sudo docker exec -u 0 ${CONTAINER_NAME} bash -lc \
      'sed -i \"s|^#\\?HostKey .*||\" /etc/ssh/sshd_config;
       echo \"HostKey /etc/ssh/keys/ssh_host_ed25519_key\" >> /etc/ssh/sshd_config'"
  fi

  ssh "${SSH_OPTS[@]}" "${VM_USER}@${H}" "sudo docker exec -u 0 ${CONTAINER_NAME} bash -lc \
    'sed -i \"s/^#\\?PasswordAuthentication .*/PasswordAuthentication no/\" /etc/ssh/sshd_config;
     sed -i \"s/^#\\?PubkeyAuthentication .*/PubkeyAuthentication yes/\" /etc/ssh/sshd_config;
     sed -i \"s/^#\\?PermitRootLogin.*/PermitRootLogin yes/\" /etc/ssh/sshd_config'"

  # 1d) Start sshd on port 2222
  ssh "${SSH_OPTS[@]}" "${VM_USER}@${H}" "sudo docker exec -u 0 ${CONTAINER_NAME} bash -lc '
    /usr/sbin/sshd -t
    rm -f /run/nologin
    /usr/sbin/sshd -p ${SSH_PORT}
  '"
done

#################################################
# Step 1.5: refresh known_hosts with new keys   #
#################################################
echo "Refreshing ${KNOWN} with current container host keys..."
for H in "${HOSTS[@]}"; do
  ssh-keygen -f "${KNOWN}" -R "[${H}]:${SSH_PORT}" >/dev/null 2>&1 || true
  ssh-keyscan -p "${SSH_PORT}" -t ed25519 "${H}" >> "${KNOWN}" 2>/dev/null || {
    echo "WARN: ssh-keyscan failed for ${H}:${SSH_PORT}"
  }
done

#########################################
# Step 2: install PUBLIC key inside     #
#########################################
echo "Installing launcher public key into each container..."
for H in "${HOSTS[@]}"; do
  ssh "${SSH_OPTS[@]}" "${VM_USER}@${H}" "sudo docker exec -u root ${CONTAINER_NAME} bash -lc '
    install -d -m 700 /root/.ssh;
    echo \"${PUB}\" >> /root/.ssh/authorized_keys;
    chmod 600 /root/.ssh/authorized_keys'"
done

#########################################
# Step 3: quick container SSH test      #
#########################################
echo "Testing SSH into each container as root on port ${SSH_PORT} ..."
for H in "${HOSTS[@]}"; do
  echo -n "[VM ${H}] "
  if ssh "${SSH_OPTS[@]}" -p "${SSH_PORT}" "root@${H}" 'echo OK'; then
    :
  else
    echo "ERROR: SSH to container on ${H} failed"
    exit 1
  fi
done

#########################################
# Step 5: launcher container (idle)     #
#########################################
echo "[Launcher] ensuring local io500 container is up..."

sudo docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true

# Using /tmp for key copy to avoid read-only mount issues
sudo docker run -d --name ${CONTAINER_NAME} --restart unless-stopped --network host \
  -v /mnt/lustre:/mnt/lustre \
  -v /tmp:/tmp \
  -v "${LAUNCHER_KEY}":/tmp/launcher_key:ro \
  -v "${KNOWN}":"${KNOWN}":ro \
  "${IMAGE}" bash -lc 'mkdir -p /root/.ssh; cp /tmp/launcher_key /root/.ssh/id_rsa; chmod 400 /root/.ssh/id_rsa; exec sleep infinity'

echo
echo "=== Setup complete ==="

# --- GENERATE HOSTFILE ---
HOST_FILE="/mnt/lustre/Scripts/ior-hosts.txt"
echo "Generating hostfile at ${HOST_FILE}..."
# Empty the file first
: > "${HOST_FILE}"
for H in "${HOSTS[@]}"; do
  echo "${H} slots=${RANKS_PER_NODE}" >> "${HOST_FILE}"
done

# --- Create a helper script for the full run inside the shared folder ---
RUN_SCRIPT="/mnt/lustre/Scripts/start_io500.sh"
cat > "${RUN_SCRIPT}" <<EOF
#!/bin/bash
# Using --hostfile to run on all nodes listed in ior-hosts.txt
mpirun --hostfile ${HOST_FILE} --mca plm_rsh_agent 'ssh -p 2222 -o StrictHostKeyChecking=no -o IdentitiesOnly=yes' \\
       --use-hwthread-cpus --map-by hwthread --bind-to hwthread --allow-run-as-root \\
       --mca hwloc_base_mem_alloc_policy none --mca hwloc_base_mem_bind_failure_action silent \\
       --mca oob_tcp_if_include 172.31.0.0/16 --mca btl_tcp_if_include 172.31.0.0/16 --mca pml ob1 --mca btl tcp,self \\
       --report-bindings -np $((RANKS_PER_NODE * ${#HOSTS[@]})) \\
       /opt/io500/io500 /mnt/lustre/Scripts/IOR-MDtest.ini
EOF
chmod +x "${RUN_SCRIPT}"

echo "Enter the launcher container:"
echo "  sudo docker exec -it ${CONTAINER_NAME} bash"
echo
echo "Smoke test (1 rank on first node):"
echo "  mpirun --host ${HOSTS[0]} --mca plm_rsh_agent 'ssh -p 2222 -o StrictHostKeyChecking=no -o IdentitiesOnly=yes' -np 1 bash -lc 'hostname; whoami'"
echo
echo "----------------------------------------------------------------"
echo "TO RUN WITH NOHUP (SAFE AGAINST DISCONNECTS):"
echo "Run this command directly from this terminal (outside the container):"
echo
echo "  nohup sudo docker exec ${CONTAINER_NAME} ${RUN_SCRIPT} > /mnt/lustre/Scripts/io500_run.log 2>&1 &"
echo
echo "Then you can disconnect. Tail the log to watch progress:"
echo "  tail -f /mnt/lustre/Scripts/io500_run.log"
echo "----------------------------------------------------------------"
echo
