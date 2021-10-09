if ( [ -f ${HOME}/runtime/BYPASS_PROCESSED ] )
then
    exit
fi

if ( [ "`/bin/mount | /bin/grep ${HOME}/config`" = "" ] )
then
   exit
fi

WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEDISPLAYNAME'`"

for ip in "`/bin/ls ${HOME}/config/autoscalerip | /usr/bin/tr '\n' ' '`"
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
