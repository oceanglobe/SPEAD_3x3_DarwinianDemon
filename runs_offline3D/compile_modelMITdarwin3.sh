#!/bin/sh
##------------------------------------------
cd ../make_offline3D
make Clean
##------------------------------------------
##export MPI_INC_DIR=/usr/include/mpi
##export ROOTDIR=${HOME}/PAZ/LEGLAND/FORTRAN/MODELS/MIT-GIT/MITgcm
export ROOTDIR=/home/sauterey/BORIS/MIT-GIT/MITgcm
export MPI_INC_DIR=/lib/x86_64-linux-gnu/openmpi/include
#export MPI_INC_DIR=/bin/
#export MPI_INC_DIR=/lib/x86_64-linux-gnu/openmpi/include/
##------------------------------------------
${ROOTDIR}/tools/genmake2 -mpi \
    -of ${ROOTDIR}/tools/build_options/linux_amd64_gfortran -mods=../code_offline3D
##  -of ${ROOTDIR}/tools/build_options/linux_amd64_gfortran
##------------------------------------------
make depend
# I think the following step is necessary to avoid mixing with the next task
#read -t 10 -p "Waiting 10 seconds before compiling"
make -j8
#read -t 10 -p "Waiting 10 seconds before moving mitgcmuv"
##------------------------------------------
mv mitgcmuv ../runs_offline3D
##------------------------------------------
