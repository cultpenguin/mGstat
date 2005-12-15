% krig_optim_range
% CALL : 
%   [V,be]=krig_optim_range(pos_known,val_known,V,options)
%
function [V,be_acc,V_acc]=krig_optim_range(pos_known,val_known,V,options);

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
[d1,d2,be]=gstat_krig_blinderror(pos_known,val_known,pos_known,V_init,options);
be_old=be;
be_init=be;

be_arr=[];

be_min=0.8*be;

nacc=0;
for i=1:100
  
  % perturb model 
  V_new = V_old;
  V_new(2).par2=V_new(2).par2.*(1+rand(size(V_new(2).par2))/1);
  
  [d1,d2,be_new]=gstat_krig_blinderror(pos_known,val_known,pos_known,V_new,options);

  
  PA=min(1,be_old/be_new);

%  disp(sprintf('be = %6.3g  , PA=%6.2g : %s',be_new,PA,format_variogram(V_new)))
  
  Prand=rand(1);
  Prand=1;
  
  be_arr(i)=be_new;
  %plot(be_arr);drawnow;
  
  if PA>Prand
    nacc=nacc+1;

    be_acc(nacc) = be_new;
    V_acc{nacc} = V_new; 
    plot(be_acc);drawnow;
   
    V_old=V_new;
    be_old=be_new;
    disp(sprintf('%3d --OK-- be = %6.3g  , PA=%4.2g Prand=%4.2g : %s',i,be_new,PA,Prand,format_variogram(V_new)))
  else
    disp(sprintf('%3d ------ be = %6.3g  , PA=%4.2g Prand=%4.2g : %s',i,be_new,PA,Prand,format_variogram(V_new)))
  end
  % 
  
end


return

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