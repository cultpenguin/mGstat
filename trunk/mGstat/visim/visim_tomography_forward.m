% visim_tomography_forward(V,S,R,t,t_err,vref,options)
function [V,t,t_err]=visim_tomography_forward(V,S,R,t,t_err,vref,options);
	
	if isfield(options,'linear_kernel')
 		v0=vref.*0+V.gmean;
	else
		v0=vref;	
	end
	

	v0=vref.*0+V.gmean;

	[V,G,Gr,rl]=visim_setup_tomo_kernel(V,S,R,v0,t,t_err,options.name,options);
	G=visim_to_G(V);
	t=rl'./(Glin*vref(:));
	[V]=visim_setup_tomo_kernel(V,S,R,v0,t,t_err,options.name,options);
