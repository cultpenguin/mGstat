function [vs,hs,ss,supar,mov]=sufdmod2(v,supar);

    supar.f_out='movie.su';
    supar.v_in='vel.out';
    su_write_model(v,supar.v_in);
    
    if nargin<2
        supar.null=0;
    end
    
    if ~isfield(supar,'nz'), supar.nz=100; end
    if ~isfield(supar,'nx'), supar.nx=100; end
    if ~isfield(supar,'dz'), supar.dz=5; end
    if ~isfield(supar,'dx'), supar.dx=5; end
    if ~isfield(supar,'fz'), supar.fz=0.0; end
    if ~isfield(supar,'fx'), supar.fx=0.0; end
    
    if ~isfield(supar,'xs'), supar.xs=250; end
    if ~isfield(supar,'zs'), supar.zs=250; end
    %if ~isfield(supar,'hsz'), supar.hsz=250; end
    %if ~isfield(supar,'vsx'), supar.vsx=250; end
    
    supar.verbose=0;
    
    supar.vsfile='vseis.out' ;
    supar.ssfile='sseis.out' ;
    supar.hsfile='hseis.out';
    if ~isfield(supar,'tmax'), supar.tmax=.5 ; end

    % MOVIE SNAP SHOTS FOR EVERY mt
    supar.mt=1000;
    if (supar.mt<20)
        disp(sprintf('%s : Writing out many snapshots, mt=%d',mfilename,supar.mt));
    end
    supar.abs=[1 1 1 1] ;
    
    supar.pml=0 ;

    supar.pml_thick=4;
        
    cmd=sprintf('sufdmod2 <vel.out nz=$n1 dz=$d1 nx=$n2 dx=$d2 verbose=1 xs=$xs zs=$zs hsz=$hsz vsx=$vsx hsfile=$hsfile sfile=$vsfile ssfile=$ssfile verbose=$verbose tmax=$tmax abs=1,1,1,1 mt=$mt pml=$pml pml_thick=$pml_thick > out.su');

    if (isunix==1)
        cmd=sprintf('sufdmod2 < %s',supar.v_in);    
    else
        cmd=sprintf('sufdmod2.exe < %s',supar.v_in);    
    end
    cmd=sprintf('%s nz=%d dz=%5.3f nx=%d dx=%5.3f verbose=%d',cmd,supar.nz,supar.dz,supar.nx,supar.dx,supar.verbose);    
    cmd=sprintf('%s xs=%d zs=%d hsz=%d vsx=%d',cmd,supar.xs,supar.zs,supar.hsz,supar.vsx);    

    cmd=sprintf('%s hsfile=%s vsfile=%s ssfile=%s',cmd,supar.hsfile,supar.vsfile,supar.ssfile);    
    txt_tmax=space2char(sprintf('tmax=%8.4f',supar.tmax),'0');
    cmd=sprintf('%s %s abs=%d,%d,%d,%d',cmd,txt_tmax,supar.abs(1),supar.abs(2),supar.abs(3),supar.abs(4));    
    if isfield(supar,'mt'),  cmd=sprintf('%s mt=%d',cmd,supar.mt); end
    if isfield(supar,'fmax'),  cmd=sprintf('%s fmax=%3.2g',cmd,supar.fmax); end
    if isfield(supar,'dt'),  cmd=sprintf('%s dt=%3.2g',cmd,supar.dt);end
    cmd=sprintf('%s pml=%d pml_thick=%d',cmd,supar.pml,supar.pml_thick);    
    cmd=sprintf('%s > %s',cmd,supar.f_out);    

       
    % disp(cmd);
    
    unix(cmd);
    
    if nargout>0, vs=ReadSu(supar.vsfile); end
    if nargout>1, hs=ReadSu(supar.hsfile); end
    if nargout>2, ss=ReadSu(supar.ssfile); end
    if nargout>4
        mov=ReadSu(supar.f_out,'endian','b');
    end
    

    