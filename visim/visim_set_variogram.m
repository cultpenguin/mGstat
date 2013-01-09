% visim_set_variogram : Set variogram model (gslib style) for VISIM
%
% Call : 
%      V=visim_set_variogram(V,Va)
%
% Example : 
%   V=visim_init;
%   V=visim_set_variogram(V,'1 Sph(30)');
%
%
function [V,Va]=visim_set_variogram(V,Va);
  
if isstr(Va);
    Va=deformat_variogram(Va);
end

V.Va.nst=length(Va);

iv=0;
for i=1:length(Va);
    
    if Va(i).itype==0
        % nugget
        V.Va.nugget=Va(i).par1;
        V.Va.nst=V.Va.nst-1;
    else
        iv=iv+1;
        V.Va.cc(iv)=Va(i).par1;
        V.Va.it(iv)=Va(i).itype;

        if length(Va(i).par2)==1;
            V.Va.a_hmax(iv)=Va(i).par2;
            V.Va.a_hmin(iv)=Va(i).par2;
            V.Va.a_vert(iv)=Va(i).par2;
            V.Va.ang1=0;
            V.Va.ang2=0;
            V.Va.ang3=0;
        elseif length(Va(i).par2)==3;
            V.Va.a_hmax(iv)=Va(i).par2(1)
            V.Va.a_hmin(iv)=Va(i).par2(1)*Va(i).par2(3);
            V.Va.a_vert(iv)=0;
            V.Va.ang1=Va(i).par2(2);
            V.Va.ang2=0;
            V.Va.ang3=0;
        elseif length(Va(i).par2)==6;
            V.Va.a_hmax(iv)=Va(i).par2(1)
            V.Va.a_hmin(iv)=Va(i).par2(1)*Va(i).par2(5);
            V.Va.a_vert(iv)=Va(i).par2(1)*Va(i).par2(6);
            V.Va.ang1=Va(i).par2(2);
            V.Va.ang2=Va(i).par2(3);
            V.Va.ang3=Va(i).par2(4);
        end
            
        
    end
    V.gvar=sum([Va.par1]);
end


