
default: all

uninstall:
	rm -rf /opt/transmissionvpn
	rm -rf /usr/local/etc/rc.d/transmissionvpn
	sed -i'' -e "/transmissionvpn.*/d" /etc/rc.conf

all: requirements install

requirements:
	pkg update
	pkg fetch -u -y
	pkg upgrade -y
	pkg install -y openvpn python3 wget jq

install:
	-@[ -d "/opt/transmissionvpn" ] && rm -rf /opt/transmissionvpn
	mkdir -p /opt/transmissionvpn

	cp -r ./app_root/* /opt/transmissionvpn
	chmod +x /opt/transmissionvpn/*.sh

	cp ./rc.d/transmissionvpn /usr/local/etc/rc.d/transmissionvpn
	chmod +x /usr/local/etc/rc.d/transmissionvpn

	# Make sure 'transmissionvpn' service is enabled
	grep -q 'transmissionvpn_enable=' /etc/rc.conf \
	        && (sed -i -e 's/^transmissionvpn_enable.*/transmissionvpn_enable=\"YES\"/' /etc/rc.conf) \
	        || (echo 'transmissionvpn_enable="YES"' >> /etc/rc.conf)

	@clear
	@echo "Enter your OpenVPN username and press [ENTER]:" ; \
	read USERNAME ; \
	sed -i'' -e "s/username/$$USERNAME/" /opt/transmissionvpn/openvpn/credentials

	@printf "Enter your OpenVPN password and press [ENTER]: \n"; \
	stty -echo; \
	read PASSWORD; \
	stty echo; \
	sed -i'' -e "s/password/$$PASSWORD/" /opt/transmissionvpn/openvpn/credentials

	@clear
	@echo -e "\nVPN service's username and password written to the '/opt/transmissionvpn/openvpn/credentials' file."
	@echo -e "PLEASE BE AWARE:  These are written out in plain text.\n\n"

	@echo "Installation complete. The service will automatically connect to a NordVPN TCP P2P capable"
	@echo "host and start Transmision. In case you want to use another provider or server, just replace the"
	@echo -e "'/opt/transmissionvpn/openvpn/openvpn.conf' file.\n\n"

	@echo "You can now launch OpenVPN + Transmission manually by running:"
	@echo -e "\n     service transmissionvpn start\n\n"

	@echo -e "To stop Transmission and OpenVPN, run:"
	@echo -e "\n     service transmissionvpn stop\n\n"

	@echo "Enjoy!"
