
default: install

requirements:
	pkg update
	pkg fetch -u -y
	pkg upgrade -y
	pkg install -y expect openvpn python3 wget

all: requirements fix_permissions install

install: 
	cp ./scripts/rc.d.sh /usr/local/etc/rc.d/transmissionvpn
	cp /etc/rc.conf ./rc.conf.backup
	-@service transmission stop
	cp /etc/rc.conf /etc/rc.conf.backup

	# Make sure 'transmission' service is enabled
	grep -q 'transmission_enable=' /etc/rc.conf \
		&& (sed -i -e 's/^transmission_enable.*/transmission_enable=\"YES\"/' /etc/rc.conf) \
		|| (echo 'transmission_enable="YES"' >> /etc/rc.conf)

	# Make sure 'transmissionvpn' service is enabled
	grep -q 'transmissionvpn_enable=' /etc/rc.conf \
		&& (sed -i -e 's/^transmissionvpn_enable.*/transmissionvpn_enable=\"YES\"/' /etc/rc.conf) \
		|| (echo 'transmissionvpn_enable="YES"' >> /etc/rc.conf)

	-@service transmission start
	-@while ! [ -e '/var/run/transmission/daemon.pid' ]; do\
					sleep 1;\
	done

	-@service transmission stop
	-@while [ -e '/var/run/transmission/daemon.pid' ]; do\
					sleep 1;\
	done

	mkdir -p /opt/transmissionvpn/
	mkdir /opt/transmissionvpn/scripts
	mkdir /opt/transmissionvpn/openvpn

	cp -r scripts/ /opt/transmissionvpn/scripts
	cp stop.sh /opt/transmissionvpn/

	@echo "Enter your OpenVPN username and press [ENTER]:" ; \
																	read username ; \
																	echo "Enter your OpenVPN password and press [ENTER]:" ; \
																	read password ; \
																	sed s/USERNAME/$$username/ run.sh.template | sed s/PASSWORD/$$password/ > /opt/transmissionvpn/run.sh

	chmod +x /opt/transmissionvpn/run.sh


	@clear
	@echo -e "\nUsername and password written to the OpenVPN running script, run.sh."
	@echo -e "PLEASE BE AWARE:  These are written out in plain text.\n\n"
	@echo "Configuration complete.  OpenVPN has been installed.  It will automatically connect on boot and start Transmision."
	@echo "You will still need to download your provider's openvpn.conf and associated keys."
	@echo "Place openvpn.conf and the keys into ./openvpn.  One this is done, you can launch OpenVPN and Transmission by running:"
	@echo -e "\n     /etc/rc.d/transmissionvpn start\n\nTo stop Transmission and OpenVPN, run:\n\n     /etc/rc.d/transmissionvpn stop\n\n"
	@echo "Enjoy!"

fix_permissions:
	chmod +x *.sh
	chmod +x scripts/*.sh
