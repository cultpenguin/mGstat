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
 
 return
 
 set(cb,'units','Centimeters')
 set(cb,'Position',[w+x1+w./20 y1 w./10 h])
 
 set(gca,'FontSize',FS);
 set(cb,'FontSize',FS);
 
 
 fig_num=gcf;
 %set(0,'DefaultFigurePaperType','a4letter')

 set(fig_num,'paperunits','centim');
 fig_pap_pos = get(fig_num,'paperposition');
 fx0 = fig_pap_pos(1);
 fy0 = fig_pap_pos(2);
 fx1 = fig_pap_pos(3);
 fy1 = fig_pap_pos(4);
 ax_pos = [x1/fx1,y1/fy1,lx/fx1,ly/fy1];

 set(gca,'position',ax_pos,'FontName','Helvetica','FontSize',Fsize)

