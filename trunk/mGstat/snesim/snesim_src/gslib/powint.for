      real function powint(xlow,xhigh,ylow,yhigh,xval,pow)
c-----------------------------------------------------------------------
c
c Power interpolate the value of y between (xlow,ylow) and (xhigh,yhigh)
c                 for a value of x and a power pow.
c
c-----------------------------------------------------------------------
      parameter(EPSLON=1.0e-20)

      if((xhigh-xlow).lt.EPSLON) then
            powint = (yhigh+ylow)/2.0
      else
            powint = ylow + (yhigh-ylow)* 
     +               (((xval-xlow)/(xhigh-xlow))**pow)
      end if

      return
      end
