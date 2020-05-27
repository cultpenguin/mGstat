% cmap_geosoft : colormap from geosoft
%
% Call: [cmap]=cmap_geosoft(nlevels, green_level, red_level, clim)
%
% Ex %
%    cmap = cmap_geosoft;
%    cmap = cmap_geosoft(10);
%
%    % force red and green colors to match specific data values
%    cax=[.5 250];
%    green_level  = 40;
%    red_level = 200; 
%    cmap = cmap_geosoft(128,green_level red_level, cax);
%
%

function cmap = cmap_geosoft(nlevels, green_level, red_level, clim)

if nargin==0
    nlevels=64;
end


cmap=[
         0         0    1.0000
         0    0.3333    1.0000
         0    0.4980    1.0000
         0    0.6667    1.0000
         0    0.8314    1.0000
         0    0.9137    1.0000
         0    1.0000    1.0000
         0    1.0000    0.7843
         0    1.0000    0.5686
         0    1.0000    0.2471
         0    1.0000    0.1922
         0    1.0000    0.1412
         0    1.0000         0
    0.2824    1.0000         0
    0.3882    1.0000         0
    0.4275    1.0000         0
    0.5686    1.0000         0
    0.7137    1.0000         0
    0.8549    1.0000         0
    1.0000    1.0000         0
    1.0000    0.9137         0
    1.0000    0.8314         0
    1.0000    0.7490         0
    1.0000    0.7059         0
    1.0000    0.6667         0
    1.0000    0.5804         0
    1.0000    0.5373         0
    1.0000    0.4980         0
    1.0000    0.4157         0
    1.0000    0.3333         0
    1.0000    0.2078         0
    1.0000    0.0824         0
    1.0000         0         0
    1.0000         0    0.2157
    1.0000         0    0.4275
    1.0000         0    0.7137
    1.0000    0.0431    0.8549
    1.0000    0.4745    1.0000
    1.0000    0.6235    1.0000
];

nc=size(cmap,1);

if nargin>0
    for i=1:3
        cmap_out(:,i)=interp1(1:nc,cmap(:,i),linspace(1,nc,nlevels));
    end
    cmap=cmap_out;
end


if nargin>1
    colors =[
        0 0 1;
        0 1 1;
        0 1 0;
        1 1 0;
        1 0.5 0;
        1 0 0;
        1.0000    0.6235    1.0000;
        ];
    
    if nargin<2, green_level=0.33;end
    if nargin<3, red_level=0.83;end
    if nargin<4,
        clim(1)=interp1([0.33 0.83],[green_level red_level],0,'linear','extrap')
        clim(2)=interp1([0.33 0.83],[green_level red_level],1,'linear','extrap')
    end
        
    
    green_level = (green_level-clim(1))./diff(clim);
    red_level = (red_level-clim(1))./diff(clim);
    
    
    color_level_1=linspace(0, green_level, 3);
    color_level_2=linspace(green_level, red_level, 4);
    color_level_3=linspace(red_level, 1, 2);
    
    color_level=[color_level_1, color_level_2(2:end), color_level_3(2:end)];
    
    cmap = cmap_linear(colors,color_level,nlevels);
    
end



