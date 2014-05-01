function [cmap,cols]=cmap_gmt(cmap_name,N)
% cmap_gmt : GMT style colormaps
%
% Call:
%   cmap=cmap_gmt(NAME,N);
%   colormap(cmap);
%   [NAME]: string, name of GMT colormap
%   [N]: integer, number of colors
%
%   NAME:
%     'ocean'
%     'wysiwygcont'
%     'wysiwyg'
%     'seismic'
%     'relief'
%
% See also: cmap_linear
%
%
if nargin<1
    cmap_name='ocean';
end
if nargin<2
    N=128;
end

if strcmp(cmap_name,'ocean')
    cols=[
        0	0	0
        0	5	25
        0	5	25
        0	10	50
        0	10	50
        0	80	125
        0	80	125
        0	150	200
        0	150	200
        86	197	184
        86	197	184
        172	245	168
        172	245	168
        211	250	211
        211	250	211
        250	255	255
        ]./255;
    cmap=cmap_linear(cols,[],N);
    
elseif strcmp(cmap_name,'wysiwygcont')
    cols=[
        64	0	192
        0	64	255
        0	128	255
        0	160	255
        64	192	255
        64	224	255
        64	255	255
        64	255	192
        64	255	64
        128	255	64
        192	255	64
        255	255	64
        255	224	64
        255	160	64
        255	96	64
        255	32	64
        255	96	192
        255	160	255
        255	224	225
        255	255	255
        ]./255;
    cmap=cmap_linear(cols,[],N);
elseif strcmp(cmap_name,'wysiwyg')
    cols=[
        64	0	64
        64	0	64
        64	0	192
        64	0	192
        0	64	255
        0	64	255
        0	128	255
        0	128	255
        0	160	255
        0	160	255
        64	192	255
        64	192	255
        64	224	255
        64	224	255
        64	255	255
        64	255	255
        64	255	192
        64	255	192
        64	255	64
        64	255	64
        128	255	64
        128	255	64
        192	255	64
        192	255	64
        255	255	64
        255	255	64
        255	224	64
        255	224	64
        255	160	64
        255	160	64
        255	96	64
        255	96	64
        255	32	64
        255	32	64
        255	96	192
        255	96	192
        255	160	255
        255	160	255
        255	224	255
        255	224	255
        ]./255;
    cmap=cmap_linear(cols,[],size(cols,1)+1);
    
elseif strcmp(cmap_name,'seismic')
    cols=[
        170	0	0
        255	0	0
        255	85	0
        255	170	0
        255	255	0
        255	255	0
        90	255	30
        0	240	110
        0	80	255
        0	0	205
        ]./255;
    cmap=cmap_linear(cols,[],N);
    
elseif strcmp(cmap_name,'relief')
    cols=[
        0	0	0
        0	5	25
        0	10	50
        0	80	125
        0	150	200
        86	197	184
        172	245	168
        211	250	211
        70	120	50
        20	100	50
        146	126	60
        198	178	80
        250	230	100
        250	234	126
        252	238	152
        252	243	177
        253	249	216
        255	255	255
        ]./255;
    cmap=cmap_linear(cols,[],N);
    
elseif strcmp(cmap_name,'no_green')
    cols=[
        32	96	255
        32	159	255
        32	191	255
        0	207	255
        42	255	255
        85	255	255
        127	255	255
        170	255	255
        255	255	84
        255	240	0
        255	191	0
        255	168	0
        255	138	0
        255	112	0
        255	77	0
        255	0	0
        ]./255;
    cmap=cmap_linear(cols,[],N);
    
    
else
    disp(sprintf('%s: ''%s'' type GMT colorbar not found',mfilename,cmap_name))
    cmap=[];
    cols=[];
end




