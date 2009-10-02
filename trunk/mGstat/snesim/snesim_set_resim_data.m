% snesim_set_resim_data : Select and set a region to resimulate.
%
% Call
%    S=snesim_set_resim_data(S,D,lim,pos)
%
%    S : SNESIM of VISIM structure
%    D : completete conditional data set (e.g. S.D(:,:,1));
%    lim : lim(1) : horizontal radius (in meter)
%          lim(2) : vertical radius (in meter)
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

[used d_cond_2d]=set_resim_data(S.x,S.y,D,lim,pos);



d_cond=[d_cond_2d(:,1) d_cond_2d(:,2) d_cond_2d(:,2).*0+S.z(1) d_cond_2d(:,3)];
if isfield(S,'fconddata')==0
    S.fconddata.fname='cond.eas';
end
write_eas(S.fconddata.fname,d_cond);


