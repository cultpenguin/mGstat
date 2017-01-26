% mps_path: Different random path for sequential simualtion
%
% i_path=mps_path(SIM,rand_path,d_soft);
%
% SIM [ny,nx]: simulation grids (NaN values for unsampled values) 
% rand_path [-1] Sequential path (y, x, z)
%           [0] Sequential path (x, y, z)
%           [1] Random
%           [2] Preferential
%           [3] Multi-grid
%           [4] MIXPOINT
% 
function i_path=mps_path(SIM,rand_path,d_soft);
if nargin<2
    rand_path=1;
end

%%
[ny,nx,nz]=size(SIM);

NXYZ=prod([ny,nx]);


i_path=find(isnan(SIM'));
if rand_path==0
    j=0;
    for ix=1:nx
        for iy=1:ny
           for iz=1:nz
            j=j+1;
            IP(ix,iy)=j;
           end
        end
    end
    i_path=IP(:);
            
elseif rand_path==1
    % 'SHUFFLE' index of path to get a random path
    i_path=shuffle(i_path);
    mgstat_verbose(sprintf('%s: Shuffling path',mfilename),1)
elseif rand_path==2
    % PREFERENTIAL PATH
    nxy=prod(size(SIM));
    N_CAT=2; % NEEDS TO A FREE PARAMETER
    p_uninformed=ones(1,N_CAT)/N_CAT;
    maxE=entropy(p_uninformed);
    if exist('d_soft','var');
        d_soft=d_soft(:);
        % ONLY WORKS WHEN N_CAT=2
        SOFT_ENTROPY=d_soft.*0;
        for i=1:length(d_soft);
            if isnan(d_soft(i));
                SOFT_ENTROPY(i)=maxE;
            else
                SOFT_ENTROPY(i)=entropy([d_soft(i) 1-d_soft(i)]);
            end
        end
    else
        SOFT_ENTROPY=ones(size(SIM)).*maxE;
        SOFT_ENTROPY=SOFT_ENTROPY(:);
    end
    
    Ifac=4; % NEEDS TO BE A FREE PARAMETER
    SEPERATE_SOFT_TO_HARD=1;
    SE_order = rand(nxy,1)-SEPERATE_SOFT_TO_HARD+Ifac*(maxE-SOFT_ENTROPY);
    A=sortrows([SE_order,[1:1:nxy]'],[-1 2]);
    i_path=A(:,2);
    mgstat_verbose(sprintf('%s: Preferential path',mfilename),1)
elseif rand_path==3
    R=rand(size(SIM))    ;
    for dx=3:2:7;
        ix1=ceil(rand(1)*dx);
        iy1=ceil(rand(1)*dx);
        ix_arr=ix1:dx:nx;
        iy_arr=iy1:dx:ny;
        R(iy_arr,ix_arr)=10*(dx-1)+rand(length(iy_arr),length(ix_arr));
    end
    % SORT
    Rt=R';
    ROWS=[-1*Rt(:) [1:NXYZ]'];
    SR=sortrows(ROWS,[1 2]);
    i_path=SR(:,2);
    mgstat_verbose(sprintf('%s: multi-grid path',mfilename),1)    
elseif rand_path==4
    % mixed_point_path
    %i_path=rand_list(SIM,1);
    i_path=rand_list(i_path,1);
    mgstat_verbose(sprintf('%s: MIXSIM path',mfilename),1)
end
