% semivar_synth : synthethic semivariogram
%
% Call ex :  
%    [sv,d]=semivar_synth('0.1 Nug(0) + 1 Gau(1.5)',[0:.1:6]);plot(d,sv)
% or : 
%    V(1).par1=1;V(1).par2=1.5;V(1).type='Gau';
%    V(2).par1=0.1;V(2).par2=0;V(2).type='Nug';
%    [sv,d]=semivar_synth(V,[0:.1:6]);plot(d,sv)
%
function [sv,d]=semivar_synth(V,d,gstat,nugtype);
  if nargin<3
    gstat=1;
  end
  if nargin<4
    nugtype=1;
  end
  if nargin==0,
    V='5 Nug(0) + 1 Sph(5)'
    d=[0:.1:20];
  end
  if nargin==1
    d=[0:.1:20];
  end
  if ischar(V)
    V=deformat_variogram(V);
  end

  sv=zeros(size(d));
  for iv=1:length(V),
    if exist('semivariance')==3
      type=V(iv).itype;
      sill=V(iv).par1;    
      range=V(iv).par2;
      gamma=semivariance(d,sill,range,type);
    else
      [gamma]=synthetic_variogram(V(iv),d,gstat);
    end
    sv=sv+gamma;
  end

  sv(find(d==0))=0;
  
  %%% BUG FIND OUT WHY THE FOLLOWING LINE IS NEEED FOR HONORING HARD DATA
  %%% WITHOUT THESE LINES IT SEEMS THE NUGGET IS FILTERED!
  % Make sure sv(0)=0;
  if nugtype==1;
    sv(find(d<1e-9))=0;
  end
function [gamma,h]=synthetic_variogram(V,h,gstat)

  type=V.type;
  v1=V.par1;
  v2=V.par2;
  gamma=h.*0;
  s1=find(h<v2);
  s2=find(h>=v2);      
  if strmatch(type,'Nug')
    mgstat_verbose('Nug',12);
    gamma=h.*0+v1;
    gamma(find(h==0))=0;
  elseif strmatch(type,'iNug')
    mgstat_verbose('iNug',-12);
    gamma=h.*0+v1;    
    %% SEE GSTAT MANUAL FOR TYPES....
  elseif strmatch(type,'Sph')
    mgstat_verbose('Sph',12);
    gamma(s1)=v1.*(1.5*abs(h(s1))/(v2) - .5* (h(s1)./v2).^3);
    gamma(s2)=v1;
  elseif strmatch(type,'Gau')
    mgstat_verbose('Gau',12);
    if gstat==0
      gamma=v1.*(1-exp(-3*h.^2/v2.^2)); % GSLIB2/Goovaerts
    else
      gamma=v1.*(1-exp(-h.^2/v2.^2)); % GSTAT
    end
  elseif strmatch(type,'Lin')
    mgstat_verbose('Lin',12);
    if v2==0,
      gamma=v1.*h;
    else
      gamma(s1)=h(s1)./v2;
      gamma(s2)=1;
      gamma=gamma.*v1;
    end
  elseif strmatch(type,'Log')
    mgstat_verbose(type,12);
    gamma=log(h+v2);
  elseif strmatch(type,'Pow')
    mgstat_verbose(type,12);
    gamma=h.^v2;
  elseif strmatch(type,'Exp')
    mgstat_verbose(type,12);
    if gstat==0
      gamma=v1.*(1-exp(-3*h./v2)); % GSLIB2/Goovaerts
    else
      gamma=v1.*(1-exp(-h./v2)); % GSTAT
    end
  else      
    mgstat_verbose(sprintf('%s : ''%s'' type is not recognized',mfilename,type),-1);
  end
  
