FROM centos:centos7 as base

RUN yum install -y \
  containers-common \
  iptables-service \
  device-mapper-devel \
  wget \
  git \
  gcc \
  glib2-devel \
  glibc-devel \
  glibc-static \
  gpgme-devel \
  libassuan-devel \
  libgpg-error-devel \
  libseccomp-devel \
  btrfs-progs-devel \
  libselinux-devel \
  pkgconfig \
  make \
  runc

RUN  wget https://go.dev/dl/go1.19.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz && \
    rm -rf go1.19.2.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

FROM base as build

WORKDIR /src

COPY . /src

# crio build
RUN go build  -trimpath  -ldflags '-s -w -X github.com/cri-o/cri-o/internal/pkg/criocli.DefaultsPath="" -X github.com/cri-o/cri-o/internal/version.buildDate='2022-10-31T17:43:40Z' -X github.com/cri-o/cri-o/internal/version.gitCommit=6abd91c8003aca68d855f45723f0bca4b7a6c260 -X github.com/cri-o/cri-o/internal/version.gitTreeState=clean ' -tags "containers_image_ostree_stub      containers_image_openpgp seccomp selinux " -o bin/crio github.com/cri-o/cri-o/cmd/crio && \
    go build  -trimpath  -ldflags '-s -w -X github.com/cri-o/cri-o/internal/pkg/criocli.DefaultsPath="" -X github.com/cri-o/cri-o/internal/version.buildDate='2022-10-31T17:43:55Z' -X github.com/cri-o/cri-o/internal/version.gitCommit=6abd91c8003aca68d855f45723f0bca4b7a6c260 -X github.com/cri-o/cri-o/internal/version.gitTreeState=clean ' -tags "containers_image_ostree_stub      containers_image_openpgp seccomp selinux " -o bin/crio-status github.com/cri-o/cri-o/cmd/crio-status

WORKDIR /src/pinns

# pinns build
RUN cc  -O3 -o src/sysctl.o -c src/sysctl.c -std=c99 && \
    cc  -O3 -o src/pinns.o -c src/pinns.c -std=c99 && \
    cc -o ../bin/pinns src/sysctl.o src/pinns.o -std=c99 -Os -Wall -Werror -Wextra -static

# conmon install
WORKDIR /conmon

RUN git clone https://github.com/containers/conmon /conmon && \
    make

# crio config gen
WORKDIR /src
RUN ./bin/crio -d "" --config=""  config > crio.conf

FROM base as release

# binaries
COPY --from=build /src/bin/crio /usr/local/bin/crio
COPY --from=build /src/bin/crio-status /usr/local/bin/crio-status
COPY --from=build /src/bin/pinns /usr/local/bin/pinns
COPY --from=build /conmon/bin/conmon /usr/local/bin/conmon

# config
COPY --from=build /src/crio.conf /etc/crio/crio.conf
COPY --from=build /src/contrib/systemd/crio.service /usr/local/lib/systemd/system/crio.service
COPY --from=build /src/crictl.yaml /etc

ENTRYPOINT [ "/usr/local/bin/crio" ]