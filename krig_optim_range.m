% krig_optim_range
% CALL : 
%   [V,be]=krig_optim_range(pos_known,val_known,V,options)
%
function [V,be]=krig_optim_range(pos_known,val_known,V,options);

ndim=size(pos_known,2);

options.dummy='';

gvar=var(val_known(:,1));

nnug=13;
nugarr=linspace(0,1,nnug);nugarr(1)=.01;

std_known=std(pos_known);
mean_known=mean(pos_known);

na=25;
for idim=1:ndim
  narr{idim}=na;
  arr{idim}=linspace(0,2*std_known(idim),narr{idim});
  arr{idim}(1)=0.01;
end

Vorig=V;

for in=1:nnug
  dnug=nugarr(in);
  V(1).par1=dnug.*gvar;
  V(2).par1=(1-dnug).*gvar;  

  for a1=1:narr{1}  
%    for a2=1:narr{2}  
      V(2).par2=arr{1}(a1);    
      [d1,d2,be(in,a1)]=gstat_krig_blinderror(pos_known,val_known,pos_known,V,options);
      disp(sprintf('be=%6.4f V=%s',be(in,a1),format_variogram(V)))  
%    end
  end
  imagesc(be);drawnow
end