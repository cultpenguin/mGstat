function set_paper(paper_orientation,paper_type,updatePaperSize);
% set_paper : set default paper orientation
%
% set_paper('landscape')
% or
% set_paper('portrait')
% or
% set_paper('portrait','a3')
% or ...
%
%
if nargin==0
	paper_orientation='landscape';
end
if nargin<2
	paper_type='a4';
end
if nargin<3
	updatePaperSize=0;
end

set(0,'DefaultFigurePaperType',paper_type);
set(0,'DefaultFigurePaperOrientation',paper_orientation);

set(gcf,'PaperType',paper_type);
set(gcf,'PaperOrientation',paper_orientation);

set(gcf,'PaperPositionMode','Manual');
PS=get(gcf,'PaperSize');
b=.1;
set(gcf,'PaperPosition',[b b PS(1)-2*b PS(2)-2*b]);


% update figure size on screen to match paper
if updatePaperSize==1;
    PS=get(gcf,'PaperSize');
    r=PS(2)/PS(1);
    pos=get(gcf,'Position');
    h_new=pos(3)*r;
    dh=h_new-pos(4);
    set(gcf,'Position',[pos(1), pos(2)-dh, pos(3), h_new]);
end


