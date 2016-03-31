% snesim_init : load default parameter file and training image
%
% Call : 
%   S = snesim_init;
%   S = snesim;
%   imagesc(S.D(:,:));
%
%   ti=channels;
%   S = snesim_init(ti);
%   S = snesim(S,1:1:30,1:1:30);
%   imagesc(S.D(:,:));
%
%
% See also: snesim 
%
function S=snesim_init(training_image,x,y,z);

load snesim_init_v10

if nargin>0;
    ti=training_image;
end

if nargin>1
  S.nx=length(x);
  S.xmn=x(1);
  S.xsiz=x(2)-x(1);
  S.x=x;
end
if nargin>2
  S.ny=length(y);
  S.ymn=y(1);
  S.ysiz=y(2)-y(1);
  S.y=y;
end
if nargin>3
  S.nz=length(z);
  S.zmn=z(1);
  if S.nz==1,
    S.zsiz=1;
  else
    S.zsiz=z(2)-z(1);
  end
  S.z=z;
end
    

cat_code=sort(unique(ti(:)));
S.ncat=length(cat_code);
S.cat_code=cat_code;
for i=1:length(cat_code)
    S.pdf_target(i)=length(find(ti==cat_code(i)));
end
S.pdf_target=S.pdf_target./sum(S.pdf_target);

dim=size(ti);

if length(dim)==1
    % 1D
    write_eas(S.ti.fname,ti(:));
   
    S.ti.nx=dim(1);
    S.ti.ny=1;
    S.ti.nz=1;
    S.ti.col_var=1;
elseif length(dim)==2
    % 2D
    ti=ti';
    write_eas(S.ti.fname,ti(:));
   
    S.ti.nx=dim(2);
    S.ti.ny=dim(1);
    S.ti.nz=1;
    S.ti.col_var=1;
elseif length(dim)==3
    % 3D
    write_eas(S.ti.fname,ti(:));
   
    S.ti.nx=dim(1);
    S.ti.ny=dim(2);
    S.ti.nz=dim(3);
    S.ti.col_var=1;
end
