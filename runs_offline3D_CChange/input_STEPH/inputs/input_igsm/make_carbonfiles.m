nx=144; ny=90; nz=22;
r_pc=120; 

for itype=1:3,
 if (itype==1), 
  filein=['ecco_dop_ann-3d.bin']; 
  fileout=['ecco_doc_ann-3d.bin'];
 end
 if (itype==2),
  filein=['ecco_pop_ann-3d.bin'];
  fileout=['ecco_poc_ann-3d.bin'];
 end
 if (itype==3),
  filein=['zoo2_p_ann-3d.bin'];
  fileout=['zoo2_c_ann-3d.bin'];
 end

 fid=fopen(filein,'r','b');
 clear field,
 field=fread(fid,'float32','b'); fclose(fid); 
 field=reshape(field,nx,ny,nz);
 
 fieldc=field*r_pc;

 fid=fopen(fileout,'w','b');
 fwrite(fid,fieldc,'float32');
 fclose(fid);

end % for itype


