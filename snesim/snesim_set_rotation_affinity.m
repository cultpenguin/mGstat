function S=snesim_set_rotation_affinity(S,rot,aff);

if nargin<2, rot=0; end
if nargin<3, aff=1; end


if length(rot)==1;
  rot=ones(S.ny,S.nx,S.nz).*rot;
end;

if length(rot)==1;
  rot=ones(S.ny,S.nx.S.nz).*rot;
end;

if length(aff)==1;
  aff_xyz=[1 1 1].*aff;
  n_cat=size(aff,1);
  aff_class=ones(S.ny,S.nx,S.nz);
end

h{1}='ang';
h{2}='factor class';

S.frotaff.n_cat=n_cat;
S.frotaff.aff_xyz=aff_xyz;
S.frotaff.use=1;

write_eas(S.frotaff.fname,[rot(:) aff_class(:)],h,'rotationa addinity file for SNESIM');