% least_squares_oneone : Least squares inverison using only scalar 
%                        operations. (only valid when offdiag(Cd)=0)
%
% See Tarantola (2005), Inverse Problem Theory, page 198, Ch 6.
% 
% Call : 
%   [m_est,sigma2,Cm_est]=least_squares_oneone(G,Cm,Cd,m0,d_obs)
%
function [m0,sigma2,cm]=least_squares_oneone(g,cm,cd,m0,d0)
[nd,nm]=size(g);

t1=now;

for k=1:nd
    dk=1;
    if (k/dk)==round(k/dk)
        if k>1
            dt=(t2-t1)./(k-1);
            t_left=(nd-(k-1))*dt;
            t_end=t1+t_left;
            str=datestr(t_end,'DD/mm HH:MM:SS')
            str=sprintf('%4.1fs %14s',t_left*3600*24,str);
        else
            str='';
        end
        progress_txt(k-1,nd,str);
        try
            subplot(2,1,1)
            imagesc(reshape(1./m0,20,50));axis image;%;caxis([1 3])
            subplot(2,1,2)
            imagesc(reshape(diag(cm),20,50));axis image;%;caxis([0 0.1])
            drawnow;
        end
        t2=now;
    end
    
    v=d0(k);
    for i=1:nm
        v = v - g(k,i)*m0(i);
        q(i) = 0;
        for j=1:nm
            q(i)=q(i)+cm(i,j)*g(k,j);
        end
    end
    a=cd(k);
    for i=1:nm
        a=a+g(k,i)*q(i);
    end
    
    if nargout==3
        % FULL Cm
        for i=1:nm
            m0(i)=m0(i)+q(i)*v/a;
            for j=1:nm
                cm(i,j)=cm(i,j)-q(i)*q(j)/a;
            end
        end
    
    else
        % DIAGONAL Cm
        for i=1:nm
            m0(i)=m0(i)+q(i)*v/a;
            for j=i
                cm(i,j)=cm(i,j)-q(i)*q(j)/a;
            end
        end
    end
    
    
end
sigma2=diag(cm);
