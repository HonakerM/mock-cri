echo "building images"
go build  -trimpath  -ldflags '-s -w -X github.com/cri-o/cri-o/internal/pkg/criocli.DefaultsPath="" -X github.com/cri-o/cri-o/internal/version.buildDate='2022-10-31T17:43:40Z' -X github.com/cri-o/cri-o/internal/version.gitCommit=6abd91c8003aca68d855f45723f0bca4b7a6c260 -X github.com/cri-o/cri-o/internal/version.gitTreeState=clean ' -tags "containers_image_ostree_stub      containers_image_openpgp seccomp selinux " -o bin/crio github.com/cri-o/cri-o/cmd/crio
go build  -trimpath  -ldflags '-s -w -X github.com/cri-o/cri-o/internal/pkg/criocli.DefaultsPath="" -X github.com/cri-o/cri-o/internal/version.buildDate='2022-10-31T17:43:55Z' -X github.com/cri-o/cri-o/internal/version.gitCommit=6abd91c8003aca68d855f45723f0bca4b7a6c260 -X github.com/cri-o/cri-o/internal/version.gitTreeState=clean ' -tags "containers_image_ostree_stub      containers_image_openpgp seccomp selinux " -o bin/crio-status github.com/cri-o/cri-o/cmd/crio-status
cd pinns
cc -o ../bin/pinns src/sysctl.o src/pinns.o -std=c99 -Os -Wall -Werror -Wextra -static
cd ..
 read -t 3 -n 1

echo "Installing binaries"
install -Z -D -m 755 bin/crio /usr/local/bin/crio
install -Z -D -m 755 bin/crio-status /usr/local/bin/crio-status
install -Z -D -m 755 bin/pinns /usr/local/bin/pinns
install -Z -d -m 755 /usr/local/share/man/man5
install -Z -d -m 755 /usr/local/share/man/man8
install -Z -m 644 docs/crio.conf.5 docs/crio.conf.d.5 -t /usr/local/share/man/man5
install -Z -m 644 docs/crio-status.8 docs/crio.8 -t /usr/local/share/man/man8
install -Z -d -m 755 /usr/local/share/bash-completion/completions
install -Z -d -m 755 /usr/local/share/fish/completions
install -Z -d -m 755 /usr/local/share/zsh/site-functions
install -Z -D -m 644 -t /usr/local/share/bash-completion/completions completions/bash/crio
install -Z -D -m 644 -t /usr/local/share/fish/completions completions/fish/crio.fish
install -Z -D -m 644 -t /usr/local/share/zsh/site-functions  completions/zsh/_crio
install -Z -D -m 644 -t /usr/local/share/bash-completion/completions completions/bash/crio-status
install -Z -D -m 644 -t /usr/local/share/fish/completions completions/fish/crio-status.fish
install -Z -D -m 644 -t /usr/local/share/zsh/site-functions  completions/zsh/_crio-status
install -Z -D -m 644 contrib/systemd/crio.service /usr/local/lib/systemd/system/crio.service
install -Z -D -m 644 contrib/systemd/crio-wipe.service /usr/local/lib/systemd/system/crio-wipe.service
install -Z -d /usr/local/share/containers/oci/hooks.d
install -Z -d /etc/crio/crio.conf.d

cat <<<'
[crio.runtime]
spoofed = true
spoof_pass_through = [
    "kube-controller-manager-kind-control-plane",
    "etcd-kind-control-plane",
    "spoofpod",
]
' > crio.conf


install -Z -D -m 644 crio.conf /etc/crio/crio.conf
install -Z -D -m 644 crio-umount.conf /usr/local/share/oci-umount/oci-umount.d/crio-umount.conf
install -Z -D -m 644 crictl.yaml /etc

echo "restarting crio"
sudo systemctl daemon-reload
sudo service crio restart
