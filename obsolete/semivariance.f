C     
C     timestwo.f
C
C     multiple the input argument by 2
      
C     This is a MEX-file for MATLAB.
C     Copyright 1984-2000 The MathWorks, Inc. 
C     $Revision: 1.2 $
      
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha
C     64-bit platform
C
      implicit none
      integer plhs(*), prhs(*)
      integer mxGetPr, mxCreateDoubleMatrix
      integer h_pr, gamma_pr, range_pr, type_pr, sill_pr
C-----------------------------------------------------------------------
C

      integer nlhs, nrhs
      integer mxGetM, mxGetN, mxIsNumeric
      integer m, n, size, i
      real*8  h(1000000), gamma(1000000), range, type, sill

C     Check for proper number of arguments. 
      if(nrhs .ne. 4) then
         call mexErrMsgTxt('Four input required.')
      elseif(nlhs .ne. 1) then
C         call mexErrMsgTxt('One output required.')
      endif

C     Get the size of the input array.
      m = mxGetM(prhs(1))
      n = mxGetN(prhs(1))
      size = m*n

      
C     Column * row should be smaller than 1000000
      if(size.gt.1000000) then
         call mexErrMsgTxt('Row * column must be <= 1000000.')
      endif



C     Check to insure the input is a number.
      if(mxIsNumeric(prhs(1)) .eq. 0) then
         call mexErrMsgTxt('Input must be a number.')
      endif

C     Create matrix for the return argument.
      plhs(1) = mxCreateDoubleMatrix(m,n,0)
      h_pr = mxGetPr(prhs(1))
      sill_pr = mxGetPr(prhs(2))
      range_pr = mxGetPr(prhs(3))
      type_pr = mxGetPr(prhs(4))

      gamma_pr = mxGetPr(plhs(1))

      call mxCopyPtrToReal8(h_pr,h,size)
      call mxCopyPtrToReal8(range_pr,range,1)
      call mxCopyPtrToReal8(type_pr,type,1)
      call mxCopyPtrToReal8(sill_pr,sill,1)


C     Call the computational subroutine.
      call semivar(gamma, h, sill, range, type, m, n)

C     Load the data into y_pr, which is the output to MATLAB
      call mxCopyReal8ToPtr(gamma,gamma_pr,size)     

      return
      end

      subroutine semivar(gamma, h, sill, range, type, m, n)
      implicit none
      real*8 range, type, sill
      real*8 hr
      integer m, n, size
      real*8 h(m,n), gamma(m,n)
      integer i,j
      
      do i=1,m
      do j=1,n

C      
c     NUGGET
      if(type.eq.0) then
         if (h(i,j).eq.0) then
           gamma(i,j) = 0
        else
           gamma(i,j) = sill
        end if

c     SPHERICAL
      else if(type.eq.1) then
         if (h(i,j).gt.range) then
            gamma(i,j) = sill
         else
            hr=h(i,j)/range
            gamma(i,j) = sill * hr*(1.5 - 0.5*hr*hr)
         end if
      else  if(type.eq.2) then
c     SPHERICAL
         gamma(i,j) = sill*(1-exp(-3.0*h(i,j)/range))
      else if(type.eq.3) then
c     GAUSSIAN
         gamma(i,j) = sill*(1-exp(-(9*h(i,j)*h(i,j))/(range*range)))
      else if(type.eq.4) then
c     POWER
         gamma(i,j) = sill*h(i,j)**(2)
      else if(type.eq.5) then
c     HOLE
         gamma(i,j) = sill*(1-cos(3.144*h(i,j)/range ))
      else if (type.eq.14) then
         gamma(i,j) = sill
        
      else
         gamma(i,j)=0   
         
      end if
      
      enddo
      enddo

      return



      end



