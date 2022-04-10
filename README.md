# cups-airprint

Cups 2.4 server to support Airprint for older printers

## Configuration

### docker-compose

The container can be started via [docker-compose](docker-compose.yml).

Currently, it is required to run the container with `host` network mode to support multicasting for Airprint.
The printer configuration is stored in the volume `/config`:

* `printers.conf`: printer information
* `ppd`: directory for ppd files

Username and password can be configured in the docker-compose file and the `cups_password` secret file (default if no password file: cups/cups).

### Cups setup

The cups frontend is accessible at `http://[host ip]:631`.
For setting up the printer, make sure to enable `Share This Printer`.

It takes some time until cups updates the `printers.conf`, so make sure that the file changed before stopping/restarting the container.

As an alternative to the WebUi, the printers can be also configured via command line, e.g.:

```sh
docker-compose exec cups bash

lpadmin -p bizhub20p -D "KONICA MINOLTA bizhub 20p" -v "http://192.168.24.19:631/ipp" -o printer-is-shared=true -i /ppd/bizhub20p.ppd # file has to be copied/mounted before
cupsenable bizhub20p
cupsaccept bizhub20p
```

### Default paper size

The default paper size is currently set to a4 via `/etc/papersize`. This setting has to be adjusted via the environment variable if you require "Letter".

## Acknowledgements

* <https://github.com/chuckcharlie/cups-avahi-airprint>
* <https://github.com/OpenPrinting/cups/discussions/369>
