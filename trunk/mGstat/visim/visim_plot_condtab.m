% visim_plot_condtab
%
% CALL :
%   visim_plot_condtab(V,doPrint)
%
function [nscore_mean,nscore_var,q,dd,cmean,cvar,kmean,kvar]=visim_plot_condtab(V,doPrint)
  
  if nargin==1, 
    doPrint=0;
  end
  MS=4;
  
  [p,f]=fileparts(V.parfile);
  V.out.fname=[f,'.out'];
  
  fcmean=sprintf('cond_mean_%s',V.out.fname);
  fcvar=sprintf('cond_var_%s',V.out.fname);
  fcpdf=sprintf('cond_cpdf_%s',V.out.fname);
  fk=sprintf('kriging_%s',V.out.fname);
  d_refhist=read_eas(V.refhist.fname);
      
  cmean=load(fcmean);
  cvar=load(fcvar);
  
  k=load(fk);
  kmean=k(:,1);
  kvar=k(:,2);
    
  
  %% F3
  f3=figure;
  figure(f3);set_paper;
  nk=size(k,1);ikmax=3000;
  if nk>ikmax
      ik=round(linspace(1,nk,ikmax));
  else
      ik=1:1:nk;
  end
  pp=plot(k(:,1),k(:,2),'k.',k(:,3),k(:,4),'ro',cmean(:),cvar(:),'bx');
  hold on
  l=line(k(ik,[1,3])',k(ik,[2,4])');
  for i=1:length(ik);set(l(i),'color',[1 1 1].*.8);end
  plot(mean(d_refhist),var(d_refhist),'g.','MarkerSize',38)
  plot(mean(d_refhist),var(d_refhist,1),'y.','MarkerSize',38)
  hold off
  xlabel('mean')
  ylabel('variance')
  title(V.parfile);
  legend(pp,'Kriging ask','Kriging Lookup','Kriging Lookup Available');
  figure(f3);
  [p,f]=fileparts(V.parfile);
  if doPrint==1;
      print_mul(sprintf('%s_condtab1',f));
  end
  %% F2
  if exist(fcpdf)
      d=load(fcpdf);
      
      nm=V.refhist.n_Gmean;
      nv=V.refhist.n_Gvar;
      nq=V.refhist.nq;
      q=[1:1:nq]/nq-(1./nq)/2;
      
      d_refhist=read_eas(V.refhist.fname);
      
      mcmean=reshape(cmean,nv,nm);
      mcvar=reshape(cvar,nv,nm);
      nscore_mean=linspace(V.refhist.min_Gmean,V.refhist.max_Gmean,V.refhist.n_Gmean);
      nscore_var=linspace(V.refhist.min_Gvar,V.refhist.max_Gvar,V.refhist.n_Gvar);
      
      dd=reshape(d,nq,nv,nm);
      f2=figure;
      %f3=figure;
      
      xlim=[min(dd(:)) max(dd(:))];
      dxlim=0.01*(xlim(2)-xlim(1));
      xlim = xlim + [-1 1].*dxlim;
          
      %% PLOT LOCAL PDFS
      nsm=5;
      nsv=3;     
      if (nsm<nsv)
          figure(f2);set_paper('landscape');
      else
          figure(f2);set_paper('portrait');
      end
      iim=0;iiv=0;
      for im=round(linspace(1,nm,nsm))
          iim=iim+1;
          iiv=0;
          for iv=round(linspace(1,nv,nsv))
              iiv=iiv+1;
              figure(f2)
              subplot(nsm,nsv,(iim-1)*nsv+iiv);
              plot(squeeze(dd(:,iv,im)),q,'k-','LineWidth',2);
              
              hold on;
              [h,hx]=hist(d_refhist,1000);
              hh=cumsum(h);
              hh=hh./max(hh);
              plot(hx,hh,'g-')
              hold off
              
              t=title(sprintf('[%4.2f,%4.2f] ns:(%4.2f,%4.2f)',mcmean(iv,im),mcvar(iv,im),nscore_mean(im),nscore_var(iv)));
              set(t,'FontSize',6);
              set(gca,'FontSize',6)
              axis([xlim 0 1])
          end
      end
      
      if doPrint==1;
          figure(f2);
          [p,f]=fileparts(V.parfile);
          print_mul(sprintf('%s_condtab2',f));
      end
  end
  
  
  