fid=fopen('phy78_lev01_ann-3d.bin','r','b');
phyto=fread(fid,'float32'); fclose(fid);
phyto=reshape(phyto,144,90,22);

newphyto=phyto*0.1;

fid=fopen('phy_low_ann-3d.bin','w','b');
fwrite(fid,newphyto,'float32'); fclose(fid);
