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

  
function ppp(lx,ly,Fsize,x1,y1,ax),
  
  
 if nargin==0,
   help ppp
   return
 end


 if nargin<3,
   Fsize=12;
 end
 
 if nargin<4;
     PS=get(gcf,'PaperSize');
     x1=(PS(1)-lx)/2;
     %x1=0;
 end
 if nargin<5;
     PS=get(gcf,'PaperSize');
     y1=(PS(2)-ly)/2;
     %y1=0;
 end

 if nargin<6
     ax=gca;
 end
 
 for cax=ax
     set(cax,'FontSize',Fsize)
     set(cax,'units','Centimeters')
     set(cax,'Position',[x1 y1 lx ly])
 end
