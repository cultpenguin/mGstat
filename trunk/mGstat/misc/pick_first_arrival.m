function [tt_pick,c]=pick_first_arrival(wf_data,ref_trace,ref_t0,doPlot);
if nargin<4,    doPlot=1;end
if nargin<3,    ref_t0=1;end
if nargin<2,    ref_trace=wf_data(:,1);end

[ns,nt]=size(wf_data);
ns_ref=length(ref_trace);


if doPlot==1;
    f1=figure(1);
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
    progress_txt(it,nt);
    for i=1:ns-ns_ref;
        cc=corrcoef(wf_data(i:(i+ns_ref-1),it),ref_trace);
        c(i)=cc(2);
    end
    ipick=find(c==max(c));ipick=ipick(1);
    tt_pick(it)=ipick+ref_t0-1;
    

    if doPlot==1;
        set(0,'CurrentFigure',f1)
        subplot(1,2,2);
        imagesc(1:1:nt,1:1:ns,wf_data);
        hold on
        plot(1:1:it,tt_pick(1:1:it),'w-*')
        hold off
        drawnow;
    end
    
end
