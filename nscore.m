% nscore : Normal score transform
%
% CALL :
%   [d_nscore,o_nscore]=nscore(d,w1,w2,dmin,dmax,DoPlot)
%   [d_nscore,o_nscore]=nscore(d,o_nscore);
%
%
% INPUT PARAMETERS :
% Required :
% d : array of data to transformed into normal scorres.
%
% Optional :
% w1,dmin : Extrapolation options for lower tail.
%           w1=1 -> linear interpolation
%           w1>1 -> Gradual power interpolation
% w2,dmax : Extrapolation options for lower tail.
%           w1=1 -> linear interpolation
%           w1<1 -> Gradual power interpolation
%
% See Goovaerts page 280-281 for details
%
% DoPlot : ==1 --> The choice of CCPDF to be used for normal score
%                  transformation is plotted
% OUTPUT PARAMETERS
%
% d_nscore : normal score transform of input data
% o_nscore : normal socre object containing information 
%            needed to perform normal score backtransform. 
%
%
% See also : inscore
%
function [normscore_org,o_nscore]=nscore(d,w1,w2,dmin,dmax,style,DoPlot)

%% FOWARD NORMAL SCORE
 if nargin==2,
     if isstruct(w1);
         o_nscore=w1;
         % TODO: ALLOW DIFFERENT TYPE OF INTERPOLATION
         if ~isfield(o_nscore,'style');
             o_nscore.style='nearest';
         end
         normscore_org=interp1(o_nscore.sd,o_nscore.normscore,d,o_nscore.style);
         return
         
     end
 end

 %% NORMAL SCORE TRANSFORM SETUP
 
         
 if nargin<7
   DoPlot=0;
 end

 if nargin<2, w1=1;end 
 if nargin<3, w2=1;end 
 if nargin<4, dmin=min(d(:));end 
 if nargin<5, dmax=max(d(:));end 
 if nargin<6, 
     style='nearest';%  - nearest neighbor interpolation
     style='linear';%   - linear interpolation
  end
 o_nscore.style=style;
d_in=d;  
  
  
d=d(:);
n=length(d);
%Calculte normal scores
id=[1:n]';
pk=id./n-.5/n;
%pk=id./n; used in VISIM 1.6, DSSIM mode, for better target hist reproduction

normscore=norminv(pk);

n=length(d);
id=[1:n]';

normscore=norminv(pk);
sd=sort(d);

s_sort=sortrows([d id]);
d_nscore=0.*d;
normscore_org(s_sort(:,2))=normscore;
normscore_org=normscore_org(:);



if DoPlot==1,
  sd_org=sort(d);
  pk_org=pk;

  subplot(2,2,1)
  hist(d_in)
  xlabel('X');title('orig data')
  ylabel('PDF')
 
  subplot(2,2,2)
  hist(normscore)
  xlabel('NS(X)');
  ylabel('CPDF')
  title('NORMAL SCORE PDF')

end

% lower tail
if exist('w1')
  if exist('dmin')==0, dmin=min(d)-1e-9;end

  if dmin>min(d)
    disp([mfilename,' dmin is selected larger than the minimum value of data'])
    disp(sprintf('dmin=%8.3g and min(d)=%8.3g',dmin,min(d)))
    disp([mfilename,' THIS IS BAD'])    
    dmin=min(d);
    disp(sprintf('NOW USING dmin=%8.3g',dmin))
  end
  if dmin==min(d)
    dmin=min(d)-1e-9;
  end
  d1=min(d); 
  if abs(min(d)-dmin)/abs(dmin)<1e-9
      nbin=0;
  else
      nbin=10;
  end
  
  pk1=min(pk);
  
  dlow=linspace(dmin,d1,nbin+1);
  dlow=dlow(1:nbin);
  pklow=pk1.*((dlow-dmin)./(d1-dmin)).^(w1);
  
  d=[dlow(:);d];
  pk=[pklow(:);pk];

end

% upper tail
if exist('w2')
  if dmax<max(d)
    disp([mfilename,' dmax is selected smaller than the maximum value of data'])
    disp(sprintf('dmax=%8.3g and max(d)=%8.3g',dmax,max(d)))
    disp([mfilename,' THIS IS BAD'])
    dmax=max(d);
    disp(sprintf('NOW USING dmax=%8.3g',dmax))
  end
  if dmax==max(d) 
    dmax=max(d)+1e-9;
  end
  
  if abs(max(d)-dmax)/dmax<1e-9
      nbin=0;
  else
      nbin=10;
  end
  
  dk=max(d);
  pkk=max(pk);
  dhigh=linspace(dk,dmax,nbin+1);
  dhigh=dhigh(2:(nbin+1));
  
  pkhigh=pkk + (1-pkk).*((dhigh-dk)./(dmax-dk)).^(w2);
  
  d=[d;dhigh(:)];
  pk=[pk;pkhigh(:)];
end


% CALCULATE NORMAL SCORE OF INPUT DATA
n=length(d);
id=[1:n]';

normscore=norminv(pk);
sd=sort(d);

s_sort=sortrows([d id]);
d_nscore=0.*d;
d_nscore(s_sort(:,2))=normscore;

doSmooth=0;
if doSmooth==1;
    % TODO
    keyboard
    
end


if DoPlot==1,

  subplot(2,2,[3,4])
  plot(sd,pk,'r-*','MarkerSize',8)
  hold on
  plot(sd_org,pk_org,'kd','MarkerSize',10)
  hold off
  xlabel('X');
  ylabel('CPDF')
  title('ORIG CDF')
  legend('ORG+Head+Tail','ORIGINAL','Location','NorthEast')

end


o_nscore.sd=sd;
o_nscore.pk=pk;
o_nscore.d=d;
o_nscore.normscore=normscore;
