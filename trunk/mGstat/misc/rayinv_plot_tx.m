% rayinv_plot_tx:plot travel time data from tx.in file
%  
% Ex:
%   D=rayinv_load_tx('tx.in');
%   ishot=1;
%   rayinv_plot_tx(ishot,D);
%
%   ishot=[1,4,5,6];
%   rayinv_plot_tx(ishot,D);
%
%   rayinv_plot_tx(ishot,'tx.in');
%
function rayinv_plot_tx(ishot,D);
if nargin<1
    D=rayinv_load_tx('tx.in');
    ishot=1;
end
if nargin<2, 
    D=rayinv_load_tx('tx.in');
end

if isstr(D)
    D=rayinv_load_tx('tx.in');
end

if isempty(ishot);
    ishot=1:1:length(D);
end

col{1}=[1 0 0];
col{2}=[0 1 0];
col{3}=[0 0 1];
col{4}=[1 1 0];
col{5}=[0 1 1];
col{6}=[1 0 1];
col{7}=[.5 .5 0];
col{8}=[0 .5 .5];
col{9}=[.5 0 .5];
col{10}=[.2 .5 .8];


nsub=ceil(sqrt(length(ishot)));
k=0;
for is=ishot
    
    k=k+1;
    subplot(nsub,nsub,k)
    
    itypes=unique(D(is).itype);
    j=0;
    for it=itypes
        j=j+1;
        i=find(D(is).itype==it);
        try
            color=col{it};
        catch
            color=[1 0 0];
        end
        plot(D(is).recx(i),D(is).data(i),'.','color',color,'MarkerSize',12)
        hold on
        L{j}=num2str(itypes(j));
    end
    title(sprintf('Shot #%02d',is))
    legend(L,'Location','NorthEastOutside')
    %legend(L)
hold off
end

