% visim_init : create a reference parameter file.
%
% Call without arguemtnt for a reference file for unconditional simulation
%
function V=visim_init(x,y,z,V);

    if nargin==0
        [p]=fileparts(which('visim.m'))        ;
        f=[p,filesep,'visim_default'];
        load([p,filesep,'visim_default']);
        return
    end
    
	if nargin<2
		y=[1];
	end	

	if nargin<3
		yz=[1];
	end	

  if nargin<4
		load visim_reference_init;
	  V.Va.a_hmax=(max(x)-min(x))/2;
	  V.Va.a_hmin=(max(y)-min(y))/2;
	  V.Va.a_vert=(max(z)-min(z))/2;
	end

	V.xmn=x(1);
  V.nx=length(x);
	if V.nx==1;
		V.xsiz=1;
	else
		V.xsiz=x(2)-x(1);
	end

	V.ymn=y(1);
  V.ny=length(y);
	if V.ny==1
	  V.ysiz=1;
  else	
		V.ysiz=y(2)-y(1);
  end	

	V.zmn=z(1);
  V.nz=length(z);
	if V.nz==1;
		V.zsiz=1;
	else
		V.zsiz=z(2)-z(1);
	end	
	
	
	
	
