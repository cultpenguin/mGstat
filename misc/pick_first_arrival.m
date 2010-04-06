% pick_first_arrival : pick first arrival travel time data using simple
%                      correlaion
%
% Call 
%   [tt_pick]=pick_first_arrival(wf_data,ref_trace,ref_t0,doPlot,wf_time);
%
function [tt_pick,time_pick,c]=pick_first_arrival(wf_data,ref_trace,ref_t0,doPlot,wf_time);
if nargin<5,    wf_time=[];end
if nargin<4,    doPlot=1;end
if nargin<3,    ref_t0=1;end
if nargin<2,    ref_trace=wf_data(:,1);end

[ns,nt]=size(wf_data);
ns_ref=length(ref_trace);


if doPlot==1;
    %f1=figure(1);
    f1=gcf;
    set(0,'CurrentFigure',f1)
    subplot(1,2,1);
    plot(ref_trace,1:1:ns_ref,'ko');
    xlim=get(gca,'xlim');
    ax=axis;
    hold on;
    plot([xlim],[ref_t0 ref_t0],'r-');
    hold off;
    axis(ax);
    set(gca,'ydir','revers')
end



for it=1:nt;
    if nt>1;
        progress_txt(it,nt);
    end
    for i=1:ns-ns_ref;
        cc=corrcoef(wf_data(i:(i+ns_ref-1),it),ref_trace);
        c(i)=cc(2);
    end
    ipick=find(c==max(c));ipick=ipick(1);
    try
        P=polyfit(ipick-5:ipick+5,c(ipick-5:ipick+5),2);
        tt_pick(it)=-P(2)/(2*P(1))+ref_t0-1;
    catch
        tt_pick(it)=ipick+ref_t0-1;
    end
    
end
if doPlot==1;
    set(0,'CurrentFigure',f1)
    subplot(1,2,2);
    imagesc(1:1:nt,1:1:ns,wf_data);
    hold on
    plot(1:1:it,tt_pick(1:1:it),'w-*')
    hold off
    drawnow;
end
    
if ~isempty(wf_time);
    time_pick=interp1(1:1:(length(wf_time)),wf_time,tt_pick);
end
