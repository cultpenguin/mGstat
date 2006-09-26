% hpd_2d : highest posterior density 
%
% call : 
%    [levels]=hpd_2d(lik,hpd_level
%
% lik=abs(peaks);
% levels=hpd_2d(lik,[.1:.2:.9])
% contourf(lik,levels)
%
%
function [levels]=hpd_2d(lik,hpd_levels)
    
    sr=sortrows([lik(:)],1);
    cum_sr=cumsum((sr(:,1)));

    i=0;
    for thres=hpd_levels
        i=i+1;
        ipdf=find(cum_sr>=thres*sum(sr(:,1)));
        
        levels(i)=sr(min(ipdf),1);
        
        %        r12=sr(ipdf,3:4);
        % imagesc(r1,r2,ll)
        % hold on
        % 
        % plot(r12(:,1),r12(:,2),'r.','MarkerSize',thres*2)
        % hold off
        % set(gca,'Ydir','normal')
        % drawnow
        
    end
