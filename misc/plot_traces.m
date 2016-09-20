
function plot_traces(input,scale,t1,t2,color,FigN)

d_obs=input;

ti=0:0.1:100;

for j=1:2:length(d_obs(:,1))
    E1=interp1(0:100/(length(d_obs(j,:))-1):100,d_obs(j,:),ti);
    figure(FigN),hLine=plot(ti,-1*(scale*E1-j),color,'linewidt',2);axis([t1 t2 0 j+1]),
    hold on,xlabel('Time (ns)','fontsize',12),ylabel('Trace Number','fontsize',12)
    if j>1
        set(get(get(hLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
end

set(gca,'ydir','reverse')
set(gcf,'position',[20 100 300 500])