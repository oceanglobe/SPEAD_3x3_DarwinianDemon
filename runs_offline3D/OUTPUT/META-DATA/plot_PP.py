import numpy as np
from math import *
from alive_progress import alive_bar
from MITgcmutils import mds
import matplotlib as mpl
import matplotlib.pyplot as plt
import os
import gzip
import pickle
import glob
import time
mpl.rcParams['figure.dpi'] = 600

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

def moving_average(a, n=12):
    ret = np.cumsum(a, dtype=float)
    ret[n:] = ret[n:] - ret[:-n]
    return ret[n - 1:] / n

t0 = time.perf_counter()
root_dir   = './'
run_name   = ['Alltraits_100y_HiMut','Alltraits_100y_MidHiMut','Alltraits_100y','Alltraits_100y_cont50y','Alltraits_100y_MidMut','Alltraits_100y_LowMut']
jet = plt.get_cmap('jet')
col_vec    = [jet(256),jet(192),jet(128),jet(128),jet(64),jet(0)]
label_vec  = ['High','Int. High','Ref.','Ref.','Int. Low','Low']

fig = plt.figure(figsize=(4,2))
ax1 = fig.add_subplot(111)

k=0
for i in run_name:
    run_dir    = root_dir+i+'/'
    nice_print('__________________________\nSelected run: '+run_dir)

    TRAC_input = run_dir+'TRAC'
    FPP_input  = run_dir+'FPP'
    TRAC_list  = sorted(glob.glob(TRAC_input+'.*.data'))
    FPP_list   = sorted(glob.glob(FPP_input+'.*.data'))


    nice_print('\nThe run contains '+str(int(len(TRAC_list)/12))+' years.')
    Iter   = [int(i[-15:-5]) for i in TRAC_list[::3]]
    Var        = [19]

    nice_print('------ Loading outputs',pre=bcolors.OKGREEN)  
    FPP        = mds.rdmds(FPP_input,Iter)
    nice_print('------ Outputs loaded',pre=bcolors.OKGREEN)  

    t    = [int(TRAC_list[i][-15:-5])/2880 for i in range(0,len(TRAC_list),3)]
    lon  = np.linspace(0,360,360)
    lat  = np.arange(-79.5,80.5,1)
    lat_edges = np.arange(-80,81,1)
    Surf = np.transpose(np.array([(np.sin(lat_edges[1:]/360*2*pi)-np.sin(lat_edges[:-1]/360*2*pi))*2*pi/360*6378137**2 for j in np.arange(0,360)]))
    if np.shape(FPP)[1] == 8:
        delZ = np.array([10.,10.,15.,20.,20.,25.,35.,50.])
    else:
        delZ = np.array([10.,10.,15.,20.,20.,25.,35.,50.,75.,100.])

    FPP_tot = np.sum(FPP*delZ[None,:,None,None]*Surf[None,None,:,:],(1,2,3))*60*60*24*360/1e15/1e3*12 

    if len(t) <= 12:
        ax1.plot(t,FPP_tot,c=col_vec[k],label=label_vec[k])
    else:
        if k == 2:
            ax1.plot(moving_average(t),moving_average(FPP_tot),c=col_vec[k])
        else:
            ax1.plot(moving_average(t),moving_average(FPP_tot),c=col_vec[k],label=label_vec[k])
    #plt.xlim([95,150])
    #plt.ylim([40,52])

    k+=1

ax1.set_xlabel('Time (years)')
ax1.set_ylabel('PP (Pg C yr$^{-1}$)')
ax1.legend()
plt.savefig('plotPP',dpi=600,bbox_inches='tight')

t2 = time.perf_counter()
print('Total time: ',t2-t0)
