This is the sourcecode for the webserver component of the Agile Deployment Toolkit. 

The webserver component is able to install Apache, Nginx or Lighttpd.

You can fork the repository and configure Apache, Nginx or Lighttpd in the following files:

** agile-infrastructure-webserver-scripts/providerscripts/webserver/configuration/\\* **  

The webservers have their webroot as **/var/www/html**

There are cron jobs which maintain the functioning and updating of the webserver and which you can modify using crontab -e

A firewall is installed (ufw) allows connections to ports :443 and :80



