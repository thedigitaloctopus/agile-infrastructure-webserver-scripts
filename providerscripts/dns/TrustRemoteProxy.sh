#!/bin/bash

if ( [ -f ${HOME}/.ssh/DNSCHOICE:cloudflare ] )
then
    if ( [ -f ${HOME}/.ssh/WEBSERVERCHOICE:NGINX ] )
    then
        CLOUDFLARE_FILE_PATH=/etc/nginx/cloudflare

        /bin/echo "#Cloudflare" > $CLOUDFLARE_FILE_PATH;
        /bin/ echo "" >> $CLOUDFLARE_FILE_PATH;
        
        /bin/echo "" >> $CLOUDFLARE_FILE_PATH;
        /bin/echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_FILE_PATH;
        
        /bin/echo "# - IPv4" >> $CLOUDFLARE_FILE_PATH;
        for i in `curl https://www.cloudflare.com/ips-v4`; do
            /bin/echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
        done

        /bin/echo "" >> $CLOUDFLARE_FILE_PATH;
        /bin/echo "# - IPv6" >> $CLOUDFLARE_FILE_PATH;
        for i in `curl https://www.cloudflare.com/ips-v6`; do
            /bin/echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
        done


    fi
    
    if ( [ -f ${HOME}/.ssh/WEBSERVERCHOICE:APACHE ] )
    then
        CLOUDFLARE_FILE_PATH=/etc/apache2/conf-available/remoteip.conf

        /bin/echo "#Cloudflare" > $CLOUDFLARE_FILE_PATH;
        /bin/ echo "" >> $CLOUDFLARE_FILE_PATH;
    
        /bin/echo "" >> $CLOUDFLARE_FILE_PATH;
        /bin/echo "RemoteIPHeader CF-Connecting-IP" >> $CLOUDFLARE_FILE_PATH;

        /bin/echo "# - IPv4" >> $CLOUDFLARE_FILE_PATH;
        for i in `curl https://www.cloudflare.com/ips-v4`; do
            /bin/echo "RemoteIPTrustedProxy $i" >> $CLOUDFLARE_FILE_PATH;
        done

        /bin/echo "" >> $CLOUDFLARE_FILE_PATH;
        /bin/echo "# - IPv6" >> $CLOUDFLARE_FILE_PATH;
        for i in `curl https://www.cloudflare.com/ips-v6`; do
            /bin/echo "RemoteIPTrustedProxy $i" >> $CLOUDFLARE_FILE_PATH;
        done
    fi
    
fi
