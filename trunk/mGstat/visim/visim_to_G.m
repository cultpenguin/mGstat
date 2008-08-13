% visim_to_G : Setup linear forward matrix (only 2D)
%
% CALL : 
%  [G,d_obs,d_var,Cd,Cm]=visim_to_G(V);
%
function [G,d_obs,d_var,Cd,Cm,m0]=visim_to_G(V);
  
  if isstruct(V)~=1
    V=read_visim(V);
  end
  
  nxyz=V.nx*V.ny*V.nz;

  try
      ndata=size(V.fconddata.data,1);
  catch
      ndata=0;
  end
  
  try
      nvol=size(V.fvolsum.data,1);
  catch
      nvol=0;
  end
  mgstat_verbose(sprintf('%s : %s, ndata=%d novl=%d',mfilename,V.parfile,ndata,nvol),-1);
  
  m0=ones(nxyz,1).*V.gmean;
  
  if nvol>0
      Gvol=zeros(nvol,nxyz);
      for ivol=1:nvol;
          if (((ivol/50)==round(ivol/50))|(ivol==nvol))
              progress_txt(ivol,nvol,'Setting up G')
          end
          idata=find(V.fvolgeom.data(:,4)==ivol);
          POS=V.fvolgeom.data(idata,[1 2 3]);
          SENS=V.fvolgeom.data(idata,[5]);
          
          ix=(POS(:,1)-V.xmn+V.xsiz)/V.xsiz;
          iy=(POS(:,2)-V.ymn+V.ysiz)/V.ysiz;
          iz=(POS(:,3)-V.zmn+V.zsiz)/V.zsiz;
          
          idata=find(V.fvolgeom.data(:,4)==ivol);
          [iix,iiy]=pos2index(POS(:,1),POS(:,2),V.x,V.y);
          ind=sub2ind([V.nx V.ny],iix,iiy);
          
          Gvol(ivol,ind)=SENS;
          
          d_volobs(ivol,:)=V.fvolsum.data(ivol,[3]);
          d_volobs_var(ivol,:)=V.fvolsum.data(ivol,[4]);
      end
  else
      Gvol=[];
      d_volobs=[];
      d_volobs_var=[];
      
  end
  

  if ndata>0
      Gdata=zeros(ndata,nxyz);
      for idata=1:ndata;
          if (((idata/50)==round(idata/50))|(idata==ndata))
              progress_txt(idata,ndata,'Setting up G')
          end

          POS=V.fconddata.data(idata,V.cols(1:3));
          SENS=1;
          
          
          ix=(POS(:,1)-V.xmn+V.xsiz)/V.xsiz;
          iy=(POS(:,2)-V.ymn+V.ysiz)/V.ysiz;
          iz=(POS(:,3)-V.zmn+V.zsiz)/V.zsiz;
          
          %idata=find(V.fdatageom.data(:,4)==idata);
          [iix,iiy]=pos2index(POS(:,1),POS(:,2),V.x,V.y);
          ind=sub2ind([V.nx V.ny],iix,iiy);
          
          Gdata(idata,ind)=SENS;
          
          d_dataobs(idata,:)=V.fconddata.data(idata,V.cols(4));
          d_dataobs_var(idata,:)=0;
      end
      
  else
      Gdata=[];
      d_dataobs=[];
      d_dataobs_var=[];
      
  end

  G=[Gvol;Gdata];
  d_obs=[d_volobs;d_dataobs]; 
  d_var=[d_volobs_var;d_dataobs_var];

  
  if nargout<4
    return
  end
  
  % SETTING UP Cd
  
  % CHECK IF DATA COVARIANCE EXISTS
  if isfield(V,'fout')
      f_Cd=['datacov_',V.fout.fname];
  else
      [p,f_Cd]=fileparts(V.parfile);
      f_Cd=['datacov_',f_Cd,'.out'];        
  end
  try
      try
          Cd=read_eas(f_Cd);
          try
              Cd=reshape(Cd,nvol,nvol);
          catch
              disp(sprintf('%s : Size of %s is not consistent data',mfilename,f_Cd(1).name))
          end
      catch
          disp(sprintf('%s : Could not read %s ',mfilename,f_Cd))
          n=length(d_var);
          try
              Cd_diag=V.fvolsum.data(:,4);
          catch
              Cd_diag=eye(n).*0;
          end
          Cd=eye(n);
          for i=1:n
              Cd(i,i)=Cd_diag(i);
          end
      end
  catch
      Cd=[];
      mgstat_verbose('Failed to setup Cd');
  end

  if nargout>4
      % Setup Covariance matrix
      [yy,xx]=meshgrid(V.y,V.x);
      nxyz=V.nx*V.ny*V.nz;
      %Cm=zeros(nxyz,nxyz);
      
      
      Va=deformat_variogram(visim_format_variogram(V));
      Cm=precal_cov([xx(:) yy(:)],[xx(:) yy(:)],Va);
  end
  
  