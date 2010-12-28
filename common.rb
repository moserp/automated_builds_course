package :mtu do
  noop do
    post :install, 'ifconfig eth0 mtu 1440'
  end
end

