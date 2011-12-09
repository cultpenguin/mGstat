% pick_first_arrival : pick first arrival travel time data using simple
%                      correlaion
%
% Call 
%   [tt_pick]=pick_first_arrival(wf_data,ref_trace,ref_t0,doPlot,wf_time);
%
function [tt_pick,time_pick,c]=pick_first_arrival(wf_data,ref_trace,ref_t0,doPlot,wf_time,use_method);
if nargin<6,    use_method=1;end % 1: Molyneux, 2: simple
if nargin<5,    wf_time=[];end
if nargin<4,    doPlot=0;end
if nargin<3,    ref_t0=1;end
if nargin<2,    ref_trace=wf_data(:,1);end

[ns,nt]=size(wf_data);
ns_ref=length(ref_trace);

max_amp=max(abs(wf_data(:)));




if doPlot==1;
    %f1=figure(1);
    f1=gcf;
    set(0,'CurrentFigure',f1)
    subplot(1,3,1);
    plot(ref_trace,1:1:ns_ref,'ko');
    xlim=get(gca,'xlim');
    ax=axis;
    hold on;
    plot([xlim],[ref_t0 ref_t0],'r-');
    hold off;
    axis(ax);
    set(gca,'ydir','revers')
end

% TRACE NORMALIZE
%    for i=1:size(wf_data,2);
%        wf_data(:,i)=wf_data(:,i)./max(wf_data(:,i));
%    end
    

c=zeros(1,ns-ns_ref);
c_all=zeros(nt,ns-ns_ref);
for it=1:nt;
    %if nt>1;        progress_txt(it,nt);    end
    
    if use_method==1;
        parfor i=1:(ns-ns_ref);
            cc=corrcoef(wf_data(i:(i+ns_ref-1),it),ref_trace);
            c(i)=cc(2);
        end
        
        c_all(it,:)=c;
        ipick=find(c==max(c));ipick=ipick(1);

        try
            P=polyfit(ipick-5:ipick+5,c(ipick-5:ipick+5),2);
            tt_pick(it)=-P(2)/(2*P(1))+ref_t0-1;
        catch
            tt_pick(it)=ipick+ref_t0-1;
        end

        
    elseif use_method==2;
        % SIMPLE METHOD FINDING THE FA LOCATING FIRST VALUE ABOVE
        % A CERTAIN THRESHOLD. ONLY GOOD FOR NOISE FREE DATA
        % AN IN CASES VERE THE POLARITY OF THE FA CHANGES A LOT
        k=find(abs(wf_data(:,it))>(.003.*max(abs(wf_data(:,it)))));
        try
            ipick=k(1);
        catch
            ipick=NaN;
        end
        tt_pick(it)=ipick;
    end
    
    % Interpolate to find more precise time
        
        
    
end



if doPlot==1;
    set(0,'CurrentFigure',f1)
    subplot(1,3,2);
    % S/N = 26 add
    %sig=max(wf_data(:));
    %wf_data=wf_data+(sig/26).*randn(size(wf_data));
    
    % TRACE NORMALIZE
    for i=1:size(wf_data,2);
        wf_data(:,i)=wf_data(:,i)./max(wf_data(:,i));
    end
       
    %imagesc(1:1:nt,1:1:ns,wf_data);
    %caxis([-1 1].*.01)
    wiggle(1:1:nt,1:1:ns,wf_data);
    hold on
    plot(1:1:it,tt_pick(1:1:it),'r-*')
    hold off
    subplot(1,3,3);
    try
        imagesc(1:1:nt,1:1:ns,c_all')
        title('Correlation coefficient')
    end
    drawnow;
end
    
if ~isempty(wf_time);
    time_pick=interp1(1:1:(length(wf_time)),wf_time,tt_pick);
end

