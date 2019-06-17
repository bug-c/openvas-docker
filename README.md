OpenVAS image for Docker
==============


A Docker container for OpenVAS on Ubuntu.  By default, the latest images includes the OpenVAS Base as well as the NVTs and Certs required to run OpenVAS.  


| Openvas Version | Tag     | Web UI Port |
|-----------------|---------|-------------|
| 9               | latest  | 80          |



Usage
-----

Simply run:

```
# latest
docker run -d -p 80:80 --name openvas ctdc/openvas
```

This will grab the container from the docker registry and start it up.  
Openvas startup can take some time (4-5 minutes while NVT's are scanned and databases rebuilt), so be patient.  
Once you see a `It seems like your OpenVAS-9 installation is OK.` process in the logs, the web ui is good to go.  Goto `https://<machinename>`

```
Username: admin
Password: admin
```

To check the status of the process, run:

```
docker top openvas
```

In the output, look for the process scanning cert data.  It contains a percentage.

To run bash inside the container run:

```
docker exec -it openvas bash
```

#### Specify DNS Hostname
By default, the system only allows connections for the hostname "openvas".  To allow access using a custom DNS name, you must use this command:

```
docker run -d -p 80:80 -e PUBLIC_HOSTNAME=myopenvas.example.org --name openvas ctdc/openvas
```

#### OpenVAS Manager
To use OpenVAS Manager, add port `9390` to you docker run command:
```
docker run -d -p 80:80 -p 9390:9390 --name openvas ctdc/openvas
```

#### Volume Support
We now support volumes. Simply mount your data directory to `/var/lib/openvas/mgr/`:
```
mkdir data
docker run -d -p 80:80 -v $(pwd)/data:/var/lib/openvas/mgr/ --name openvas ctdc/openvas
```
Note, your local directory must exist prior to running.

#### Set Admin Password
The admin password can be changed by specifying a password at runtime using the env variable `OV_PASSWORD`:
```
docker run -d -p 80:80 -e OV_PASSWORD=securepassword41 --name openvas ctdc/openvas
```
#### Update NVTs
Occasionally you'll need to update NVTs. We update the container about once a week but you can update your container by execing into the container and running a few commands:
```
docker exec -it openvas bash
## inside container
greenbone-nvt-sync
openvasmd --rebuild --progress
greenbone-certdata-sync
greenbone-scapdata-sync
openvasmd --update --verbose --progress

/etc/init.d/openvas-manager restart
/etc/init.d/openvas-scanner restart
```
#### Docker compose (experimental)

For simplicity a docker-compose.yml file is provided, as well as configuration for Nginx as a reverse proxy, with the following features:

* Nginx as a reverse proxy
* Redirect from port 80 (http) to port 433 (https)
* Automatic SSL certificates from [Let's Encrypt](https://letsencrypt.org/)
* A cron that updates daily the NVTs

To run:

* Change "example.com" in the following files:
  * [docker-compose.yml](docker-compose.yml)
  * [conf/nginx.conf](conf/nginx.conf)
  * [conf/nginx_ssl.conf](conf/nginx_ssl.conf)
* Change the "OV_PASSWORD" enviromental variable in [docker-compose.yml](docker-compose.yml)
* Install the latest [docker-compose](https://docs.docker.com/compose/install/)
* run `docker-compose up -d`

#### LDAP Support (experimental)
Openvas do not support full ldap integration but only per-user authentication. A workaround is in place here by syncing ldap admin user(defined by `LDAP_ADMIN_FILTER `) with openvas admin users everytime the app start up.  To use this, just need to specify the required ldap env variables:
```
docker run -d -p 80:80 -p 9390:9390 --name openvas -e LDAP_HOST=your.ldap.host -e LDAP_BIND_DN=uid=binduid,dc=company,dc=com -e LDAP_BASE_DN=cn=accounts,dc=company,dc=com -e LDAP_AUTH_DN=uid=%s,cn=users,cn=accounts,dc=company,dc=com -e LDAP_ADMIN_FILTER=memberOf=cn=admins,cn=groups,cn=accounts,dc=company,dc=com -e LDAP_PASSWORD=password -e OV_PASSWORD=admin ctdc/openvas 
```

#### Email Support
To configure the postfix server, provide the following env variables at runtime: `OV_SMTP_HOSTNAME`, `OV_SMTP_PORT`, `OV_SMTP_USERNAME`, `OV_SMTP_KEY`
```
docker run -d -p 80:80 -e OV_SMTP_HOSTNAME=smtp.example.com -e OV_SMTP_PORT=587 -e OV_SMTP_USERNAME=username@example.com -e OV_SMTP_KEY=g0bBl3de3Go0k --name openvas ctdc/openvas
```


Contributing
------------

I'm always happy to accept [pull requests](https://github.com/ctdc/openvas-docker/pulls) or [issues](https://github.com/ctdc/openvas-docker/issues).

Thanks
------

Thanks to mikesplain from where we forked the openvas-docker  : https://github.com/mikesplain/openvas-docker/
Thanks to Darshana for the great tutorial: https://www.fosslinux.com/7320/how-to-install-and-configure-openvas-9-on-ubuntu.htm
