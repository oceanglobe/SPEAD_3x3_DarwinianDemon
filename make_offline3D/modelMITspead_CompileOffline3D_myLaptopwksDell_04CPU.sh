#!/bin/sh
##------------------------------------------
make CLEAN
##------------------------------------------
## export MPI_INC_DIR=/usr/include/mpi
export MPI_INC_DIR=/usr/lib/x86_64-linux-gnu/openmpi/include
export MITGCM_ROOTDIR=${HOME}/SERVAL/SER24/PROGRAMMING/FORTRAN/PROGRAMS/MODELS/OCEANS_3D/MIT_GCM/MIT-SPEAD/MITgcm
##------------------------------------------
${MITGCM_ROOTDIR}/tools/genmake2 \
    -mods=../code_offline3D \
    -of ${MITGCM_ROOTDIR}/tools/build_options/linux_amd64_gfortran -mpi
##    -of ${MITGCM_ROOTDIR}/tools/build_options/linux_amd64_gfortran_generic_mpi -mpi
##------------------------------------------
make depend
make -j5 
##------------------------------------------
mv mitgcmuv ../runs_offline3D 
##------------------------------------------
cd ../runs_offline3D 
mpirun -np 4 ./mitgcmuv 
##nohup mpirun -np 8 ./mitgcmuv &
##------------------------------------------
## wait until "STOP NORMAL END" 
./copyFilesNetCDF-to-Outputs_RunOffline3D.sh 
./glueFilesNetCDF_python-exe_RunOffline3D.sh 
##------------------------------------------
