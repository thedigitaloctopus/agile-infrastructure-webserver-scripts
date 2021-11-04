#set -x

if ( [ -f ${HOME}/runtime/BYPASS_PROCESSED ] )
then
    exit
fi

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
then
   exit
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DEVELOPMENT:1`" = "1" ] && [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh PRODUCTION:0`" = "1" ] )
then
    exit
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh WEBSERVERCHOICE:NGINX`" = "1" ] )
then
    WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
    WEBSITE_NAME="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`"
    /bin/echo "                   satisfy any;" >> /etc/nginx/sites-available/bypass_snippet.dat
    for ips in "`/bin/ls ${HOME}/config/autoscalerip | /usr/bin/tr '\n' ' '`"
    do
        for ip in ${ips}
        do 
            /bin/echo "                      allow ${ip};" >> /etc/nginx/sites-available/bypass_snippet.dat
        done
    done
    
    for ips in "`/bin/ls ${HOME}/config/autoscalerpublicip | /usr/bin/tr '\n' ' '`"
    do
        for ip in ${ips}
        do
            /bin/echo "                      allow ${ip};" >> /etc/nginx/sites-available/bypass_snippet.dat
        done
    done
    
    /bin/echo "                   deny all;" >> /etc/nginx/sites-available/bypass_snippet.dat

    if ( [ -f /etc/nginx/sites-available/bypass_snippet.dat ] )
    then
        /bin/sed -i -e '/####BYPASS####/{r /etc/nginx/sites-available/bypass_snippet.dat' -e 'd}' /etc/nginx/sites-available/${WEBSITE_NAME} 
    fi

    /bin/touch ${HOME}/runtime/BYPASS_PROCESSED
    /bin/rm /etc/nginx/sites-available/bypass_snippet.dat
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh WEBSERVERCHOICE:APACHE`" = "1" ] )
then
    WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"
    for ip in "`/bin/ls ${HOME}/config/autoscalerip | /usr/bin/tr '\n' ' '`"
    do
        /bin/echo "                 <RequireAny>" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                      Require ip ${ip}" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                      Require valid-user" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                 </RequireAny>" >> /etc/apache2/sites-available/bypass_snippet.dat
    done
    
    for ip in "`/bin/ls ${HOME}/config/autoscalerpublicip | /usr/bin/tr '\n' ' '`"
    do
        /bin/echo "                 <RequireAny>" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                      Require ip ${ip}" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                      Require valid-user" >> /etc/apache2/sites-available/bypass_snippet.dat
        /bin/echo "                 </RequireAny>" >> /etc/apache2/sites-available/bypass_snippet.dat
    done

    if ( [ -f /etc/apache2/sites-available/bypass_snippet.dat ] )
    then
        /bin/sed -i -e '/####BYPASS####/{r /etc/apache2/sites-available/bypass_snippet.dat' -e 'd}' /etc/apache2/sites-available/${WEBSITE_NAME} 
    fi

    /bin/touch ${HOME}/runtime/BYPASS_PROCESSED
    /bin/rm /etc/apache2/sites-available/bypass_snippet.dat
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh WEBSERVERCHOICE:LIGHTTPD`" = "1" ] )
then
    for ips in "`/bin/ls ${HOME}/config/autoscalerip | /usr/bin/tr '\n' ' '`"
    do
        for ip in ${ips}
        do 
            /bin/echo "                      ${ip}|" >> /etc/lighttpd/bypass_snippet.dat
        done
    done
    /bin/sed -i "s/|$//g" /etc/lighttpd/bypass_snippet.dat
    /bin/echo ")\$" >> /etc/lighttpd/bypass_snippet.dat
    /bin/echo "\$HTTP[\"remoteip\"] !~ \"^(" >> /etc/lighttpd/bypass_snippet.dat
    
    /bin/sed -i -e '/####BYPASS####/{r /etc/lighttpd/bypass_snippet.dat' -e 'd}' /etc/lighttpd/lighttpd.conf
    /bin/sed -i '/####BYPASS1####/}/g' /etc/lighttpd/lighttpd.conf
    
    /bin/rm /etc/lighttpd/bypass_snippet.dat

fi
