% semivar_synth : synthethic semivariogram
%
% [sv,d]=semivar_synth(V,d,gstat);
%    V : Variogram model
%    d : seperation (array or matrix)
%    gstat : [0] use SGeMS semivariogram definitions (default)
%    gstat : [1] use GSTAT semivariogram definitions 
% 
%
% Call ex :  
%    [sv,d]=semivar_synth('0.1 Nug(0) + 1 Gau(1.5)',[0:.1:6]);plot(d,sv)
%    [sv,d]=semivar_synth('0.1 Nug(0) + 1 Gau(1.5)',[0:.1:6]);plot(d,sv)
% or : 
%    V(1).par1=1;V(1).par2=1.5;V(1).type='Gau';
%    V(2).par1=0.1;V(2).par2=0;V(2).type='Nug';
%    [sv,d]=semivar_synth(V,[0:.1:6]);plot(d,sv)
%
% The Matern semivariogram requires an extra argument
%     d=0:.1:6;
%     [sv1]=semivar_synth('1 Mat(1,.5)',d);
%     [sv2]=semivar_synth('1 Mat(1,1)',d);
%     [sv3]=semivar_synth('1 Mat(1,2)',d);
%     plot(d,[sv1;sv2;sv3])
%
%
function [sv,d]=semivar_synth(V,d,gstat,nugtype);
  
  if nargin<3
    gstat=0;
    % GET FORMAT FROM ENV VARIABLE IF IOT EXISTS
    if strcmp(lower(getenv('SEMIVAR_DEF')),lower('GSTAT'));
        gstat=1;
    end
    if strcmp(lower(getenv('SEMIVAR_DEF')),lower('SGeMS'));
        gstat=0;
    end
    
    
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
      sgamma=semivariance(d,sill,range,type);
    else
      [sgamma]=synthetic_variogram(V(iv),d,gstat);
    end
    sv=sv+sgamma;
  end

  sv(d==0)=0;
  
  %%% BUG FIND OUT WHY THE FOLLOWING LINE IS NEEED FOR HONORING HARD DATA
  %%% WITHOUT THESE LINES IT SEEMS THE NUGGET IS FILTERED!
  % Make sure sv(0)=0;
  if nugtype==1;
    sv(find(d<1e-9))=0;
  end
function [sgamma,h]=synthetic_variogram(V,h,gstat)

  type=V.type;
  v1=V.par1;
  v2=V.par2(1);
  nu=V.par2(end);
  sgamma=h.*0;
  s1=find(h<v2);
  s2=find(h>=v2);
  try
      nu=V.nu;
  catch
      nu=0.5;
  end
  
  if strmatch(lower(type),'nug')
    mgstat_verbose('Nug',12);
    sgamma=h.*0+v1;
    sgamma(find(h==0))=0;
  elseif strmatch(lower(type),'inug')
    mgstat_verbose('iNug',-12);
    sgamma=h.*0+v1;    
    %% SEE GSTAT MANUAL FOR TYPES....
  elseif strmatch(lower(type),'sph')
    mgstat_verbose('Sph',12);
    sgamma(s1)=v1.*(1.5*abs(h(s1))/(v2) - .5* (h(s1)./v2).^3);
    sgamma(s2)=v1;
  elseif strmatch(lower(type),'gau')
    mgstat_verbose('Gau',12);
    if gstat==0
      sgamma=v1.*(1-exp(-3*h.^2/v2.^2)); % GSLIB2/Goovaerts
    else
      sgamma=v1.*(1-exp(-h.^2/v2.^2)); % GSTAT
    end
  elseif strmatch(lower(type),'lin')
    mgstat_verbose('Lin',12);
    if v2==0,
      sgamma=v1.*h;
    else
      sgamma(s1)=h(s1)./v2;
      sgamma(s2)=1;
      sgamma=sgamma.*v1;
    end
  elseif strmatch(lower(type),'log')
    mgstat_verbose(type,12);
    sgamma=log(h+v2);
  elseif strmatch(lower(type),'pow')
    mgstat_verbose(type,12);
    sgamma=h.^v2;
  elseif strmatch(lower(type),'exp')
    mgstat_verbose(type,12);
    if gstat==0
      sgamma=v1.*(1-exp(-3*h./v2)); % GSLIB2/Goovaerts
    else
      sgamma=v1.*(1-exp(-h./v2)); % GSTAT
    end
  elseif strmatch(lower(type),'bal')
        % BALGOVIND, Daley, Atmospheric Data Analysis, (4.3.20), page 117
        sgamma = v1.*(1-(1+abs(h)./v2).*exp(-1.*(abs(h)./v2)));
  elseif strmatch(lower(type),'thi')
        % THIBEAUX, Daley, Atmospheric Data Analysis, (4.3.18), page 117
        c=nu;
        sgamma = (cos(c*h) + sin(c*h)./(v2.*c)).*exp(-1.*h./v2);
        sgamma= v1.*(1-sgamma);
  elseif strmatch(type,'Mat')
        %%
        %r=0:1:10;        v2=2;
        %nu=1.1;
        r=(h./v2);
        F1=2^(1-nu)/gamma(nu);
        F2=r.^(nu);
        F3=besselk(nu,r);
        
        
        sgamma = F1.*F2.*F3;
        sgamma= v1.*(1-sgamma);
        
  else      
    mgstat_verbose(sprintf('%s : ''%s'' type is not recognized',mfilename,type),-1);
  end
  
