function Cm=calc_Cm(ny,nx,cell,gvar,h_max,h_min,mode,ang)

% Call: Cm=calc_Cm(ny,nx,cell,gvar,h_max,h_min,mode,ang);
% Calculates a 2D model covariance matrix with correlations described by a
% spherical, exponential or Gaussian covariance function.
%
% * ny: is the number of cells in the y-direction
% * nx: is the number of cells in the x-direction
% * cell: is the physical size of the cells
% * gvar: is the global variance
% * h_max: is the correlation length of maximum continutiy
% * h_min: is the correlation length of minimum continutiy
% * mode: Covariance function: 1)Spherical, 2)Exponential, 3)Gaussian, 
%   4) Ricker wavelet. 
%   Notice: In mode 4 (Ricker wavelet) h_max=f0 is the central frequency of the
%   ricker wavelet and dt=h_min is the temporal sample interval. 
% * ang: is the angle between vertical and the direction of maximum
%   continutity. By default the direction of maximum continutity (h_max) is
%   set to the x-direction (ang=90).
%
% This function is based on Goovaerts (1997) section 4.2.2.
%
% Knud S. Cordua (2008)
%
% The direction of maximum continutiy (the major axis) forms an angle ang_max
% with the y coordinate axis (north-direction) measured clock-wise from the
% y axis. The direction of minimum continuity is perpendicular to the major
% axis and forms the angle ang_min = ang_max + 90 degrees with the y axis.
% The anisotropi factor is given as:
% gamma = a_min/a_max, where a_min (minor range) and a_max (major range) are
% the ranges in the direction of minimum and maximum continuity, respectively.
% The angel is measured anti-clock-wise when y is directed positive
% downwards.



if nargin<8,ang=90;end
if h_min>h_max
    disp('Warning:')
    disp('Choose h_min<=h_max because h_max is the direction of maximum continuity.')
    disp('Use the input "ang" to change the direction of maximum continutiy')
end

a_max=h_max;
a_min=h_min;

if mode <= 4
    ang=ang*(pi/180); % Transform angle into radians
end

gamma=a_min/a_max; % anistropy factor < 1 (=1 for isotropy)

% Geometry:
x=cell/2:cell:nx*cell-cell/2;
y=cell/2:cell:ny*cell-cell/2;
[X Y]=meshgrid(x,y);

if mode==1 % Spherical
    Cm=zeros(ny*nx,ny*nx);
    c=0;
    i=1;
    for j=1:ny;
        % Original coordinates:
        h_x=abs(X-x(i));
        h_y=abs(Y-y(j));

        % Transform into rotated coordinates:
        h_min=h_x*cos(ang)-h_y*sin(ang);
        h_max=h_x*sin(ang)+h_y*cos(ang);

        % Rescale the ellipse:
        h_min_rs=h_min;
        h_max_rs=gamma*h_max;
        dist=sqrt(h_min_rs.^2+h_max_rs.^2);
        
        dist(find(dist>a_min))=a_min;
        cvm=(1.5*(dist./a_min)-0.5*(dist./a_min).^3);

        c=c+1;
        cov=(1-cvm)*gvar;
        Cm_tmp(c,:)=cov(:);
    end
    for k=1:nx
        Cm(ny*(k-1)+1:k*ny,ny*(k-1)+1:end)=Cm_tmp(:,1:ny*nx-ny*(k-1));
    end

    Cm=Cm'-sqrt(Cm'.*Cm)+Cm;

elseif mode==2 % Exponential

    Cm=zeros(ny*nx,ny*nx);
    c=0;
    i=1;
    for j=1:ny;
        % Original coordinates:
        h_x=abs(X-x(i));
        h_y=abs(Y-y(j));

        % Transform into rotated coordinates:
        h_min=h_x*cos(ang)-h_y*sin(ang);
        h_max=h_x*sin(ang)+h_y*cos(ang);

        % Rescale the ellipse:
        h_min_rs=h_min;
        h_max_rs=gamma*h_max;
        dist=sqrt(h_min_rs.^2+h_max_rs.^2);

        cvm=1-exp(-3*dist./a_min);
        c=c+1;
        cov=(1-cvm)*gvar;
        Cm_tmp(c,:)=cov(:);
    end
    for k=1:nx
        Cm(ny*(k-1)+1:k*ny,ny*(k-1)+1:end)=Cm_tmp(:,1:ny*nx-ny*(k-1));
    end

    Cm=Cm'-sqrt(Cm'.*Cm)+Cm;

elseif mode==3 % Gaussian

    Cm=zeros(ny*nx,ny*nx);
    c=0;
    i=1;
    for j=1:ny;
        % Original coordinates:
        h_x=abs(X-x(i));
        h_y=abs(Y-y(j));

        % Transform into rotated coordinates:
        h_min=h_x*cos(ang)-h_y*sin(ang);
        h_max=h_x*sin(ang)+h_y*cos(ang);

        % Rescale the ellipse:
        h_min_rs=h_min;
        h_max_rs=gamma*h_max;
        dist=sqrt(h_min_rs.^2+h_max_rs.^2);

        cvm=1-exp(-3*dist.^2./a_min.^2);
        c=c+1;
        cov=(1-cvm)*gvar;
        Cm_tmp(c,:)=cov(:);
    end
    for k=1:nx
        Cm(ny*(k-1)+1:k*ny,ny*(k-1)+1:end)=Cm_tmp(:,1:ny*nx-ny*(k-1));
    end

    Cm=Cm'-sqrt(Cm'.*Cm)+Cm;

elseif mode==4 % Ricker
    
    f0=h_max;
    dt=h_min;
    
    % Allocate memory for the covarianc matrix
    Cm=zeros(ny*nx,ny*nx);
    
    c=0;
    i=1;
    for j=1:ny;
        % Original coordinates:
        h_x=abs(X-x(i));
        h_y=abs(Y-y(j));
        
        dist=sqrt(h_x.^2+h_y.^2);

        t0=0;
        time=dist*dt;

        cvm=(1-2*pi^2*f0^2*(time-t0).^2).*exp(-pi^2*f0^2*(time-t0).^2); 
        c=c+1;
        cov=cvm*gvar;
        Cm_tmp(c,:)=cov(:);
    end
    for k=1:nx
        Cm(ny*(k-1)+1:k*ny,ny*(k-1)+1:end)=Cm_tmp(:,1:ny*nx-ny*(k-1));
    end

    Cm=Cm'-sqrt(Cm'.*Cm)+Cm;
    
elseif mode==5 % External (empirical) input
    
    % Allocate memory for the covarianc matrix
    Cm=zeros(ny*nx,ny*nx);
    
    c=0;
    i=1;
    for j=1:ny;
        cvm=ang;
        c=c+1;
        cov=cvm;
        Cm_tmp(c,:)=cov;
    end
    for k=1:nx
        Cm(ny*(k-1)+1:k*ny,ny*(k-1)+1:end)=Cm_tmp(:,1:ny*nx-ny*(k-1));
    end
    
    Cm=Cm'-sqrt(Cm'.*Cm)+Cm;
    
end







