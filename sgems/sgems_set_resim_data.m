% sgems_set_resim_data : Select and set a region to resimulate.
%
% Call
%    S=sgems_set_resim_data(S,D,lim,pos)
%
%    S : SGEMS structure
%    D : completete conditional data set (e.g. S.D(:,:,1)');
%    lim : lim(1) : horizontal radius (in cells)
%          lim(2) : vertical radius (in cells)
%
%    pos : center point pos=[x,y] for pertubation
%
function S=snesim_set_resim_data(S,D,lim,resim_type)

if nargin<2
    D=S.D(:,:,1)';
end
if isempty(D)
    D=S.D(:,:,:,1)';
end
    
if nargin<3
    lim(1)=3;
    lim(2)=3;
    lim(3)=3;
end

if nargin<4
    resim_type=1; % SQUARE AREA
    %resim_type=2; % NUMBER OF DATA
end

if length(lim)<2, lim(2:3)=lim(1);end
if length(lim)<3, lim(3)=lim(2);end

pos(1)=min(S.x)+rand(1)*(max(S.x)-min(S.x));
pos(2)=min(S.y)+rand(1)*(max(S.y)-min(S.y));
pos(3)=min(S.z)+rand(1)*(max(S.z)-min(S.z));



[xx,yy,zz]=meshgrid(S.x,S.y,S.z);

if resim_type==2;
    nn=prod(size(xx));
    %ih=unique(ceil(nn*rand(1,lim(1)*nn)));
    ih_inv=unique(ceil(nn*rand(1,ceil(lim(1)*nn))));
    
    ih=setxor(ih_inv,1:1:nn);
    d_cond=[xx(ih(:)) yy(ih(:)) zz(ih(:)) D(ih(:))];
    disp(resim_type)
else
    used=xx.*0+1;
    used(find( (abs(xx-pos(1))<lim(1)) & (abs(yy-pos(2))<lim(2)) ))=0;
    ih=find(used);
    d_cond=[xx(ih) yy(ih) zz(ih) D(ih)];
end

if isfield(S,'f_obs')==0
    S.f_obs='f_obs.sgems';
end

sgems_write_pointset(S.f_obs,d_cond);
%,header,title);
%write_eas(S.fconddata.fname,d_cond);


