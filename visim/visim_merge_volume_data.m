% visim_merge_volume_data
%
% CALL : 
%   [f_volgeom,f_volsum,d_volgeom,d_volsum]=visim_merge_volume_data(f_volgeom1,f_volsum1,f_volgeom2,f_volsum2,name);
%
%
%
%
function [f_volgeom,f_volsum,d_volgeom,d_volsum]=visim_merge_volume_data(f_volgeom1,f_volsum1,f_volgeom2,f_volsum2,name);

if nargin<5
    name='merge';
end

d_volgeom1=read_eas(f_volgeom1);
d_volgeom2=read_eas(f_volgeom2);
d_volsum1=read_eas(f_volsum1);
d_volsum2=read_eas(f_volsum2);

N1=size(d_volsum1,1);
N2=size(d_volsum2,1);

d_volsum2(:,1)=d_volsum2(:,1)+N1;
d_volgeom2(:,4)=d_volgeom2(:,4)+N1;

d_volsum=[d_volsum1;d_volsum2];
d_volgeom=[d_volgeom1;d_volgeom2];

f_volgeom=sprintf('fvolgeom_%s.eas',name);
f_volsum=sprintf('fvolsum_%s.eas',name);

write_eas(f_volgeom,d_volgeom);
write_eas(f_volsum,d_volsum);
