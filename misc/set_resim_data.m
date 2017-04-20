% set_resim_data : Select and set a region to resimulate.
%
% Call
%    resim_grid=set_resim_data(x,y,D,lim,pos,wrap_around)
%
%    D : completete conditional data set (e.g. S.D(:,:,1));
%    lim : lim(1) : horizontal radius (in meter)
%          lim(2) : vertical radius (in meter)
%
%    pos : center point pos=[x,y] for pertubation
%    wrap_around : [0]: no wrapping default, 
%                  [1]: wrapping (use with e.g. fft_ma_2d);
%
% 
% See also: set_resim_data_3d
%
function [used,d_cond,pos]=set_resim_data(x,y,D,lim,pos,wrap_around,xx,yy)

if nargin==0;
    x=1:1:10;y=1:1:20;D=rand(length(y),length(x));
    for ix=20;1:length(x);
    for iy=1:20;1:length(y);
        [used,d_cond]=set_resim_data(x,y,D,[3 3],[ix iy],1);
        imagesc(used);axis image
        drawnow;
        disp(length(find(used==0)))
        pause(.1);
    end
    end
    return
end


if nargin<4
    lim(1)=3;
    lim(2)=3;
end
if nargin<5
	pos(1)=min(x)+rand(1)*(max(x)-min(x));
	pos(2)=min(y)+rand(1)*(max(y)-min(y));
end
if nargin<6
    wrap_around=0;
end
if length(lim)==1;
    lim(2)=lim(1);
end
if length(pos)==1;
    pos(2)=S.y(1);
end

if nargin<7
    [xx,yy]=meshgrid(x,y);
end
used=ones(size(xx));
used(abs(xx-pos(1))<lim(1) & abs(yy-pos(2))<lim(2))=0;

if wrap_around==1    
    % upper x
    used(abs(xx-(pos(1)-max(x)))<lim(1) & abs(yy-pos(2))<lim(2))=0;
    % upper y
    used(abs(xx-pos(1))<lim(1) & abs(yy-(pos(2)-max(y)))<lim(2))=0;    
    % upper x&y
    used(abs(xx-(pos(1)-max(x)))<lim(1) & abs(yy-(pos(2)-max(y)))<lim(2))=0;
    % lower x
%     used(find(abs(fliplr(xx)+pos(1))<=lim(1) & abs(yy-pos(2))<lim(2)))=0;
%     % lower x, lower y
%     used(find(abs(fliplr(xx)+pos(1))<=lim(1) & abs(flipud(yy)+pos(2))<=lim(2)))=0;
%     % lower y
%     used(find(abs(xx-pos(1))<lim(1) & abs(flipud(yy)+pos(2))<=lim(2)))=0;
%     % upper x, lower y
%     used(find(abs(xx-( pos(1)- max(x) ))<=lim(1) & abs(flipud(yy)+pos(2))<=lim(2)))=0;
%     % lower x, upper y 
%     used(find(abs(fliplr(xx)+pos(1))<=lim(1) & abs(yy-(pos(2)-max(y)))<lim(2)))=0;
%         
    used(abs(fliplr(xx)+pos(1)-1)<lim(1) & abs(yy-pos(2))<lim(2))=0; % Corrected
    % lower x, lower y
    used(abs(fliplr(xx)+pos(1)-1)<lim(1) & abs(flipud(yy)+pos(2)-1)<lim(2))=0; % Corrected
    % lower y
    used(abs(xx-pos(1))<lim(1) & abs(flipud(yy)+pos(2)-1)<lim(2))=0; % Corrected
    % upper x, lower y 
    used(abs(xx-( pos(1)- max(x) ))<lim(1) & abs(flipud(yy)+pos(2)-1)<lim(2))=0; % Corrected
    % lower x, upper y 
    used(abs(fliplr(xx)+pos(1)-1)<lim(1) & abs(yy-(pos(2)-max(y)))<lim(2))=0; % Corrected

end
if nargout>1
    ih=find(used);
    xxx=xx(ih);
    yyy=yy(ih);
    ddd=D(ih);    
    d_cond=[xxx(:) yyy(:) ddd(:)];
end
