% semivar_map : create 2D semivariogram map
%
% See Goovaerts, p. 99
%
function [vmap,hx,hy,nvmap,gamma,dp]=semivar_map(pos,val)

  [hc,garr,h,gamma,hangc,z_head,z_tail,dp]=semivar_exp(pos,val);
  q3=find(dp(:,1)<=0 & dp(:,2)<=0);
  dp(q3,1)=-1.*dp(q3,1);
  dp(q3,2)=-1.*dp(q3,2);
  q2=find(dp(:,1)>=0 & dp(:,2)<0);
  dp(q2,1)=-1.*dp(q2,1);
  dp(q2,2)=-1.*dp(q2,2);

  mhx=max(h)./2;
  mhy=max(h)./2;
  
  nhx=20;
  nhy=10;
  
  hx=linspace(-mhx,mhx,nhx+1);
  hy=linspace(0,mhy,nhy+1);
  
  vmap=zeros(nhy,nhx);
  nvmap=zeros(nhy,nhx);

  for ix=1:(nhx)
    disp(sprintf('%d/%d',ix,nhx));
  for iy=1:(nhy)

    ii = find( dp(:,1)>=hx(ix) & dp(:,1)<hx(ix+1) & dp(:,2)>=hy(iy) & dp(:,2)<hy(iy+1) );

    if length(ii)>0
      vmap(iy,ix)=mean(gamma(ii));
    end
    nvmap(iy,ix)=length(ii);
    
%    plot(dp(:,1),dp(:,2),'k.')
%     hold on
%     plot(dp(ii,1),dp(ii,2),'ro')
%     hold off
%     axis image
%     pause(.1)
  end
  end
    
  
