import pandas as pd
import sys 
import os
import argparse
import fnmatch

argparser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter, description="Compute distance to TSS of hexamers in BS converted chromosome.\n Do it per chromosome! By Emma Dann")
#argparser.add_argument('cov2c', type=str, help='chromosome cytosine report input')
args = argparser.parse_args()

dir="/hpc/hub_oudenaarden/edann/hexamers/kaester/met_extraction"
files=[]
for file in os.listdir(dir):
    if fnmatch.fnmatch(file, '*.CpG_report.txt.gz'):
        files.append(dir+"/"+file)


# cov2c = pd.read_csv(dir+"/"+files[0], sep="\t", header=None) 
# cov2c.columns = ["chr", "pos", "strand", "C", "T", "context", "flank"]

# for file in files[1:]:
# 	cov2c_2 = pd.read_csv(dir+"/"+file, sep="\t", header=None) 
# 	cov2c_2.columns = ["chr", "pos", "strand", "C", "T", "context", "flank"]
# 	## gives MemoryError --> ask Buys
# 	df=pd.merge(cov2c,cov2c_2,how="outer",on=["chr","pos","strand","context", "flank"] ).fillna(0)
# 	df=df.assign(C=df.C_x+df.C_y, T=df.T_x+df.T_y)
# 	cov2c=df[["chr","pos","strand","C","T","context","flank"]]

# # average values
# cov2c_avg=cov2c.assign(T=df["T"]/len(files), C=df.C/len(files))
# cov2c_avg=cov2c_avg.assign(frac=cov2c_avg.C/(cov2c_avg.C+cov2c_avg['T']))

# cov2c_avg.to_csv(dir+"/cov2c_merged_refGen.csv", sep='\t')


cov_dict=collections.OrderedDict()
with gzip.open(files[0], "rb") as f:
    for line in f:
		line=line.strip('\n').split('\t')
		cov_dict['\t'.join([line[i] for i in [0,1,2,5,6]])]=[int(i) for i in line[3:5]]

for file in files[1:]:
	with gzip.open(file,'rb') as f:
		for line in f:
			line=line.strip('\n').split('\t')
			cov_dict['\t'.join([line[i] for i in [0,1,2,5,6]])][0]+= int(line[3])
			cov_dict['\t'.join([line[i] for i in [0,1,2,5,6]])][1]+= int(line[4])

for key,val in cov_dict.items():
	list_key=key.split("\t")
	newLine =  list_key[:3]+[str(i/2) for i in val]+list_key[3:]
	print '\t'.join(newLine)