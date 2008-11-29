% snesim_set_resim_data : Select and set a region to resimulate.
%
% Call
%    S=snesim_set_resim_data(S,D,lim,pos)
%
%    S : SNESIM of VISIM structure
%    D : completete conditional data set (e.g. S.D(:,:,1));
%    lim : lim(1) : horizontal radius (in cells)
%          lim(2) : vertical radius (in cells)
%
%    pos : center point pos=[x,y] for pertubation
%
function [S pos]=snesim_set_resim_data(S,D,lim,pos)


if nargin<2
    D=S.D(:,:,1)';
end
if isempty(D)
    D=S.D(:,:,1)';
end
    
if nargin<3
    lim(1)=3;
    lim(2)=3;
end

if nargin<4
	pos(1)=min(S.x)+rand(1)*(max(S.x)-min(S.x));
	pos(2)=min(S.y)+rand(1)*(max(S.y)-min(S.y));
end



[xx,yy]=meshgrid(S.x,S.y);
used=xx.*0+1;

used(abs(xx-pos(1)<lim(1)) & abs(yy-pos(2))<lim(2))=0;
ih=find(used);

d_cond=[xx(ih) yy(ih) yy(ih).*0+S.y(1) D(ih)];

if isfield(S,'fconddata')==0
    S.fconddata.fname='cond.eas';
end
write_eas(S.fconddata.fname,d_cond);


