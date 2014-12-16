#Aim - Program to read the logs generated by YCSB and generate the graphs for read latency, update latency and throughput
#Assumption - File Name of logs should be XXXXrunYYYY_ZZZZ.out
#XXXX - DBName
#YYYY - Desired Throughput
#ZZZZ - Threads
#Author - Naman Aggarwal

import os
import re
from os.path import isfile, join
from matplotlib import pyplot as pp

# ---------- EDIT THESE TO CHANGE THE LOG DIRECTORY AND WHERE THE FILES SHOULD BE SAVED ----------------------
directory = "/home/naman/dd/hbasefiles"
readsavefile="/home/naman/dd/hbase-read-vs-throughput"
updatesavefile="/home/naman/dd/hbase-update-vs-throughput"
throughputsavefile="/home/naman/dd/hbase-throughput-vs-throughput"

colors = [ 'bo--', 'go-', 'ro--', 'co-', 'mo--', 'yo-', 'ko--','bo-', 'go--', 'ro-', 'co--', 'mo-', 'yo--', 'ko-' ]
maxth=0
maxrl=0
maxul=0
maxdt=0

def readFiles():
        global maxth, maxrl, maxul, maxdt	
	cwd = directory
	lst = {}
	for f in os.listdir(cwd):
		fpath = join(cwd,f)
		if isfile(fpath) and f[-3:] == "out":		
			rindex = f.find("run")
			uindex = f.find("_")
			dtype, dthroughput, dthread  = f[:rindex],int(f[rindex+3:uindex]),int(f[uindex+1:-4])
			otregex = re.compile("^\[OVERALL.*Throughput.*",re.M);
			ulregex = re.compile("^\[UPDATE.*AverageLatency.*",re.M);
			rlregex = re.compile("^\[READ.*AverageLatency.*",re.M);
			strfile = open(fpath,"r").read()
			otline  = otregex.search(strfile)
			ulline  = ulregex.search(strfile)
			rlline  = rlregex.search(strfile)
			throughput, ulatency, rlatency = float(otline.group(0).split(",")[2]), float(ulline.group(0).split(",")[2]), float(rlline.group(0).split(",")[2])
			if not dthread in dict.keys(lst):
				lst[dthread] = {}
								
			lst[dthread][dthroughput] = [ulatency,rlatency,throughput]		
			if throughput > maxth:
				maxth = throughput
			if ulatency > maxul:
				maxul = ulatency
			if rlatency > maxrl:
				maxrl = rlatency
			if dthroughput > maxdt:
                                maxdt = dthroughput
	
	nlst = {}
	for thread in lst:
		nlst[thread] = []
		for i in range(0,4):
			nlst[thread].append([])
		for th in sorted(lst[thread]):
			nlst[thread][0].append(th)
			nlst[thread][1].append(lst[thread][th][0])
			nlst[thread][2].append(lst[thread][th][1])
			nlst[thread][3].append(lst[thread][th][2])
			
	
	return nlst

def createReadLatencyGraph(data):
	
	pp.figure(1)
	count=0
	for thread in sorted(data.keys()):
		pp.plot(data[thread][3],data[thread][2],colors[count],label="Threads = "+str(thread))
		count+=1
	pp.grid(axis='both')
        pp.xlabel('Achieved Throughput (operations/second)')
        pp.ylabel('Average Read Latency (milliseconds)')
        pp.axis([0, 1.1 * maxth , 0, 1.1*maxrl ])
        pp.title('HBase Read Latency vs Achieved Throughput at different number of threads for 300000 operations and 25000000 record count')
        pp.legend(loc=2)
	save(readsavefile)

def createUpdateLatencyGraph(data):

        pp.figure(2)
        count=0
        for thread in sorted(data.keys()):
                pp.plot(data[thread][3],data[thread][1],colors[count],label="Threads = "+str(thread))
                count+=1
        pp.grid(axis='both')
        pp.xlabel('Overall Achieved Throughput (operations/second)')
        pp.ylabel('Average Update Latency (milliseconds)')
        pp.axis([0, 1.1 * maxth , 0, 1.5*maxul ])
        pp.title('HBase Update Latency vs Achieved Throughput at different number of threads for 300000 operations and 25000000 record count')
        pp.legend(loc=2)
        save(updatesavefile)

def createThroughputGraph(data):

        pp.figure(3)
        count=0
        for thread in sorted(data.keys()):
                pp.plot(data[thread][0],data[thread][3],colors[count],label="Threads = "+str(thread))
                count+=1
        pp.grid(axis='both')
        pp.xlabel('Target Throughput (operations/second)')
        pp.ylabel('Overall Achieved Throughput (operations/second)')
        pp.axis([0, 1.1*maxdt , 0, 1.1*maxth ])
        pp.title('HBase Achieved Throughput vs Target Throughput at different number of threads for 300000 operations and 25000000 record count')
        pp.legend(loc=2)
        save(throughputsavefile)


#This function saves the plot in a file
#This is contributed by Siddharth Goel (National University of Singapore)
def save(path, ext='png', close=True, verbose=True):

    # Extract the directory and filename from the given path
    directory = os.path.split(path)[0]
    filename = "%s.%s" % (os.path.split(path)[1], ext)
    if directory == '':
        directory = '.'

    # If the directory does not exist, create it
    if not os.path.exists(directory):
        os.makedirs(directory)

    # The final path to save to
    savepath = os.path.join(directory, filename)

    if verbose:
        print("Saving figure to '%s'..." % savepath)

    pp.gcf().set_size_inches(18.5,10.5)

   # Actually save the figure
    pp.savefig(savepath, figsize=(50, 40), dpi=80)

    # Close it
    if close:
        pp.close()

    if verbose:
        print("Done")

def main():
	#Read the log files
	data = readFiles()
	#Create the read latecy vs throughput graph
	createReadLatencyGraph(data)
	#Create update latency vs throughput graph
	createUpdateLatencyGraph(data)
	#Create achieved throughput vs desired throughput graph
	createThroughputGraph(data)

if __name__=="__main__":
	main()
