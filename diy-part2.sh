#!/bin/bash

git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

mkdir -p files/etc/config
cat > files/etc/config/system <<EOF
config system
    option hostname 'OpenWrt-K2P'
    option timezone 'CST-8'
    option zonename 'Asia/Shanghai'
EOF

mkdir -p files/etc/smartdns
cat > files/etc/smartdns/smartdns.conf <<EOF
server 223.5.5.5
server 114.114.114.114
server-tls 1.12.12.12

speed-check-mode ping,tcp:80
cache-size 2048
prefetch-domain yes
serve-expired yes
dualstack-ip-selection yes
EOF

cat > files/etc/config/smartdns <<EOF
config smartdns
    option enabled '1'
    option port '6053'
    option auto_set_dnsmasq '1'
EOF

cat > files/etc/config/dhcp <<EOF
config dnsmasq
    option noresolv '1'
    option server '127.0.0.1#6053'
EOF

mkdir -p files/etc/init.d
cat > files/etc/init.d/adblock_update <<'EOF'
#!/bin/sh /etc/rc.common
START=99

start() {

mkdir -p /etc/dnsmasq.d

wget -O /tmp/ad1.txt https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts
wget -O /tmp/ad2.txt https://raw.githubusercontent.com/vokins/yhosts/master/hosts
wget -O /tmp/video.txt https://raw.githubusercontent.com/banbendalao/ADgk/master/ADgk.txt

cat /tmp/ad1.txt /tmp/ad2.txt | \
grep "0.0.0.0" | \
awk '{print "address=/"$2"/0.0.0.0"}' \
> /etc/dnsmasq.d/adblock.conf

grep "^||" /tmp/video.txt | \
sed 's/^||//' | sed 's/\^//' | \
awk '{print "address=/"$1"/0.0.0.0"}' \
>> /etc/dnsmasq.d/adblock.conf

/etc/init.d/dnsmasq restart
}
EOF

chmod +x files/etc/init.d/adblock_update

mkdir -p files/etc/crontabs
cat > files/etc/crontabs/root <<EOF
0 4 * * 0 /etc/init.d/adblock_update restart
EOF