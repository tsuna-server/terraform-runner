FROM ubuntu:24.04
LABEL maintainer="Tsutomu Nakamura<tsuna.0x00@gmail.com>"

COPY motd.sh /root/.motd.sh
SHELL ["/bin/bash", "-c"]
RUN \
    # Set up motd \
    chmod 755 /root/.motd.sh && \
    echo "\${HOME}/.motd.sh" >> /root/.bashrc && \
    # Install fundemental packages \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl vim unzip gnupg software-properties-common wget jq apt-transport-https && \
    # Prepare repositories \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list && \
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    # Install packages of docker and terraform \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin terraform && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    # Prepare sops \
    curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64" && \
    mv cosign-linux-amd64 /usr/local/bin/cosign && \
    chmod +x /usr/local/bin/cosign && \
    LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ") && \
    curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_amd64.deb" && \
    dpkg -i cosign_${LATEST_VERSION}_amd64.deb && \
    curl -LO https://github.com/getsops/sops/releases/download/v3.9.0/sops-v3.9.0.linux.amd64 && \
    mv sops-v3.9.0.linux.amd64 /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops && \
    # Install kubectl \
    # https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    chmod 644 /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y kubectl && \
    # Install helm \
    bash <(curl -o- https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3) && \
    # Clean up \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

