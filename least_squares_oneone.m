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

for k=1:nd
    if (k/50)==round(k/50)
    progress_txt(k,nd);
    subplot(2,1,1)
    imagesc(reshape(1./m0,20,50));axis image;%;caxis([1 3])
    subplot(2,1,2)
    imagesc(reshape(diag(cm),20,50));axis image;%;caxis([0 0.1])
    drawnow;
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
    
    for i=1:nm
        m0(i)=m0(i)+q(i)*v/a;
        for j=1:nm
            cm(i,j)=cm(i,j)-q(i)*q(j)/a;
        end
    end
    
%    for i=1:nm
%        m0(i)=m0(i)+q(i)*v/a;
%       for j=1:nm
%            cm(i,j)=cm(i,j)-q(i)*q(j)/a;
%        end
%    end
    
    
end

