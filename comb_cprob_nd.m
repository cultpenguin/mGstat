% comb_cprob_nd : PDF combination using permancne of ratios
%
% Combination of 'nd' conditional probabilities 
% based on permanence of updating ratios.
%
% Call : 
%  pAgND=comb_cprob(pA,pAgND,wAgND)
%
%
% pA    [scalar] : Prob(A)
% pAgND [array]  : Prob(A|N1),Prob(A|N2),...,Prob(A|ND)
% wAgBC [array]  : Weight of each cprob
% pAgBC [scala]  : Prob(A|ND)
%
% Combination of conditional probabilities 
% based on permanence of updating ratios.
%
% Journel, An Alternative to Traditional Data Independence
% Hypotheses, Math Geol(34), 2002
% 
%

function pAg=comb_cprob_nd(pA,pAgND,tau)

  if size(pAgND,1)>1
    % This is a matrix....
    [ndata,nd]=size(pAgND);
  else
    nd=length(pAgND);
    ndata=1;
  end
    
  if nargin==2, 
    tau=ones(1,size(pAgND,2));
  end
  
  pAg=zeros(ndata,1);
  
  
  a = (1-pA)./pA;

  for idata=1:ndata
  
    for i=1:nd;
      if pAgND(idata,i)==0
        d(1)=NaN;
      else
        d(i)=(1-pAgND(idata,i))/pAgND(idata,i);
      end
    end
    
    %x = prod(d) / a^(nd-1);
    
    x = prod((d./a).^tau).*a;
    
    pAg(idata) = 1./(1+x);
  end