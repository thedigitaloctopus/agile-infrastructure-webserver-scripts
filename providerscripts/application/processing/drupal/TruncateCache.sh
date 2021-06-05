set -x

if ( [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:Maria ] || [ -f ${HOME}/.ssh/DATABASEINSTALLATIONTYPE:MySQL ] )
then
    prefix="`/bin/cat /var/www/html/dpb.dat`"

    ${HOME}/providerscripts/utilities/ConnectToRemoteMYSQLDB.sh "TRUNCATE ${prefix}_cache_bootstrap;TRUNCATE ${prefix}_cache_config; TRUNCATE ${prefix}_cache_container;TRUNCATE ${prefix}_cache_data;TRUNCATE ${prefix}_cache_default;TRUNCATE ${prefix}_cache_discovery;TRUNCATE ${prefix}_cache_dynamic_page_cache;TRUNCATE ${prefix}_cache_entity;TRUNCATE ${prefix}_cache_menu; TRUNCATE ${prefix}_cache_page;TRUNCATE ${prefix}_cache_render;TRUNCATE ${prefix}_cache_toolbar;TRUNCATE ${prefix}_cachetags;"

    if ( [ "$?" = "0" ] )
    then
       /bin/echo "TRUNCATED"
    else
        /bin/echo "NOT TRUNCATED"
    fi
fi
