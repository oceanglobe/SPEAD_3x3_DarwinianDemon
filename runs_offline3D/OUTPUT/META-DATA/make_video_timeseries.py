import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from alive_progress import alive_bar
from MITgcmutils import mds
import os
import gzip
import pickle
import glob
import time
import subprocess as sp

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

delZ     = np.array([10.,10.,15.,20.,20.,25.,35.,50.])
lon      = np.linspace(0,360.000005,360)
lat      = np.linspace(-79.5,79.5,160)

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
year = input(bcolors.OKGREEN+bcolors.BOLD+'Do you want to load everything (y/nunber of years; can be negative to start from the end)? '+bcolors.ENDC)
if (year == 'y') or (year == ''):
    nice_print('------ Loading everything',pre=bcolors.OKGREEN)
    Iter   = [int(i[-15:-5]) for i in TRAC_list]
elif float(year) > 0:
    inp = input(bcolors.OKGREEN+bcolors.BOLD+"Loads the whole interval (y/n; 'n' loads only the one year)? "+bcolors.ENDC)
    if (inp == 'y'):
        nice_print('------ Loading the '+str(year)+' first years',pre=bcolors.OKGREEN)
        Iter   = [int(i[-15:-5]) for i in TRAC_list][:int(year)*12]
    else:
        nice_print('------ Loading the year '+str(year),pre=bcolors.OKGREEN)
        Iter   = [int(i[-15:-5]) for i in TRAC_list][(int(year)-1)*12:int(year)*12]
elif float(year) < 0:
    inp = input(bcolors.OKGREEN+bcolors.BOLD+"Loads the whole interval (y/n; 'n' loads only the one year)? "+bcolors.ENDC)
    if (inp == 'y'):
        nice_print('------ Loading the '+str(year)+' last years',pre=bcolors.OKGREEN)    
        Iter   = [int(i[-15:-5]) for i in TRAC_list][int(year)*12:]
    else:
        nice_print('------ Loading the year '+str(int(len(TRAC_list)/12)+year),pre=bcolors.OKGREEN)
        Iter   = [int(i[-15:-5]) for i in TRAC_list][(int(year)-1)*12:int(year)*12]

trait = input(bcolors.OKGREEN+bcolors.BOLD+'Which variable number (refer to data.ptracer): '+bcolors.ENDC)

Var        = [int(trait),19]
TRAC       = mds.rdmds(TRAC_input,Iter,rec=Var)

C          = TRAC[:,1,:,:,:]
Var        = TRAC[:,0,:,:,:]/C
if (trait == '20') or (trait == '22'):
    Var    = np.exp(Var)
    if (trait == '20'):
        Var = np.log((3/4*1/np.pi*Var)**(1/3)*2)


nice_print('------ Outputs loaded',pre=bcolors.OKGREEN)  

Var_z      = np.sum(C*Var*delZ[None,:,None,None],(1))/np.sum(C*delZ[None,:,None,None],(1))
if (trait == '20'):
    for i in np.arange(len(Var_z)):
        fig = plt.figure(figsize=(5.5,1.5))  # largeur augmentée pour 2 colonnes

        ax1 = fig.add_subplot(121,facecolor='black',projection=ccrs.Robinson(central_longitude=0))
        p1 = ax1.contourf(lon,lat,np.exp(Var_z)[i,:,:],10**np.linspace(np.log10(0.5),np.log10(20),20),transform=ccrs.PlateCarree(),cmap='viridis',extend='both',norm=mpl.colors.LogNorm())
        ax1.add_feature(cfeature.LAND, facecolor='black', edgecolor='black', linewidth=0.5, zorder=2)
        c1 = fig.colorbar(p1,shrink=0.40,orientation='horizontal',pad=0.05)
        c1.ax.xaxis.set_ticks([1,10],minor=False)
        c1.ax.xaxis.set_ticklabels(['10$^0$','10$^1$'],minor=False)
        c1.ax.xaxis.set_ticks((np.arange(5,10)/10).tolist() + np.arange(1,10).tolist() + [20],minor=True)
        c1.ax.tick_params(labelsize=5)
        c1.ax.set_xlabel('ESD (µm)',rotation=0,fontsize=5)
        ax1.set_global()

        fig.tight_layout()
        plt.savefig('map_ESD_{0:04d}.png'.format(i),dpi=600,bbox_inches = 'tight')
        plt.close(fig)
        print('------ '+str(np.round(i/len(Var_z)*100))+'%',end='\r')

elif (trait == '21'):
    for i in np.arange(len(Var_z)):
        fig = plt.figure(figsize=(5.5,1.5))  # largeur augmentée pour 2 colonnes

        ax1 = fig.add_subplot(121,facecolor='black',projection=ccrs.Robinson(central_longitude=0))
        p1 = ax1.contourf(lon,lat,Var_z[i,:,:],np.arange(0,31,1),transform=ccrs.PlateCarree(),cmap='turbo',extend='both')
        ax1.add_feature(cfeature.LAND, facecolor='black', edgecolor='black', linewidth=0.5, zorder=2)
        c1 = fig.colorbar(p1,shrink=0.40,orientation='horizontal',pad=0.05)
        c1.set_ticks([0,10,20,30])
        c1.ax.tick_params(labelsize=5)
        c1.ax.set_xlabel('T$\mathrm{_{opt}}$ (°C)',rotation=0,fontsize=5)
        ax1.set_global()

        fig.tight_layout()
        plt.savefig('map_Topt_{0:04d}.png'.format(i),dpi=600,bbox_inches = 'tight')
        plt.close(fig)
        print('------ '+str(np.round(i/len(Var_z)*100))+'%',end='\r')
else:  
    for i in np.arange(len(Var_z)):
        fig = plt.figure(figsize=(5.5,1.5))  # largeur augmentée pour 2 colonnes

        ax1 = fig.add_subplot(121,facecolor='black',projection=ccrs.Robinson(central_longitude=0))
        p1 = ax1.contourf(lon[:],lat[:],Var_z[i,:,:],10**np.linspace(np.log10(50),np.log10(250),21),transform=ccrs.PlateCarree(),cmap='inferno',extend='both',norm=mpl.colors.LogNorm())
        ax1.add_feature(cfeature.LAND, facecolor='black', edgecolor='black', linewidth=0.5, zorder=2)
        c1 = fig.colorbar(p1,shrink=0.35,orientation='horizontal',pad=0.05)
        c1.ax.xaxis.set_ticks([100],minor=False)
        c1.ax.xaxis.set_ticks((np.arange(5,10)*10).tolist()+(np.arange(1,3)*100).tolist(),minor=True)
        c1.ax.xaxis.set_ticklabels([100])
        c1.ax.xaxis.set_ticklabels([100],minor=False)
        c1.ax.xaxis.set_ticklabels([],minor=True)
        c1.ax.tick_params(labelsize=5)
        c1.ax.set_xlabel('PAR$_{\mathrm{opt}}$ (µEin.m$^{-2}$.s$^{-1}$)',rotation=0,fontsize=5)
        ax1.set_global()

        fig.tight_layout()
        plt.savefig('map_Lopt_{0:04d}.png'.format(i),dpi=600,bbox_inches = 'tight')
        plt.close(fig)
        print('------ '+str(np.round(i/len(Var_z)*100))+'%',end='\r')

if (trait == '20'): 
    sp.call("ffmpeg -i map_ESD_%04d.png -vf palettegen palette_ESD.png",shell=True)
    sp.call("ffmpeg -i map_ESD_%04d.png -i palette_ESD.png -lavfi paletteuse map_ESD.gif",shell=True)
    sp.call("rm -f map_ESD_*.png",shell=True)
    sp.call("rm -f pallete_ESD*.png",shell=True)
elif (trait == '21'): 
    sp.call("ffmpeg -i map_Topt_%04d.png -vf palettegen palette_Topt.png",shell=True)
    sp.call("ffmpeg -i map_Topt_%04d.png -i palette_Topt.png -lavfi paletteuse map_Topt.gif",shell=True)
    sp.call("rm -f map_Topt_*.png",shell=True)
    sp.call("rm -f pallete_Topt*.png",shell=True)
else: 
    sp.call("ffmpeg -i map_Lopt_%04d.png -vf palettegen palette_Lopt.png",shell=True)
    sp.call("ffmpeg -i map_Lopt_%04d.png -i palette_Lopt.png -lavfi paletteuse map_Lopt.gif",shell=True)
    #sp.call("rm -f map_Lopt_*.png",shell=True)
    #sp.call("rm -f pallete_Lopt*.png",shell=True)

nice_print('------ Done',pre=bcolors.OKGREEN)
t2 = time.perf_counter()
print('Total time: ',t2-t0)
