# Information on the code #
This code runs the DARWIN model coupled with the SPEAD eco-evolutionary framework which allows simulating the evolution of three phytoplankton traits: cell-size, temperature optimum, and irradiance optimum. We provide pre-compiled standalone executables to run the main configurations of the code without compilation required. To modify, compile then run the code, the main code of the MITgcm (which can be find here: https://github.com/MITgcm/MITgcm) is required. 

# Running the precompiled code #
As compiling the code on a unknown machine is not trivial, we provide 5 pre-compiled executables:
- three in which one trait evolves while the two others are assumed optimal (mitgcmuv_Size, mitgcmuv_Light, mitgcmuv_Temp),
- one in which all traits evolve (mitgcmuv_AllTraits),
- one in which all traits are optimal) in the directory runs_offline3D (mitgcmuv_DD). 

Those executables have been compiled to run on 40 CPUs. So to run the code you will need a linux machine with at least 40 CPUs and Open MPI for parallel computing. The code was compiled and run on a machine using Debian GNU/Linux 11 (bullseye), gcc version 10.2.1 and Open MPI 4.1.0. 

To run the executables, you need to execute the 'run_script' bash file found in the same directory. Prior to execution, must be set in the file the directory initial run directory (l 11) and your final output directory (l 12):
```
export initdir=<your initial run directory>
export rundir=<your final output directory>
```
as well as the name of the executable to use (l 25)
```
mpirun -np 40 ./<your executable>
```
Once it is done, the script can be executed in command line as follows
```
bash ./run_script
```
Note that this needs to be adapted if the code is run on a machine with a job manager (e.g., SLURM, HTCondor). As the simulation is running, monthly output files will be generated in the "OUTPUT/META-DATA/<name of your run>" directory. The files TRAC* contain all the state variables, the FPP* files the primary productivity. Please refer to the file data.ptracers in the run_offline3D directory to know about 1/ the variables included in the TRAC files, 2/ their units, /3 their order.

# Testing the code and reproducing the study's results #
The data* files are namelists containing the model parameters. In the data file, the number of time steps 'nTimeSteps' can be setup. By default, nTimeSteps is set to 240 (one month) which should run in ~5 minutes. Longer simulations of ~20 years (nTimeSteps=60480 in Sauterey et al.; should take about a day to run) are required for the system to converge to a seasonal equilibirum and to obtain the results shown in Sauterey et al. (in prep). 

# Modifying and recompiling the code #
The modification we made to the main code of the MITgcm can be found in the "code_offline3D" directory. In this directory can for instance be found the routine that determines the number of CPU required to run the code. We will describe how to change this number as an example of how to change the code and recompile it. First, downloading the MITgcm code is necessary: https://github.com/MITgcm/MITgcm. Once this is done, you can go in the "code_offline3D" directory of this repository and open the routine SIZE.h with your preferred text editor. Once there you can modifiy the nPx and nPy which together determine the number of regions in which the model can be run in parallel. The total number of CPUs required is equal to nPx x nPy. By default, it is equal to 10 x 4 = 40 CPUs. One the file has been modified, a compilation is required. To do so, go in the "run_offline3D" directory and open the compile_modelMITdarwin3.sh script. You must set the ROOTDIR to the path of the main MITgcm code (l 6). You might also need to adapt the path of your MPI libraries (l 7). 
```
export ROOTDIR=<path of the MITgcm code>
export MPI_INC_DIR=<path of your MPI libraries>
```
Once this is done, you can execute the script as follows
```
./compile_modelMITdarwin3.sh
```
The compilation will produce an executable named mitgcmuv (you can/should rename it) in the run directory. To run this new executable, you must modify the run_script script to adjust it to the new number of cpu and executable filename 
```
mpirun -np <your new number of necessary CPUs> ./<your executable>
```
Then you can execute the script.

# Extract outputs #
The output files are produced in the chosen directory and can be extracted using the python libraries provided by in the MITgcm github (https://github.com/MITgcm/MITgcm/tree/master/utils/python/MITgcmutils) which are documented here: https://mitgcm.readthedocs.io/en/latest/utilities/utilities.html#mitgcmutils.

Alternatively, you can use the python script Pickling_Outputs.py which will combine all the TRAC* and FPP* files into a single pickle file. This script is based on python utilies built by MITgcm team (mds.rdmds). More details can be found here: https://github.com/MITgcm/MITgcm/tree/master/utils/python/MITgcmutils. Within the script can be modified the variables from the TRAC files to include in the pickle (l 49), by default:
```
Var        = [1,2,3,4,5]+np.arange(19,30).tolist()
```
When run as follows
```
python3 Pickling_Outputs.py 
```
The script will ask the number of years that should be included. The pickle file generates can then be opened with jupyter rnotebook "Read_Outputs_3D.ipynb" provided in the python directory provided in this repository. 

