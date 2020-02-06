#!/bin/bash
########################################################################################
# Author: Peter Winter
# Date :  07/07/2016
# Description: This script records the CPU usage on this machine in batches of 5,10,15 and 30 readings.
# The reason for batching like this is that 5 gives a very short sample of the CPU behaviour and 30
# gives a longer period of time to sample it. The heuristic on the autoscaler can then be adjusted
# such that a lower figure for a longer time is given the same weight as a high figure for a short time.
# The autoscaler will request the CPU usage stats from each webserver in the fleet and make its decision
# on wheteher to scale up or scale down accordingly
########################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
########################################################################################
########################################################################################
#set -x

/bin/echo "${0} `/bin/date`: Calculating CPU usage for autoscaling" >> ${HOME}/logs/MonitoringLog.dat

if ( [ ! -f ${HOME}/config/INSTALLEDSUCCESSFULLY ] )
then
    exit
fi

# Obtain the current CPU reading
#CPU="`/bin/ps aux | /usr/bin/awk 'BEGIN { sum=0 } { sum += $3 }; END { print sum }'`"

#Script runs every minute from cron as long as it can obtain the lock it needs
nosamplestotake="$1"
samplestaken="0"
samples=""
while ( [ "${samplestaken}" -lt "${nosamplestotake}" ] )
do
    CPU="`/usr/bin/top -bn2 | grep "Cpu(s)" | /bin/sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | /usr/bin/awk '{print 100 - $1}' | /usr/bin/tail -n 1`"
    samplestaken="`/usr/bin/expr ${samplestaken} + 1`"
    samples="${samples} `/bin/echo ${CPU%%.*}`"
    /bin/sleep 2
done

total=0

for value in ${samples}
do
    total="`/usr/bin/expr ${total} + ${value}`"
done

CPU="`/usr/bin/expr ${total} / ${nosamplestotake}`"
ip="`${HOME}/providerscripts/utilities/GetIP.sh`"

# Add the latest CPU reading to each of our aggregation files
/bin/echo ${CPU} >> ${HOME}/config/cpuaggregator/CPUAGGREGATOR-${nosamplestotake}.${ip}

# Truncate the CPU readings to batches of 5,10,15,30 and 60 - this allows up to 60 webservers to be running. If more are needed it should be
# obvious how to accomodate them
/usr/bin/tail -n ${nosamplestotake} ${HOME}/config/cpuaggregator/CPUAGGREGATOR-${nosamplestotake}.${ip} > ${HOME}/config/cpuaggregator/CPUAGGREGATOR-${nosamplestotake}.${ip}.tmp
/bin/mv ${HOME}/config/cpuaggregator/CPUAGGREGATOR-${nosamplestotake}.${ip}.tmp ${HOME}/config/cpuaggregator/CPUAGGREGATOR${nosamplestotake}.${ip}


