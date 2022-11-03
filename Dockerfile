FROM ubuntu:22.04 as base



RUN apt-get update -qq && apt-get install -y curl gpg

RUN apt-get update -qq && apt-get install -y \
  libbtrfs-dev \
  git \
  golang-go \
  libassuan-dev \
  libdevmapper-dev \
  libglib2.0-dev \
  libc6-dev \
  libgpgme-dev \
  libgpg-error-dev \
  libseccomp-dev \
  libsystemd-dev \
  libselinux1-dev \
  pkg-config \
  go-md2man \
  libudev-dev \
  software-properties-common \
  gcc \
  make \
  runc


FROM base as build

WORKDIR /src

COPY ./pinns /src/pinns

WORKDIR /src/pinns

# pinns build
RUN cc  -O3 -o src/sysctl.o -c src/sysctl.c -std=c99 && \
    cc  -O3 -o src/pinns.o -c src/pinns.c -std=c99 && \
    cc -o ../bin/pinns src/sysctl.o src/pinns.o -std=c99 -Os -Wall -Werror -Wextra -static

# conmon install
WORKDIR /conmon

RUN git clone https://github.com/containers/conmon /conmon && \
    make

WORKDIR /src

COPY . /src

# crio build
RUN go build  -trimpath  -ldflags '-s -w -X github.com/cri-o/cri-o/internal/pkg/criocli.DefaultsPath="" -X github.com/cri-o/cri-o/internal/version.buildDate='2022-10-31T17:43:40Z' -X github.com/cri-o/cri-o/internal/version.gitCommit=6abd91c8003aca68d855f45723f0bca4b7a6c260 -X github.com/cri-o/cri-o/internal/version.gitTreeState=clean ' -tags "containers_image_ostree_stub      containers_image_openpgp seccomp selinux " -o bin/crio github.com/cri-o/cri-o/cmd/crio && \
    go build  -trimpath  -ldflags '-s -w -X github.com/cri-o/cri-o/internal/pkg/criocli.DefaultsPath="" -X github.com/cri-o/cri-o/internal/version.buildDate='2022-10-31T17:43:55Z' -X github.com/cri-o/cri-o/internal/version.gitCommit=6abd91c8003aca68d855f45723f0bca4b7a6c260 -X github.com/cri-o/cri-o/internal/version.gitTreeState=clean ' -tags "containers_image_ostree_stub      containers_image_openpgp seccomp selinux " -o bin/crio-status github.com/cri-o/cri-o/cmd/crio-status



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
COPY --from=build /src/contrib/policy.json /etc/containers/contrib/policy.json
COPY --from=build /src/crictl.yaml /etc

ENTRYPOINT [ "/usr/local/bin/crio" ]