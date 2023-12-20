#!/bin/sh
##------------------------------------------
make CLEAN
##------------------------------------------
## export MPI_INC_DIR=/usr/include/mpi
export MPI_INC_DIR=/usr/lib/x86_64-linux-gnu/openmpi/include
export MAINDIR=${HOME}/SERVAL/SER24/PROGRAMMING/FORTRAN/PROGRAMS/MODELS/OCEANS_GCM/MIT-EVO/DARWIN
#export ROOTDIR=${HOME}/SERVAL/SER24/PROGRAMMING/FORTRAN/PROGRAMS/MODELS/OCEANS_GCM/MIT-EVO/MITgcm
export ROOTDIR=${HOME}/MIT-GIT/MITgcm
##------------------------------------------
${ROOTDIR}/tools/genmake2 \
    -mods=../code_offline3D \
    -of ${ROOTDIR}/tools/build_options/linux_amd64_gfortran -mpi
##    -of ${ROOTDIR}/tools/build_options/linux_amd64_gfortran_generic_mpi -mpi
##------------------------------------------
## ${MAINDIR}/MITesm/COMPILE-TOOLS/GENMAKE/genmake2 \
##     -mods=../code_offline3D \
##     -rootdir=${ROOTDIR} \
##     -of ${MAINDIR}/MITesm/COMPILE-TOOLS/BUILD_OPTIONS/linux_amd64_gfortran_generic_mpi -mpi
## ##    -of=${MAINDIR}/MITesm/COMPILE-TOOLS/BUILD_OPTIONS/linux_amd64_gfortran_default
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
