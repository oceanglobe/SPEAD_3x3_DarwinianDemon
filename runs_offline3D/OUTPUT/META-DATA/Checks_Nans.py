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
run_name   = 'Alltraits_100y_2'
run_dir    = root_dir+run_name+'/'
nice_print('Selected run: '+run_dir)

TRAC_input = run_dir+'TRAC'
FPP_input  = run_dir+'FPP'
TRAC_list  = sorted(glob.glob(TRAC_input+'.*.data'))
FPP_list   = sorted(glob.glob(FPP_input +'.*.data'))


nice_print('\nThe run contains '+str(int(len(TRAC_list)/12))+' years.')
Iter   = [int(i[-15:-5]) for i in TRAC_list]
Var        = [1,2,3,4,5]+np.arange(19,30).tolist()

nice_print('------ Loading outputs',pre=bcolors.OKGREEN)  
TRAC       = mds.rdmds(TRAC_input,Iter,rec=Var)
FPP        = mds.rdmds(FPP_input,Iter)
nice_print('------ Outputs loaded',pre=bcolors.OKGREEN)  

n_Nans = np.sum(np.isnan(TRAC))

if (n_Nans == 0):
    nice_print('------ No Nans!',pre=bcolors.OKGREEN)  
else:
    nice_print('------ :( '+str(n_Nans)+' Nans...')

t2 = time.perf_counter()
print('Total time: ',t2-t0)
