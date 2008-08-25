function set_paper(paper_orientation,paper_type);
% set_paper : set default paper orientation
%
% set_paper('landscape')
% or
% set_paper('portrait')
%
if nargin==0
	paper_orientation='landscape';
end
if nargin<2
	paper_type='a4';
end

set(0,'DefaultFigurePaperType',paper_type);
set(0,'DefaultFigurePaperOrientation',paper_orientation);
set(gcf,'PaperPositionMode','Manual');
PS=get(gcf,'PaperSize');
b=.1;
set(gcf,'PaperPosition',[b b PS(1)-2*b PS(2)-2*b]);


