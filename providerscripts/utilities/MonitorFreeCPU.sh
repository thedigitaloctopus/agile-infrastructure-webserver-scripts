

/usr/bin/top -bn2 | grep "Cpu(s)" | /bin/sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | /usr/bin/awk '{print 100 - $1}' | /usr/bin/tail -n 1
