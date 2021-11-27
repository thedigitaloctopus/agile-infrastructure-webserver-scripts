


/bin/echo " " >> ${HOME}/runtime/${1}.php.new
/bin/cp ${HOME}/runtime/${1}.php.new ${HOME}/runtime/${1}.php
/bin/cp ${HOME}/runtime/${1}.php.new ${HOME}/config/${1}.php
/bin/rm ${HOME}/runtime/${1}.php.new
/bin/touch ${HOME}/config/GLOBAL_CONFIG_UPDATE
