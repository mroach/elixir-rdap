
fetch:
	test -d priv/iana || mkdir -p priv/iana
	cd priv/iana; curl -O http://data.iana.org/rdap/ipv4.json
