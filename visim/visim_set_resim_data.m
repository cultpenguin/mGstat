% visim_set_resim_data : Select and set a region to resimulate.
%
% Call
%    V=visim_set_resim_data(S,D,lim,pos,unc)
%
%    V : SNESIM of VISIM structure
%    D : completete conditional data set (e.g. V.D(:,:,1));
%    lim : lim(1) : horizontal radius (in meter)
%          lim(2) : vertical radius (in meter)
%
%    pos : center point pos=[x,y] for pertubation
%
%    unc : resimulate using uncertainty unc  (standard deviation)   
%
function [S,ih,pos]=visim_set_resim_data(S,D,lim,pos,unc)


if nargin<2
    D=S.D(:,:,1)';
end
if isempty(D)
    D=S.D(:,:,1)';
end
    
if nargin<3, lim=[], end
if isempty(lim);
    lim(1)=3;
    lim(2)=3;
end


if nargin<4, pos=[]; end
if isempty(pos)
	pos(1)=min(S.x)+rand(1)*(max(S.x)-min(S.x));
	pos(2)=min(S.y)+rand(1)*(max(S.y)-min(S.y));
end

if nargin<5
    unc=0;
end

if length(lim)==1;
    lim(2)=lim(1);
end
if length(pos)==1;
    pos(2)=S.y(1);
end


[xx,yy]=meshgrid(S.x,S.y);
used=xx.*0+1;
used(find(abs(xx-pos(1))<lim(1) & abs(yy-pos(2))<lim(2)))=0;
ih=find(used);
ih_not=find(~used);
xxx=xx(ih);
yyy=yy(ih);
ddd=D(ih);

d_cond=[xxx(:) yyy(:) yyy(:).*0+S.z(1) ddd(:)];

% WRITE CONDITIONAL HARD DATA
if isfield(S,'fconddata')==0
    S.fconddata.fname='cond.eas';
end
write_eas(S.fconddata.fname,d_cond);

% WRITE CONDITIONAL UNCERTAIN DATA
if unc>0
    ih_not=find(~used);
    S.fvolgeom.fname='d_volgeom.eas';
    S.fvolsum.fname='d_volsum.eas';
    
    n=length(ih_not);
    idata=[1:1:n]';
    ddd=D(ih_not);
    d_volsum=[idata ones(n,1) ddd(:) ones(n,1).*(unc.^2)];
    
    write_eas(S.fvolsum.fname,d_volsum);
    xxx=xx(ih_not);
    yyy=yy(ih_not);
    zzz=xxx.*0+S.z;
    d_volgeom=[xxx(:) yyy(:) zzz(:) idata(:) ones(n,1)];
    write_eas(S.fvolgeom.fname,d_volgeom);
    
end
