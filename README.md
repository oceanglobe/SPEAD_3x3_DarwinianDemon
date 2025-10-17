# Information on the code #
This code runs the DARWIN model coupled with the SPEAD eco-evolutionary framework which allows simulating the evolution of three phytoplankton traits: cell-size, temperature optimum, and irradiance optimum. The main code is the MITgcm code and can be find here: https://github.com/MITgcm/MITgcm. Our additions/modifications to this code can be found in the code_offline3D directory.

# Running the code #
To run the code you will need a linux machine with at least 40 CPUs, a gfortran compiler and Open MPI for parallel computing. The code was run on a machine using Debian GNU/Linux 11 (bullseye), gcc version 10.2.1 and Open MPI 4.1.0. 

As compiling the code on a unknown machine is not trivial, we provide 5 pre-compiled executables (for each of the 5 different simulations) in the directory runs_offline3D. Those executables have been compiled to run on 40 CPUs. To run them, you need to execute the 'run_script' bash file found in the same directory. Prior to execution, must be set in the file the directory initial run directory (l 11) and your final output directory (l 12):
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
Note that this needs to be adapted if the code is run on a machine with a job manager (e.g., SLURM, HTCondor).

# Testing the code and reproducing the study's results #
The data* files are namelists containing the model parameters. In the data file, the number of time steps 'nTimeSteps' can be setup. By default, it is set to 2880 which corresponds to a year (the time step being 3 hours). This should take 1h to run and constitues a good demo/test run. If necessary, nTimeSteps can be set to 240 (one month) which should run in 5 minutes. Longer simulations (~20 years; in the study we use nTimeSteps=60480) are required for the system to converge and to obtain the results shown in the study. 

# Extract outputs #
The output files are produced in the chosen directory and can be extracted using the python libraries provided by in the MITgcm github (https://github.com/MITgcm/MITgcm/tree/master/utils/python/MITgcmutils) which are documented here: https://mitgcm.readthedocs.io/en/latest/utilities/utilities.html#mitgcmutils 
