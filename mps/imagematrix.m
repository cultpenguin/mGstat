function [xl,yl]=imagematrix(M,lw);


if nargin<1; M=membrane;end
if nargin<2, lw=.1; end


imagesc(M);
xlim=get(gca,'xlim');
ylim=get(gca,'ylim');

hold on
for x=xlim(1):1:xlim(2);
    [xl]=plot([1 1].*x,ylim,'-','color',get(gca,'GridColor'),'LineWidth',lw);
end

for y=ylim(1):1:ylim(2);
    [yl]=plot(xlim,[1 1].*y,'-','color',get(gca,'GridColor'),'LineWidth',lw);
end


hold off

axis image

