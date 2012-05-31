% plot_mh_loglikelihood % plot loglikelihood time series
%                         plots accept ratio
%
% Call : 
%    plot_mh_loglikelihood(L_acc,i_acc,N,itext)
%
%
%


function acc=plot_mh_loglikelihood(L_acc,i_acc,N,itext);

acc=NaN;
%cla;

if nargin<2
    i_acc=1:1:length(L_acc);
end

if nargin<3
    N=1;
end

if nargin<4
    itext=max(i_acc)/5;
end

xlim=[i_acc(1) max(i_acc)+1e-4];

plot(i_acc,L_acc,'k.')
%semilogy(i_acc,L_acc,'k-')
set(gca,'xlim',xlim)

%% FORMAT Y TICK
%Yt=get(gca,'Ytick')';
%for i=1:length(Yt)
%    Yl{i}=sprintf('%4.1f',Yt(i));
%end
%set(gca,'YtickLabel',Yl);

if nargin>2
    hold on
    plot(xlim,[-1 -1].*N/2,'r-','linewidth',2)
    plot(xlim,[-1 -1].*N/2+sqrt(N/2),'r--')
    plot(xlim,[-1 -1].*N/2-sqrt(N/2),'r--')
    
    hold off
end
ylim=get(gca,'ylim');
dy=diff(ylim);
ylim(1)=ylim(1)-.1*dy;
ylim(2)=ylim(2)+.1*dy;
set(gca,'ylim',ylim);
ntext=min([ceil(length(L_acc)/30) 15]);
ntext=ceil(length(L_acc)/itext);
ii=unique(round(linspace(1,length(L_acc),ntext)));
dt=.1.*(ylim(2)-ylim(1));
if length(ii)>2;
    for i=2:(length(ii))     
        j=ii(i);
        acc=(ii(i)-ii(i-1)) / (i_acc(ii(i))-i_acc(ii(i-1)));
        y=min([L_acc(j)+dt,ylim(2)]);
        %t=text(i_acc(j),min([L_acc(j)+dt,ylim(2)]),sprintf('%2.1f',100.*acc));
        %set(t,'FontSize',8,'HorizontalAlignment','center')
    end
end

xlabel('Iteration');
ylabel('log(L)');
%set(gca,'xlim',xlim)
%set(gca,'ylim',ylim)
