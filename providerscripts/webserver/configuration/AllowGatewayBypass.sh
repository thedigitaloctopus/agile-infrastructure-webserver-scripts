    if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh GATEWAYGUARDIAN:1`" = "1" ] )
    then

        for ip in "`/bin/ls ${HOME}/config/autoscalerip | /usr/bin/tr '\n' ' '`"
        do
           /bin/echo "<RequireAny>" >> /etc/apache2/sites-available/${WEBSITE_NAME}
           /bin/echo "    Require ip ${ip}" >> /etc/apache2/sites-available/${WEBSITE_NAME}
           /bin/echo "    Require valid-user" >> /etc/apache2/sites-available/${WEBSITE_NAME}
           /bin/echo "</RequireAny>" >> /etc/apache2/sites-available/${WEBSITE_NAME}
        done
    fi
