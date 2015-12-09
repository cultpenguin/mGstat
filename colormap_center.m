% colormap_center: centers a colormap on a specific value
%
%
%
function cmap_out=colormap_center(c_center_value,cmap,cax)

if nargin<2
    cmap=colormap(gca);
end

if nargin<3
    cax=caxis;
end

if nargin<1
    c_center_value=mean(cax);
end



% cmap 1
n=size(cmap,1);
cax_linear=linspace(cax(1),cax(2),n);
n1=ceil(n/2);
n2=n-n1;

% cmap 2

i_center=(c_center_value-cax(1))/diff(cax);
n_center=ceil(n*i_center);
cax_nonlinear_1=linspace(cax(1),c_center_value,n1);
cax_nonlinear_2=linspace(c_center_value,cax(2),1+n2);
cax_nonlinear=[cax_nonlinear_1, cax_nonlinear_2(2:end)];
%figure(2);plot(cax_nonlinear)

for i=1:3;
    cmap_out(:,i)=interp1(cax_linear, cmap(:,i), cax_nonlinear);
end
   
colormap(cmap_out);

    