% krig_optim_1d_exh
% CALL : 
%   [V_L,B_be,ML,Mbe]=krig_optim_1d_exh(pos_known,val_known,V,options);
%
function [V_L,V_be,ML,Mbe,par2_range,nugfrac_range]=krig_optim_1d_exh(pos_known,val_known,V,options);

par2_range=linspace(1,200,30);
nugfrac_range=[0:.05:1];

for ipar2=1:length(par2_range);
  for inug=1:length(nugfrac_range);
    V(2).par2=par2_range(ipar2);
    nugfrac=nugfrac_range(inug);
    V(1).par1=options.gvar.*nugfrac;
    V(2).par1=options.gvar.*(1-nugfrac);
    [d1,d2,be,d_diff,L]=krig_blinderror(pos_known,val_known,pos_known,V,options);
    ML(ipar2,inug)=L;
    Mbe(ipar2,inug)=be;
    MV{ipar2,inug}=V;
  end
  disp(format_variogram(V,1))
end

iML=find(max(ML(:))==ML);
ibe=find(min(Mbe(:))==Mbe);


V_L=MV{iML(1)};
V_be=MV{ibe(1)};

if (isfield(options,'pos_known_all'))
  pos_est=options.pos_known_all;
  rr=.1*max(options.pos_known_all)-min(options.pos_known_all);
  pos_est=linspace(min(options.pos_known_all)-rr,max(options.pos_known_all)+rr,100)+rand(1).*.0001;
else
  rr=.1*max(pos_known)-min(pos_known);
  pos_est=linspace(min(pos_known)-rr,max(pos_known)+rr,100)+rand(1).*.0001;
end

xrange=[min(pos_est) max(pos_est)];

if (isfield(options,'val_known_all'))
  yrange=[min(options.val_known_all(:,1)) max(options.val_known_all(:,1))];
else  
  yrange=[min(val_known(:,1)) max(val_known(:,1))];
end
yrange=yrange+[-.1 .1].*abs(diff(yrange));

[d_L,v_L]=krig(pos_known,val_known,pos_est(:),V_L,options);
[d_be,v_be]=krig(pos_known,val_known,pos_est(:),V_be,options);


if length(iML)>1
  disp(sprintf('More than one optimal ML solution'))
  for i=1:length(iML)
    disp(format_variogram(MV{iML(i)}))
  end
end


if length(ibe)>1
  disp(sprintf('More than one optimal BE solution'))
  for i=1:length(ibe)
    disp(format_variogram(MV{ibe(i)}))
  end
end


disp(sprintf('Optimal Likelihood V : %s',format_variogram(V_L)))
disp(sprintf('Optimal CVE V        : %s',format_variogram(V_be)))


subplot(2,2,1)
imagesc(par2_range,nugfrac_range,ML');
xlabel('Range');ylabel('Nugget proportion')
title('Likelihood')
colorbar
subplot(2,2,2)
imagesc(par2_range,nugfrac_range,-log(Mbe)');
xlabel('Range');ylabel('Nugget proportion')
title('-CrossValidationError')
colorbar


subplot(2,2,3)
p1=plot(pos_est,[d_L d_L+sqrt(v_L) d_L-sqrt(v_L)],'r-',pos_known,val_known(:,1),'k*');
if (isfield(options,'pos_known_all')&isfield(options,'val_known_all'))
  hold on
  plot(options.pos_known_all,options.val_known_all,'k-')
  hold off
end
set(p1(1),'LineWidth',2)
set(gca,'Xlim',xrange);
set(gca,'Ylim',yrange);
title(sprintf('Max Likelihood : %s',format_variogram(V_L,1)))

subplot(2,2,4)
p2=plot(pos_est,[d_be d_be+sqrt(v_be) d_be-sqrt(v_be)],'b-',pos_known,val_known(:,1),'k*');
set(p2(1),'LineWidth',2)
if (isfield(options,'pos_known_all')&isfield(options,'val_known_all'))
  hold on
  plot(options.pos_known_all,options.val_known_all,'k-')
  hold off
end
set(gca,'Xlim',xrange);
set(gca,'Ylim',yrange);
title(sprintf('Min CVE : %s',format_variogram(V_be,1)))

if (isfield(options,'val_known_all'))

  [d_L,v_L]=krig(pos_known,val_known,options.pos_known_all,V_L,options);
  [d_be,v_be]=krig(pos_known,val_known,options.pos_known_all,V_be,options);

  
  highL= find( ((d_L(:,1)+sqrt(v_L))-options.val_known_all)<0);
  lowL= find( ((d_L(:,1)-sqrt(v_L))-options.val_known_all)>0);
  
  highbe= find( ((d_be(:,1)+sqrt(v_be))-options.val_known_all)<0);
  lowbe= find( ((d_be(:,1)-sqrt(v_be))-options.val_known_all)>0);
  
  nL=length(highL)+length(lowL);
  nbe=length(highbe)+length(lowbe);
  
  txt=sprintf('Number og data outside 95%% interval : %d(L) %d(be)',nL,nbe);
  
  
  watermark(txt);
  disp(txt)
end
