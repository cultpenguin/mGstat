function [gmat,gc,p5,p50,p95]=semivar_mat(hc,g,garr)
  
  if nargin<3
    ngarr=20;
    garr=linspace(0,max(g(:)),ngarr);
  end      
  ngarr=length(garr);
  
  ng=size(g,2);
  
  gc=(garr(1:(ngarr-1))+garr(2:ngarr))./2;
  
  gmat=zeros(length(garr)-1,length(hc));
  
  for ih=1:length(hc);
    for ig=1:(length(garr)-1);
      ii=find( g(ih,:)>garr(ig)  & g(ih,:)<garr(ig+1) );
      gmat(ig,ih)=length(ii);
    end    
    
    
    %gmat=semivar_mat(hc,g)
    x=cumsum(gmat(:,ih));
    x=x(:)'+[1:1:length(x)].*.00001;
      %gmat=semivar_mat(hc,g)
    x=cumsum(gmat(:,ih));
    x=x(:)'+[1:1:length(x)].*.00001;
  
    p5(ih)=interp1(x(:),gc(:),.05*ng);
    p50(ih)=interp1(x(:),gc(:),.50*ng);
    p95(ih)=interp1(x(:),gc(:),.95*ng);
    
    
  end
  
  