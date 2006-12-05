% visim_plot_smeivar_real : plot experimental semivariogram from VISIM run
%
% CALL : 
%    visim_plot_semivar_real(V)
%
%    [g,hc,sv,hc2]=visim_plot_semivar_real(V,ang,tolerance,cutoff,width)
%
%
% ang : angle with respect to direction of max continutiy. 
%       (ang=0, computes variogram along max and min continuity)
% TMH/2006
%
function [g,hc,sv,hhc]=visim_plot_semivar_real(V,ang,tolerance,cutoff,width)

if isstruct(V)~=1
  V=read_visim(V);
end

if nargin<2
  ang=[0 90];
end

if isempty(ang);  ang=[0 90];end 

nang=length(ang);

if nargin<3
  tolerance=15;
end
if length(tolerance)~=nang
  tolerance=ones(1,nang).*tolerance;
end

if nargin<4
  cutoff=sqrt((max(V.x)-V.x(1)).^2+ (max(V.y)-V.y(1)).^2 + (max(V.z)-V.z(1)).^2)/2;
  cutoff=6;
  cutoff=str2num(sprintf('%12.1g',cutoff));
end
if length(cutoff)~=nang
  cutoff=ones(1,nang).*cutoff;
end

if nargin<5
  width=cutoff./16;
  width=str2num(sprintf('%12.1g',width));
end
if length(width)~=nang
  width=ones(1,nang).*width;
end


col{1}=[0 0 0];
col{2}=[1 0 0];
col{3}=[0 0 1];
lstyle{1}=('-');
lstyle{2}=('--');
lstyle{3}=(':');

for ia=1:length(ang)
    a(ia)=V.Va.ang1+ang(ia);
    [g{ia},hc{ia}]=visim_semivar(V,1:V.nsim,a(ia),tolerance(ia),cutoff(ia),width(ia));
    if isfield(V,'etype')
        V.D(:,:,V.nsim+1)=V.etype.mean;
        [g_lsq{ia},hc_lsq{ia}]=visim_semivar(V,V.nsim+1,a(ia),tolerance(ia),cutoff(ia),width(ia));
    end
end

[v1,v2]=visim_format_variogram(V);
for ia=1:nang;

  if ia==1, 
    vtxt{ia}=v1;
    v1=deformat_variogram(v1);
    hhc{1}=linspace(0,max(hc{1}),40);
    [sv{1}]=semivar_synth(v1,hhc{1},0);  
  else
    vtxt{ia}=v2;
    v2=deformat_variogram(v2);
    hhc{2}=linspace(0,max(hc{2}),40);
    [sv{2}]=semivar_synth(v2,hhc{2},0);  
  end
end

i=0;
for ia=1:length(ang)
  i=i+1;
  subplot(2,2,i)
  pall=plot(hc{ia},g{ia},'-','color',[1 1 1].*.7,'linewidth',.1);
  pall=pall(1);
  hold on
  pmean=plot(hc{ia},mean(g{ia}')','-','color',col{1},'linestyle',lstyle{1});
  p(i)=pall(1);
  
  ptrue=plot(hhc{i},sv{i},'k-','linewidth',3,'linestyle',lstyle{1});

  % PLOT GAMMA OF LEAST SQUARE RESULT !
  if isfield(V,'etype')
      plsq=plot(hc_lsq{1},g_lsq{1},'k--','linewidth',2);
  end
  
  pout{ia}=[pall,pmean,ptrue];
  try
    if ia>0
      [hLeg,hObj]=legend([pall,pmean,ptrue],'All sim','Mean of all sim',vtxt{ia});
      set(hLeg,'box','off')
      set(hLeg,'Location','Best');
    end
  catch
    disp('BOX')
    keyboard
  end


  xlabel('Distance')
  ylabel('Semivariance, \gamma')
  
  axis([0 max(hhc{i}) 0 V.Va.cc*2.0])
  
  hold off
  
end



[f1,f2,f3]=fileparts(V.parfile);
print_mul(sprintf('%s_semivar_real',f2))

