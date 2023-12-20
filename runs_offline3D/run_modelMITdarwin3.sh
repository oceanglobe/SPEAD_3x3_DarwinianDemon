#!/bin/sh
#export PATH=/usr/local/bin/mpirun:$PATH
##------------------------------------------
export OMPI_MCA_plm_rsh_agent=
##------------------------------------------
##mpirun -np 4 ./mitgcmuv
##mpirun -np 12 ./mitgcmuv
mpirun -np 24 ./mitgcmuv
##nohup mpirun -np 8 ./mitgcmuv &
##------------------------------------------
## wait until "STOP NORMAL END"
sleep 10
mkdir OUTPUT/META-DATA/darwin_latest/
rm OUTPUT/META-DATA/darwin_latest/*
#mv out.dat OUTPUT/META-DATA/darwin_latest/
mv *.data OUTPUT/META-DATA/darwin_latest/
mv *.meta OUTPUT/META-DATA/darwin_latest/
mv *.txt OUTPUT/META-DATA/darwin_latest/
cp data OUTPUT/META-DATA/darwin_latest/
cp data.* OUTPUT/META-DATA/darwin_latest/
cp ../code_offline3D/darwin_tempfunc.F OUTPUT/META-DATA/darwin_latest/
cp ../code_offline3D/darwin_spead_rates.F OUTPUT/META-DATA/darwin_latest/
mv STD* OUTPUT/META-DATA/darwin_latest/
mv SLURM* OUTPUT/META-DATA/darwin_latest/
#./copyFilesNetCDF-to-Outputs_RunOffline3D.sh
#./glueFilesNetCDF_python-exe_RunOffline3D.sh
##------------------------------------------
