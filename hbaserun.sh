THREADS="1 2 4 8 16 32 64 128 256 512"
TARGETS="500 1000 2000 4000 8000 16000 32000 64000 128000"

US="_"

for target in ${TARGETS[@]}
do    
    for thread in ${THREADS[@]}
    do
	date
	echo "Doing the run for Hbase Target as $target and Thread as $thread"
       ./bin/ycsb run hbase -P workloads/workloada -P large.dat -p columnfamily=family -p operationcount=300000 -target ${target} -threads ${thread} -s &> hbaserun${target}${US}${thread}.out
	echo "Run for Hbase Target as $target and Thread as $thread done"
	date
	sleep 5
    done    	
done

echo "Script completed"
