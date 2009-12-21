% file=ppp.m : Creates a lx,ly cm plot
%
% call function ppp(lx,ly,Fsize,x1,y1),
% 
% (lx,ly) : WIDTH and HEIGHT of plot in cm
% Fsize   : Font Size
% (x1,y1) : Lower left corner of plot (relative to lower left corner of paper)
%
%
% (C) Thomas Mejer Hansen, 1997-2001, tmh@gfy.ku.dk
%

  
function ppp(lx,ly,Fsize,x1,y1),
  
  
 if nargin==0,
   help ppp
   return
 end


 if nargin==2,
   Fsize=12;
   x1=2;y1=2;
 end
 if nargin==3,
   x1=2;y1=2;
 end
  

 set(gca,'units','Centimeters')
 set(gca,'Position',[x1 y1 lx ly])
 
