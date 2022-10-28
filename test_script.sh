echo "building images"
go build  -trimpath  -ldflags '-s -w -X github.com/cri-o/cri-o/internal/pkg/criocli.DefaultsPath="" -X github.com/cri-o/cri-o/internal/version.buildDate='2022-10-28T18:45:45Z' -X github.com/cri-o/cri-o/internal/version.gitCommit=d089da942be6c9cb9ddaa5e455631ad997b8bb9a -X github.com/cri-o/cri-o/internal/version.gitTreeState=clean ' -tags "" -o bin/crio github.com/cri-o/cri-o/cmd/crio
go build  -trimpath  -ldflags '-s -w -X github.com/cri-o/cri-o/internal/pkg/criocli.DefaultsPath="" -X github.com/cri-o/cri-o/internal/version.buildDate='2022-10-28T18:45:52Z' -X github.com/cri-o/cri-o/internal/version.gitCommit=d089da942be6c9cb9ddaa5e455631ad997b8bb9a -X github.com/cri-o/cri-o/internal/version.gitTreeState=clean ' -tags "" -o bin/crio-status github.com/cri-o/cri-o/cmd/crio-status
make -C pinns
./bin/crio -d "" --config=""  config > crio.conf


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
install -Z -D -m 644 crio.conf /etc/crio/crio.conf
install -Z -D -m 644 crio-umount.conf /usr/local/share/oci-umount/oci-umount.d/crio-umount.conf
install -Z -D -m 644 crictl.yaml /etc

echo "restarting crio"
sudo systemctl daemon-reload
sudo service crio restart
