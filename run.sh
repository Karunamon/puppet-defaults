#Make sure Puppet is available
which puppet
if [ $? != 0 ]; then
  echo "Puppet is not available. Please install it before continuing."
  exit 1
fi

sed -i "s/REPLACEME/$(whoami)/g" ./default.pp
echo "Injected $(whoami) into manifest"

#Install modules
puppet module install puppetlabs/vcsrepo

echo "Initiating puppet run!"
puppet apply './default.pp'
