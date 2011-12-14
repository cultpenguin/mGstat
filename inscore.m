% inscore : normal score BACK transform
%
% CALL :
%   d=inscore(d_nscore,o_nscore)
%
% d_nscore : normal score values to be back transformed 
%            using the 'o_nscore' object, obtained using 
%            'nscore'
%
% See also nscore.m
%
function d_out=inscore(d_normal,o_nscore)
  if nargin<3
    style='nearest';%  - nearest neighbor interpolation
    %style='linear';%   - linear interpolation
    %style='spline';%   - piecewise cubic spline interpolation (SPLINE)
    %style='pchip';%    - shape-preserving piecewise cubic interpolation
    %style='cubic';%    - same as 'pchip'
    %style='v5cubic';%  - the cubic interpolation from MATLAB 5, which does not
  end
  
  
  % use only non NAN data
  id=find(~isnan(o_nscore.normscore));
  
  s_origdata=sort(o_nscore.d);
             
  % INTERPOLATE BETWEEN KNOWN DATA
  % 'help interp1' to see list of interpolation options.
  d_out=interp1(o_nscore.normscore(id),s_origdata(id),d_normal,style);
  
  doPlot=0;
  if doPlot==1;
     plot(o_nscore.normscore(id),s_origdata(id),'k-*',d_normal,d_out,'go')
  end 
  
  % THERE IS SOME TROUBLE AT THE TAILS, FOR SOME VERSION OF MATLAB ... -->
  ibad=find(isnan(d_out));
  if ~isempty(ibad);
    d_out(ibad)=interp1(o_nscore.normscore(id),s_origdata(id),d_normal(ibad),'nearest');
  end
  
