
default: all

uninstall:
	rm -rf /usr/local/etc/openvpn
	rm -rf /etc/rc.conf.d/openvpn
	rm -rf /usr/local/etc/rc.d/openvpn
	#sed -i'' -e "/transmissionvpn.*/d" /etc/rc.conf

all: requirements install

requirements:
	pkg update
	pkg fetch -u -y
	pkg upgrade -y
	pkg install -y openvpn python3 wget jq

install:
	service transmission stop

	cp -R ./app_root/* /
	chmod +x /usr/local/etc/rc.d/openvpn
	chmod +x /usr/local/etc/openvpn/scripts/*.sh

	@clear
	@echo "Enter your OpenVPN username and press [ENTER]:" ; \
	read USERNAME ; \
	echo $$USERNAME > /usr/local/etc/openvpn/credentials

	@printf "Enter your OpenVPN password and press [ENTER]: \n"; \
	stty -echo; \
	read PASSWORD; \
	stty echo; \
	echo $$PASSWORD >> /usr/local/etc/openvpn/credentials

	chmod 600 /usr/local/etc/openvpn/credentials

	@clear
	@echo -e "\nVPN service's username and password written to the '/usr/local/etc/openvpn/credentials' file."
	@echo -e "PLEASE BE AWARE:  These are written out in plain text.\n\n"

	@echo "Installation complete. The service will automatically connect to a NordVPN TCP P2P capable"
	@echo "host and start Transmision. In case you want to use another provider or server, just replace the"
	@echo -e "'/usr/local/etc/openvpn/client.conf' file.\n\n"

	@echo "You can now launch OpenVPN + Transmission manually by running:"
	@echo -e "\n     service transmissionvpn start\n\n"

	@echo -e "To stop Transmission and OpenVPN, run:"
	@echo -e "\n     service transmissionvpn stop\n\n"

	@echo "Enjoy!"
