# 使用说明

一个简单的基于tproxy的网关镜像，需要配合可以提供透明代理的服务进行配置。
本镜像可以作为网关使用，使用iptables将经过的流量自动转发到相关的TPROXY服务接口上。
详细配置可以参考`docker-compose.yaml`

## 虚拟子网络
作为网关需要独立的ip地址，*必须*使用[macvlan](https://uefeng.com/docker-macvlan.html)（推荐）设立新的容器ip。

macvlan要求宿主机的网卡设为[混杂模式](https://zdyxry.github.io/2020/03/18/%E7%90%86%E8%A7%A3%E7%BD%91%E5%8D%A1%E6%B7%B7%E6%9D%82%E6%A8%A1%E5%BC%8F/)。
```bash
ifconfig eno1 promisc
```

如果需要和宿主机可以互相访问，需要在宿主机的`/etc/network/interfaces`中增加相应的配置，并重启。（或者先运行一下其中的相关的ip命令）
```
# The primary network interface
allow-hotplug eno1
# iface eno1 inet dhcp
iface eno1 inet static
	  address 10.128.0.2
	  netmask 255.255.255.0
	  gateway 10.128.0.1
	  # Create new macvlan interface on the host
	  up ip link add mac32 link eno1 type macvlan mode bridge
	  # Add the host address and bring up the interface
	  up ip addr add 10.128.0.31 dev mac32
	  up ip link set mac32 up
	  # Tell our host to use that interface to communicate with containers
	  up ip route add 10.128.0.32/27 dev mac32
```

注意在`ip addr add 10.128.0.31 dev mac32`中配置一个新的不在macvlan网段中的ip。如在docker-compose.yaml中macvlan使用`10.128.0.32/27`网段(10.128.0.32-10.128.0.63), 所以在宿主机配置的macvlan ip地址为10.128.0.31。

## 如何设置网关
根据主路由的支持方式，根据路由有两种方式将镜像容器设置为网关

1. 在主路由器中的网关地址设置为容器ip地址（如果使用host mode则为宿主机地址）
2. 如果主路由器无法设置网关地址，则需要配置[adguard](https://hub.docker.com/r/adguard/adguardhome)或[dnsmasq](https://hub.docker.com/r/dockurr/dnsmasq)等支持dhcpd的服务，并配置为局域网中的dhcpd服务，将路由器中的dhcpd服务关闭掉。

## TPORXY服务（必需）
镜像本身不提供TPROXY服务，需要配合提供TPROXY服务的镜像一起使用。
并将tproxy服务容器的network_mode设置为`network_mode: "service:gateway"`
其中gateway为本镜像容器的服务名。

## DNS服务
镜像本身不提供DNS服务，可以配合提供DNS服务的镜像一起使用。（可选）
如果不设置dns服务，由于android手机会强制将8.8.8.8设置为手机的主dns，有可能会导致局域网中的android手机的ip查询失败。

## 配置环境变量

### TPROXY_PORT(必需)
设置为提供TPROXY服务的TPROXY服务端口，所有未被排除的tcp/udp流量均会被转发到这一端口。如果tproxy端口失效，则网络内所有机器均无法连接互联网。

### DNS_PORT(可选)
设置为提供DNS服务的DNS服务端口。需要保证相关的dns服务返回正确的ip地址，否则域名解析错误的网站无法连接。

### DIVERT_SOCKET(默认开启)
开启这一选项，会跳过已建立连接的socket流量，不进行流量转发。如果发现网站可访问性不稳定，可以尝试关闭(`DIVERT_SOCKET=false`)

### 流量排除选项
服务默认会排除所有[局域网内流量](https://zh-m-wikipedia-org.translate.goog/zh-cn/%E4%BF%9D%E7%95%99IP%E5%9C%B0%E5%9D%80?_x_tr_sl=zh-CN&_x_tr_tl=en&_x_tr_hl=en&_x_tr_pto=sc)不不进行流量转发。使用环境变量设置可以配置更多排除的ip地址

以下环境变量可以使用url(http/https开头)或本地文件地址进行设置。并使用';'进行分隔。

如 NET_DST_V4='http://www.ipdeny.com/ipblocks/data/countries/cn.zone;/root/config/bypass_ips'
则会将`http://www.ipdeny.com/ipblocks/data/countries/cn.zone`及`/root/config/bypass_ips`中的地址都进行解析后加入到需要排除的流量中。

#### NET_DST_V4
支持列表文件url或容器中本地列表文件，文件中每行为一个排除的网段, 当目的地ip命中其中的网段时则不进行流量转发。文件中格式如以下样例：
```
14.1.64.0/19
27.100.36.0/22
```

#### MAC_SRC_V4
支持列表文件url或容器中本地列表文件，文件中每行为一个MAC地址, 当来源命中其中的mac地址时则不进行流量转发，适合用于排除局域网中特定的设备。文件中格式如以下样例：

```
00:0A:02:0B:03:0C
01:0A:02:0B:03:0C
```


ENJOY!
