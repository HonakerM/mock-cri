echo "building images"
su $1 -c 'make BUILDTAGS=""'

echo "Installing binaries"
sudo make install

echo "restarting crio"
sudo systemctl daemon-reload
sudo service crio restart
