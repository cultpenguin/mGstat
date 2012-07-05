% set_resim_data_3d : Select and set a region to resimulate.
%
% Call
%    resim_grid=set_resim_data_3d(x,y,z,D,lim,pos,wrap_around)
%
%    D : completete conditional data set (e.g. S.D(:,:,1));
%    lim : lim(1) : horizontal radius (in meter)
%          lim(2) : vertical radius (in meter)
%          lim(3) : Z
%
%    pos : center point pos=[x,y] for pertubation
%    wrap_around : [0]: no wrapping default, 
%                  [1]: wrapping (use with e.g. fft_ma_2d);
%
function [used d_cond]=set_resim_data_3d(x,y,z,D,lim,pos,wrap_around)


if nargin<4
    lim(1)=3;
    lim(2)=3;
    lim(3)=3;
end
if nargin<5
	pos(1)=min(x)+rand(1)*(max(x)-min(x));
	pos(2)=min(y)+rand(1)*(max(y)-min(y));
	pos(3)=min(y)+rand(1)*(max(z)-min(z));
end
if nargin<6
    wrap_around=0;
end
if length(lim)==1;
    lim(2)=lim(1);
    lim(3)=lim(1);
end
if length(pos)==1;
    pos(2)=S.y(1);
    pos(3)=S.z(1);
end


[xx,yy,zz]=meshgrid(x,y,z);
used=ones(size(xx));
used(find( abs(xx-pos(1))<lim(1) & abs(yy-pos(2))<lim(2) & abs(zz-pos(3))<lim(3)   ))=0;

if wrap_around==1
    disp('wrap around not yet implemented !!')
    %    used(find(abs(fliplr(xx)+pos(1))<lim(1) & abs(yy-pos(2))<lim(2)))=0;
    %    used(find(abs(fliplr(xx)+pos(1))<lim(1) & abs(flipud(yy)+pos(2))<lim(2)))=0;
    %    used(find(abs(xx-pos(1))<lim(1) & abs(flipud(yy)+pos(2))<lim(2)))=0;
end
if nargout>1
    ih=find(used);
    xxx=xx(ih);
    yyy=yy(ih);
    zzz=zz(ih);
    ddd=D(ih);    
    d_cond=[xxx(:) yyy(:) zzz(:) ddd(:)];
end
