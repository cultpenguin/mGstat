      real function getz(pval,nt,vr,cdf,zmin,zmax,ltail,ltpar,
     +     utail,utpar)
c-----------------------------------------------------------------------
c     
c     
c     
c     INPUT VARIABLES:
c     
c   pval             probability value to use
c   nt               number of values in the back transform tbale
c   vr(nt)           original data values that were transformed
c   cdf(nt)          the corresponding transformed values
c   zmin,zmax        limits possibly used for linear or power model
c   ltail            option to handle values less than cdf(1)
c   ltpar            parameter required for option ltail
c   utail            option to handle values greater than cdf(nt)
c   utpar            parameter required for option utail
c
c
c
c-----------------------------------------------------------------------
      parameter(EPSLON=1.0e-20)
      dimension vr(nt),cdf(nt)
      real      ltpar,utpar,lambda
      integer   ltail,utail
c
c Value in the lower tail?    1=linear, 2=power, (3 and 4 are invalid):
c 
      if(pval.le.cdf(1)) then
                  getz = vr(1)
            if(ltail.eq.1) then
                  getz = powint(0.0,cdf(1),zmin,vr(1),pval,1.0)  
            else if(ltail.eq.2) then
                  cpow = 1.0 / ltpar
                  getz = powint(0.0,cdf(1),zmin,vr(1),pval,cpow)
            endif
c
c Value in the upper tail?     1=linear, 2=power, 4=hyperbolic:
c
      else if(pval.ge.cdf(nt)) then
                  cdfhi  = cdf(nt)
                  getz   = vr(nt)
c                WRITE(*,*) 'nt=', nt, 'cdfhi=', cdfhi, 'vr(nt)=', vr(nt)
            if(utail.eq.1) then
                  getz   = powint(cdfhi,1.0,vr(nt),zmax,pval,1.0)
            else if(utail.eq.2) then
                  cpow   = 1.0 / utpar
                  getz   = powint(cdfhi,1.0,vr(nt),zmax,pval,cpow)
            else if(utail.eq.4) then
                  lambda = (vr(nt)**utpar)*(1.0-cdf(nt))
c                  write(*,*) 'lambda=', lambda
c                  write(*,*) '(lambda/(1.0-pval))=', lambda/(1.0-pval)
c                  write(*,*) '(lambda/(1.0-pval))**(1.0/utpar)=',
c     +                        (lambda/(1.0-pval))**(1.0/utpar)
                  getz   =(lambda/(1.0-pval))**(1.0/utpar)
c                  write(*,*) 'getz=', getz

            endif
      else
c
c Value within the transformation table:
c
            call locate(cdf,nt,1,nt,pval,j)
            j    = max(min((nt-1),j),1)
            getz = powint(cdf(j),cdf(j+1),vr(j),vr(j+1),pval,1.0)
      endif
      if(getz.lt.zmin) getz = zmin
      if(getz.gt.zmax) getz = zmax
      return      
      end   
                  




