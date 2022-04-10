FROM debian:testing-slim

RUN apt-get update && apt-get install --no-install-recommends -y \
	avahi-daemon \
	colord \
	cups-pdf \
	foomatic-db-compressed-ppds \
	inotify-tools

EXPOSE 631
VOLUME /config

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen *:631/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

COPY start.sh detect-changes.sh /

CMD ["/start.sh"]
