% estim_taran, one data set : Tarantola equations (16-17) 
% 
% CALL : [m_est,Cm_est]=estim_taran(G,Cm,Cd,m0,d0);
function [m_est,Cm_est]=estim_taran(G,Cm,Cd,m0,d0,type);
  
  if nargin<6, type=2;end

  if type==2,
    S = Cd + G*Cm*G';    
    T = inv(S);
    %disp([mfilename,' : Estimating m_est type1'])
    m_est  = m0 + Cm*G'*T*(d0-G*m0);
    if nargout>1
      % disp([mfilename,' : Estimating Cm type1'])
      Cm_est = Cm - Cm*G'*T*G*Cm; % SLOW
    end
   
  else
  
    
    if size(G,1)==1,
      goodG=find(G~=0);
    else
      goodG=find(sum(G)~=0);
    end
    
    S = Cd + G(:,goodG)*Cm(goodG,goodG)*G(:,goodG)';
    T = inv(S);
    
    %disp([mfilename,' : Estimating m_est type2'])
    m_est = m0 + Cm(:,goodG)*G(:,goodG)'*T*(d0-G*m0); 
    
    if nargout>1
      %disp([mfilename,' : Estimating Cm type2']) 
      PP=Cm*G'*T*G;
      Cm_est = Cm -PP(:,goodG)*Cm(goodG,:);
    end
  end