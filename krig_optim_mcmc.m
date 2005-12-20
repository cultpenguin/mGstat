% krig_optim_mcmc
% CALL : 
%   [V,be]=krig_optim_range(pos_known,val_known,V,options)
%
function [V,be_acc,L_acc,par2]=krig_optim_mcmc(pos_known,val_known,V,options);

if isstr(V),
  V=deformat_variogram(V);
end 

ndim=size(pos_known,2);

options.dummy='';

gvar=var(val_known(:,1));

nnug=13;
nugarr=linspace(0,1,nnug);nugarr(1)=.01;

std_known=std(pos_known);
mean_known=mean(pos_known);


% A PRIORI 
na=25;
for idim=1:ndim
  narr{idim}=na;
  arr{idim}=linspace(0,2*std_known(idim),narr{idim});
  arr{idim}(1)=0.01;
end

V_init=V;
V_old=V;
[d_est,d_var,be_init,d_diff,L_init]=gstat_krig_blinderror(pos_known,val_known,pos_known,V_init,options);

be_old=be_init;
L_old=L_init;

L_arr=[];

range_min=0.001;

nacc=0;
imax=1000;
for i=1:imax
  
  % perturb model 
  V_new = V_old;

  
  % 
  step=0.15;
  %step=0.05;
  V_new(2).par2=V_new(2).par2 + step*randn(size(std_known)).*std_known;

  % MAKE SURE RANGE IS POSITIVE  
  %V_new(2).par2(find(V_new(2).par2<=0))=0.01;
  %V_new(2).par2(find(V_new(2).par2>1500))=1500;

  % TEST FOR 
  compL=1;
  if ~isempty(find(V_new(2).par2<=0)), compL=0; end
 
  if ~isempty(find(V_new(2).par2>=200000)), compL=0; end
  
  if compL==1
    try
      [d1,d2,be_new,d_diff,L_new]=gstat_krig_blinderror(pos_known,val_known,pos_known,V_new,options);
    catch
      keyboard
    end
    
  else
    L_new=-1e-45;
  end
    
  % Pacc=min([(L_new-L_min)/(L_old-L_min),1]);
  Pacc=min([(L_new)/(L_old),1]);

  thres=100000;
  if (Pacc<1)&(i>thres)
    fac= (1+sin( pi/2 + (i-thres)/(imax-thres).*pi))./2;
    fac=fac.*.1;
    disp(fac)
    fac=0.1;
     Pacc=Pacc.*fac;
  end
  
  
  Prand=rand(1);
  
  if Pacc>Prand
%  if Pacc==1  % ONLY ACCPET IMPROVEMENTS
    % ACCEPT
    
    V_old=V_new;
    L_old=L_new;
    be_old=be_new;
    
    nacc=nacc+1;
    
    par2(nacc,:)=V_new(2).par2;
    
    L_acc(nacc) = L_new;
    be_acc(nacc) = be_new;
    V_acc{nacc} = V_new; 

    subplot(1,2,1)
    plotyy(1:nacc,L_acc,1:nacc,be_acc);drawnow;
    subplot(1,2,2)
    if size(par2,2)==1
      scatter(par2(:,1),L_acc,'k.')
    elseif size(par2,2)==2
      scatter(par2(:,1),par2(:,2),22,L_acc,'filled')
    end
    V_old=V_new;
    L_old=L_new;
    disp(sprintf('%3d --OK-- L = %6.3g  , PA=%4.2g Prand=%4.2g : %s',i,L_new,Pacc,Prand,format_variogram(V_new)))
  else
    %disp(sprintf('%3d ------ L = %6.3g  , PA=%4.2g Prand=%4.2g : %s',i,L_new,Pacc,Prand,format_variogram(V_new)))
  end

  
end


return

for in=1:nnug
  dnug=nugarr(in);
  V(1).par1=dnug.*gvar;
  V(2).par1=(1-dnug).*gvar;  

  for a1=1:narr{1}  
%    for a2=1:narr{2}  
      V(2).par2=arr{1}(a1);    
      [d1,d2,be(in,a1),d_diff,L]=gstat_krig_blinderror(pos_known,val_known,pos_known,V,options);
      disp(sprintf('be=%6.4f V=%s',be(in,a1),format_variogram(V)))  
%    end
  end
  imagesc(be);drawnow
end