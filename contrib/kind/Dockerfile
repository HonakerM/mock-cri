# Build from kind as base
ARG IMAGE=kindest/node
ARG VERSION=1.24.7

FROM ${IMAGE}:v${VERSION}

# Install Required Binaries
RUN apt-get update
RUN apt-get install -y \
  libassuan-dev \
  libdevmapper-dev \
  libglib2.0-dev \
  libc6-dev \
  libgpgme11-dev \
  libgpg-error-dev \
  libseccomp-dev \
  libsystemd-dev \
  libbtrfs-dev \
  libselinux1-dev \
  libudev-dev 

# Copy required docker files from crio build
COPY --from=mchonaker/mockcrio:latest /usr/local/lib/systemd/system/crio.service /usr/local/lib/systemd/system/crio.service
COPY --from=mchonaker/mockcrio:latest /usr/local/bin/crio /usr/local/bin/crio
COPY --from=mchonaker/mockcrio:latest /usr/local/bin/crio-status /usr/local/bin/crio-status
COPY --from=mchonaker/mockcrio:latest /usr/local/bin/pinns /usr/local/bin/pinns
COPY --from=mchonaker/mockcrio:latest /usr/local/bin/conmon /usr/local/bin/conmon
COPY --from=mchonaker/mockcrio:latest /etc/crictl.yaml /etc/crictl.yaml
COPY --from=mchonaker/mockcrio:latest /etc/containers/policy.json /etc/containers/policy.json
COPY --from=mchonaker/mockcrio:latest /etc/cni/net.d/10-kindnet.conflist /etc/cni/net.d/10-kindnet.conflist

# Copy crio conf
COPY crio.conf /etc/crio/crio.conf
COPY registries.conf /etc/containers/registries.conf

RUN systemctl disable containerd \
 && systemctl enable crio