function cov=precal_cov(pos1,pos2,V);
  
  n_est1=size(pos1,1);
  n_est2=size(pos2,1);

  cov=zeros(n_est1,n_est2);
  d=zeros(n_est1,n_est2);
  mgstat_verbose([mfilename,' : Setting up covariance']);
  for i=1:n_est1;
    progress_txt(i,n_est1,sprintf('%s : ',mfilename));
    for j=1:n_est2;
      d(i,j)=edist(pos1(i,:),pos2(j,:));
    end
  end
  gvar=sum([V.par1]);
  cov=gvar-semivar_synth(V,d);  
  