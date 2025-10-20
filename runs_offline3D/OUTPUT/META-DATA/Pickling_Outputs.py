import numpy as np
from alive_progress import alive_bar
from MITgcmutils import mds
import os
import gzip
import pickle
import glob
import time

class bcolors:
    HEADER    = '\033[95m'
    OKBLUE    = '\033[94m'
    OKCYAN    = '\033[96m'
    OKGREEN   = '\033[92m'
    WARNING   = '\033[93m'
    FAIL      = '\033[91m'
    ENDC      = '\033[0m'
    BOLD      = '\033[1m'
    UNDERLINE = '\033[4m'

def nice_print(x,pre=bcolors.OKGREEN+bcolors.BOLD,post=bcolors.ENDC):
    print(pre+x+post)
    return()

t0 = time.perf_counter()
root_dir   = './'
run_name   = 'your_run'
run_dir    = root_dir+run_name+'/'
nice_print('Selected run: '+run_dir)

TRAC_input = run_dir+'TRAC'
FPP_input  = run_dir+'FPP'
TRAC_list  = sorted(glob.glob(TRAC_input+'.*.data'))
FPP_list   = sorted(glob.glob(FPP_input +'.*.data'))


nice_print('\nThe run contains '+str(int(len(TRAC_list)/12))+' years.')
year = input(bcolors.OKGREEN+bcolors.BOLD+'Do you want to load everything (y/nunber of years; can be negative to start from the end)? '+bcolors.ENDC)
if (year == 'y') or (year == ''):
    nice_print('------ Loading everything',pre=bcolors.OKGREEN)
    Iter   = [int(i[-15:-5]) for i in TRAC_list]
elif float(year) > 0:
    nice_print('------ Loading the '+str(year)+' first years',pre=bcolors.OKGREEN)
    Iter   = [int(i[-15:-5]) for i in TRAC_list][:int(year)*12]
elif float(year) < 0:
    nice_print('------ Loading the '+str(year)+' last years',pre=bcolors.OKGREEN)    
    Iter   = [int(i[-15:-5]) for i in TRAC_list][int(year)*12:]

Var        = [1,2,3,4,5]+np.arange(19,30).tolist()
TRAC       = mds.rdmds(TRAC_input,Iter,rec=Var)
FPP        = mds.rdmds(FPP_input,Iter)
nice_print('------ Outputs loaded',pre=bcolors.OKGREEN)  

t1 = time.perf_counter()
nice_print('\n------ Pickling the outputs',pre=bcolors.OKGREEN)
pickle_name = run_dir+run_name+'.pickle'
f=open(pickle_name,'wb')
pickle.dump([TRAC,FPP], f)
#f=gzip.GzipFile(pickle_name,'wb')
#pickle.dump([TRAC,FPP], f, protocol=pickle.HIGHEST_PROTOCOL)
nice_print('------ Outputs pickled in '+pickle_name,pre=bcolors.OKGREEN)
t2 = time.perf_counter()
print('\nPickling time: ',t2-t1)
print('Total time: ',t2-t0)
