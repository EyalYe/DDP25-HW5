# create database for post simulation waveform
database -open -shm dmp -compress -incsize 100M -into dmp -default
probe -database dmp -create [scop -tops] -functions -tasks -emptyok -depth all -memories -all

#run until $finish signal and exit
run 1000000
exit
