% visim_tomograhy
%
% [V,Vlsq]=visim_tomography(V,S,R,t,t_err,m0,options);
%
%
% if ~isfield(options,'linearize');	options.linearize=0;end;
% if ~isfield(options,'lsq');	options.lsq=0;end;
% if ~isfield(options,'nocal_kernel');	
%
function [V,Vlsq]=visim_tomography(V,S,R,t,t_err,m0,options);

Vlsq='';

options.dummy='';
if nargin<6
  m0=V.gmean.*ones(V.nx,V.ny);
end;

if isempty(m0)
  m0=V.gmean.*ones(V.nx,V.ny);
end

if ~isfield(options,'name'); options.name='generic'; end;

if ~isfield(options,'linearize');	options.linearize=0;end;
if ~isfield(options,'lsq');	options.lsq=0;end;
if ~isfield(options,'nocal_kernel');	
  options.nocal_kernel=0; % CALCULATE KERNEL FROM REFERENCE MODEL !
  % options.nocal_kernel=1; % DO NOT CALCULATE KERNEL FROM REFERENCE MODEL !
end;


if ~isfield(options,'ktype');
   options.ktype=1; % HIGH FREQUENCY
   % options.ktype=2; % FINITE FREQUENCY
end;

if ~isfield(options,'T');
	options.T=1; % PERIOD
end;

if ~isfield(options,'doPlot');
	options.doPlot=0;
end;


if ~isfield(options,'linearize');
	options.linearize=0;
end;


% CREATE INITIAL KERNEL FROM REFERENCE MODEL m0
if options.nocal_kernel==0
    options.ktype=options.type
  [V,G,Gray,rayl]=visim_setup_tomo_kernel(V,S,R,m0,t,t_err,options.name,options);
end

% SHOULD WE LINEARIZE THE PROBLEM ?
if options.linearize==1
	disp(sprintf('%s : linearizing %.par',mfilename,options.name));
  [V,Vlsq]=visim_tomography_linearize(V,S,R,t,t_err,m0,options);
	V.parfile=sprintf('%s.par',options.name);
end

if options.lsq==1
	disp(sprintf('%s : calculating exact least squares result (%s)',mfilename,options.name));
	nsim=V.nsim;
	densitypr=V.densitypr;
	V.nsim=0;
	V.densitypr=0;
	V=visim(V);
	V.nsim=nsim;
	V.densitypr=densitypr;
  return
end	

disp(sprintf('%s : Generating sample of the posterior PDF using : visim %s.par',mfilename,options.name));
V=visim(V);
