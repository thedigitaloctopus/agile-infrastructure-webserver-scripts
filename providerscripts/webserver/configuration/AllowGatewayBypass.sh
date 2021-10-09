if ( [ -f ${HOME}/runtime/BYPASS_PROCESSED ] )
then
    exit
fi

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
then
   exit
fi

WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh WEBSERVERCHOICE:NGINX`" = "1" ] )
then
    /bin/echo "satisfy any;" >> /etc/nginx/sites-available/bypass_snippet.dat
    for ip in "`/bin/ls ${HOME}/config/autoscalerip | /usr/bin/tr '\n' ' '`"
    do
        /bin/echo "                      allow ${ip};" >> /etc/nginx/sites-available/bypass_snippet.dat
    done
    
    for ip in "`/bin/ls ${HOME}/config/autoscalerpublicip | /usr/bin/tr '\n' ' '`"
    do
        /bin/echo "                      allow ${ip};" >> /etc/nginx/sites-available/bypass_snippet.dat
    done
    
    /bin/echo "deny all;" >> /etc/nginx/sites-available/bypass_snippet.dat

    if ( [ -f /etc/nginx/sites-available/bypass_snippet.dat ] )
    then
        /bin/sed -i -e '/####BYPASS####/{r /etc/nginx/sites-available/bypass_snippet.dat' -e 'd}' /etc/nginx/sites-available/${WEBSITE_NAME} 
    fi

    /bin/touch ${HOME}/runtime/BYPASS_PROCESSED
    /bin/rm /etc/nginx/sites-available/bypass_snippet.dat
fi

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh WEBSERVERCHOICE:APACHE`" = "1" ] )
then
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
