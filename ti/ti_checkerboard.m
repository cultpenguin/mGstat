% ti_checkerboard: create a 1D-3D checkerboard image
%
% Call:
%   C = ti_checkerboard(n,w)   
%   n: numver of pixels per dimension
%   w: width of each checker board (def, w=1);
%
% Example
%   C = ti_checkboard(80); % 1D with checkboard size 1
%   C = ti_checkboard([80 80 80],8) % 3D with checkboard size w=8
%   C = ti_checkboard([80 80],8) % 2D 
% 
% Using:  http://matlabtricks.com/post-31/three-ways-to-generate-a-checkerboard-matrix
function C = ti_checkerboard(n,w,mod_val);

if nargin<1
    n=80;
end

if length(n)==1;
    n=[n 1 1];
elseif length(n)==2;
    n(3)=1;
end
if nargin<2
    w=1;
end
if nargin<3
    mod_val=2;
end

if nargin==0
    n=[80 80 80];
    w=8;
end


%%
n_use = ceil(n./w);


%% 
ni=n_use(1);
nj=n_use(2);
nk=n_use(3);

C = zeros(ni,nj,nk);
for k = 1:nk
    for j = 1:nj
        for i = 1:ni
            C(i,j,k) = ceil(mod( (i-j-k) ,mod_val));
        end
    end
end

%% interpolate
if w~=1
    %ii=[1:1:ni].*w;
    %jj=[1:1:nj].*w;
    %kk=[1:1:nk].*w;
    
    ii=([0:1:(ni-1)]).*w+w/2+.5; 
    jj=([0:1:(nj-1)]).*w+w/2+.5;
    kk=([0:1:(nk-1)]).*w+w/2+.5;
    
    [ii2,jj2,kk2]=meshgrid(ii,jj,kk);
    
    
    [ii3,jj3,kk3]=meshgrid(1:n(1),1:n(2),1:n(3));
    
    %figure(1);
    %scatter3(ii2(:),jj2(:),kk2(:),40,C(:),'filled')
    %hold on;
    %plot3(ii3(:),jj3(:),kk3(:),'.')
    %hold off
    
    
    Cg = griddata(ii2(:),jj2(:),kk2(:),C(:),ii3,jj3,kk3,'nearest');
    C=Cg;
    
    %figure(2);
    %scatter3(ii3(:),jj3(:),kk3(:),80,C(:),'filled')
    
end
    

