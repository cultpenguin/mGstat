function caxis_squeeze(fac);




if nargin==0
    fac=-.1;
end


cax=caxis;
dcax=cax(2)-cax(1);
cax2=[cax(1)+fac*dcax cax(2)-fac*dcax];
caxis(cax2)