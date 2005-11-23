C     
C     edist.f
C
      
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C-----------------------------------------------------------------------
C     (pointer) Replace integer by integer*8 on the DEC Alpha
C     64-bit platform
C
      implicit none
      integer plhs(*), prhs(*)
      integer mxGetPr, mxCreateDoubleMatrix
      integer arr1_pr, arr2_pr, dist_pr
C-----------------------------------------------------------------------
C

      integer nlhs, nrhs
      integer mxGetM, mxGetN, mxIsNumeric
      integer m, n, size, i
      real*8  arr1(100000), arr2(100000), dist(100000)

C     Check for proper number of arguments. 
      if(nrhs .ne. 2) then
         call mexErrMsgTxt('2 input required.')
      elseif(nlhs .ne. 1) then
C         call mexErrMsgTxt('One output required.')
      endif

C     Get the size of the input array.
      m = mxGetM(prhs(1))
      n = mxGetN(prhs(1))
      size = m*n

C     Column * row should be smaller than 10000
      if(size.gt.100000) then
         call mexErrMsgTxt('EDIST Row * column must be <= 10000.')
      endif


C     Check to insure the input is a number.
      if(mxIsNumeric(prhs(1)) .eq. 0) then
         call mexErrMsgTxt('Input must be a number.')
      endif

C     Create matrix for the return argument.
      plhs(1) = mxCreateDoubleMatrix(m,1,0)
      dist_pr = mxGetPr(plhs(1))

      arr1_pr = mxGetPr(prhs(1))
      arr2_pr = mxGetPr(prhs(2))

      call mxCopyPtrToReal8(arr1_pr,arr1,size)
      call mxCopyPtrToReal8(arr2_pr,arr2,size)

C     Call the computational subroutine.
      call edist(arr1,arr2,dist,m,n)

C     Load the data into y_pr, which is the output to MATLAB
      call mxCopyReal8ToPtr(dist,dist_pr,m)     

      return
      end

      subroutine edist(arr1,arr2,dist,m,n)
      implicit none
      integer m, n, size, i, j
      real*8  arr1(m,n), arr2(m,n), dist(m)
      
      do i=1,m
         dist(m)=0
         do j=1,n
            dist(m) = dist(m) + (arr1(i,j)-arr2(i,j))**(2)
         enddo
c         dist(m)=sqrt(dist(m))
      enddo
      return
      


      end



