
x=linspace(0,80,161);
z=linspace(0,40,81);

nx=length(x);
nz=length(z);

vel=zeros(nz,nx)+4000;
vel(10:12,30:40)=300;

sx=[10:10:40];
sz=sx.*0+10;

S=[sx(:),sz(:)];

t=fast_fd_2d(x,z,vel,S);

contourf(x,z,t,[0:2:100]);axis image;colorbar