# --------- BASE STAGE ---------
FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl wget git python3 python3-pip unzip jq ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /suite

# --------- TRIVY STAGE (SAST/Container scan) ---------
FROM base AS trivy
ENV TRIVY_VERSION=0.50.2
RUN wget -qO- https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz \
    | tar xz -C /usr/local/bin

# --------- SEMGREP STAGE (SAST) ---------
FROM trivy AS semgrep
RUN pip3 install --no-cache-dir --break-system-packages semgrep

# --------- NIKTO STAGE (DAST) ---------
FROM semgrep AS nikto
RUN apt-get update && apt-get install -y nikto && rm -rf /var/lib/apt/lists/*

# --------- FINAL STAGE ---------
FROM nikto AS final

COPY entrypoint.sh /entrypoint.sh
COPY sast/ /suite/sast/
COPY dast/ /suite/dast/
RUN chmod +x /entrypoint.sh /suite/sast/run_sast.sh /suite/dast/run_dast.sh

# Create output folder for artifact mounting
RUN mkdir -p /output

WORKDIR /suite

ENTRYPOINT ["/entrypoint.sh"]

