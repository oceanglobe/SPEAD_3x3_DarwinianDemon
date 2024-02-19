%more off
%close all
%clear all
%format short g
%%opengl neverselect
%..........................................................................
addpath('TOOLBOX-MITesm/');
%..........................................................................
%==========================================================================
%..........................................................................
darwin_pathroot ='/Users/sauterey/Documents/Recherche/Sync_files/Code/MIT-GIT/DARWIN/verification/SPEAD_global_cont/runs_offline3D/';
%darwin_pathroot ='/Users/sauterey/Documents/Recherche/Sync_files/Code/MIT-GIT/DARWIN/verification/SPEAD_1d_cont_1trait/runs_offline1D/';
darwin_pathroot_folder = [darwin_pathroot,'OUTPUT/META-DATA/'];
darwin_pathroot_folder_data = [darwin_pathroot_folder,'test_mut_0_KTW_0_nomin_var/'];
%darwin_pathroot_folder_data = [darwin_pathroot_folder,'darwin_12042021/'];
%..........................................................................
addpath(darwin_pathroot);
%..........................................................................
[TRAC_names] = data_ptracers_names; %Readin MATLAB script *.m from "runs_offline3D" folder.
%..........................................................................
[TRAC_input] = [darwin_pathroot_folder_data,'TRAC'];
[FPP_input]   = [darwin_pathroot_folder_data,'FPP']; % Primary production (mmolC.m-3.s-1 = 1036800 mgC.m-3.d-1)
%[KPP_input]   = [darwin_pathroot_folder_data,'KPP'];
%[SST_input]   = [darwin_pathroot_folder_data,'SST'];
%[SALT_input]   = [darwin_pathroot_folder_data,'SALT'];
%[PAR_input]   = [darwin_pathroot_folder_data,'PAR_surface'];
%[PAR_input]   = [darwin_pathroot_folder_data,'PAR'];
%..........................................................................
iter = scan_iter(TRAC_input);

[TRAC_values,IT] = rdmds(TRAC_input,iter); %matrices 5D (X,Y, Profondeur, Ptracers, Iteration)
[FPP_values,IT] = rdmds(FPP_input,iter); %matrices 5D (X,Y, Profondeur, Ptracers, Iteration)
%[KPP_values,IT] = rdmds(KPP_input,NaN); %matrices 5D (X,Y, Profondeur, Ptracers, Iteration)
%[SST_values,IT] = rdmds(SST_input,NaN); %matrices 5D (X,Y, Profondeur, Ptracers, Iteration)
%[SALT_values,IT] = rdmds(SALT_input,NaN); %matrices 5D (X,Y, Profondeur, Ptracers, Iteration)
%[PAR_values,IT] = rdmds(PAR_input,NaN); %matrices 5D (X,Y, Profondeur, Ptracers, Iteration)
%..........................................................................
TRAC_values = TRAC_values(1:2:end,1:2:end,:,:,:);
FPP_values  = FPP_values(1:2:end,1:2:end,:,:);
[dum1,dum2,ndepth,ntracer,ntime] = size(TRAC_values);
%..........................................................................
%[TRAC_data] = modelMITdarwin1D_ReadFortranOutputs_MDSIO_dataread_permute(TRAC_values);
%TRAC_data = max(TRAC_data,0);
%[FPP_data] = modelMITdarwin1D_ReadFortranOutputs_MDSIO_dataread_permute(FPP_values);
%[KPP_data] = modelMITdarwin1D_ReadFortranOutputs_MDSIO_dataread_permute(KPP_values);
%[SST_data] = modelMITdarwin1D_ReadFortranOutputs_MDSIO_dataread_permute(SST_values);
%[SALT_data] = modelMITdarwin1D_ReadFortranOutputs_MDSIO_dataread_permute(SALT_values);
%[PAR_data] = modelMITdarwin1D_ReadFortranOutputs_MDSIO_dataread_permute(PAR_values);
%..........................................................................
%SAVE MATLAB BINARY FROM MDSIO DATA:
%save('DARWIN_binary.mat','-mat','TRAC_data','FPP_data','KPP_data','SST_data','PAR_data','TRAC_names')
%save('DARWIN_binary.mat','-mat','TRAC_data','FPP_data','SST_data','TRAC_names')
save('DARWIN_binary_lowRes.mat','-mat','TRAC_values','FPP_values','TRAC_names','-v7.3')
%save('DARWIN_binary.mat','-mat','TRAC_values','FPP_values','TRAC_names')

function [iter] = scan_iter(TRAC_input)
iter=[];
allfiles=dir([TRAC_input '.*.001.001.meta']);
if isempty(allfiles)
    allfiles=dir([TRAC_input '.*.meta']);
    ioff=0;
else
    ioff=8;
end
for k=1:size(allfiles,1);
    hh=allfiles(k).name;
    iter(k)=str2num( hh(end-14-ioff:end-5-ioff) );
end
iter=sort(iter);
end
