function [ALL_sim,options]=mixsim_2D(Ny,Nx,Nsim,TI,options)
% call: sim=mixsim_2D(Ny,Nx,Nsim,options)
%
% --- Primary input parameters --- :
% Ny; Depth of the grid to be simualted
% Nx; Width of the grid to be simulated
% Nsim; Number of realizations.
% TI; Cell structure containing 1D traning images 
% --- Optional input parameters --- :
% options.data; Conditional data and their positions. options.data=[observation pos_y pos_x] 
% options.do_cond; 1 = use observed conditioning hard data, 0 = do not use data (default).  
% options.sV; Number of categories in the variables to be simulated. Default = length(pdf1D).
% options.Tx; Neighborhood size for two-point-statistics horizontally. The width of the neighborhood is 2*options.Tx-1. Default =20.
% options.covar_type; Type of covaraince function used for the two-point statistics; 1 = exponential, 2 = spherical (default), 3= Gaussian.
% options.range; Horizontal range used by two-point statistic. Default = 20.
% options.Ty; Neighborhood size for multi-point-statistics vertically. The height of the template/neighborhood is 2*option.Ty+1. Default = 8. 
% options.Cm; Covariance matrix for horizontal dependencies (by default this is calculated using range and covar_type).  
% options.ST; Search tree used for the multiple-point statistics vertically (by default this is calculated using TI).
% options.random_path; Random path; 6 = random path used in paper (default); 1= completely random path
% Other random_path options:
% 0: Raster scan manner along y-direction
% 1: Jump randomly around,
% 2: Random in y-dir, Raster in x-dir.
% 3: Random in x-dir, Raster in y-dir.
% 4: Raster in y-dir., random in x-dir.
% 6: Mixsim simulation as described in the paper Cordua et al., 2016.
%
% Please refer to the following paper when using this algorithm: 
% Cordua, K.S., T.M. Hansen, M.L. Gulbrandsen, C. Barnes, and 
% K. Mosegaard, 2016. Mixed-point geostatistical simulation: A 
% combination of two- and multiple-point geostatistics. Geophysical 
% Research Letters.
%
% K.S. Cordua and T.M. Hansen (2016)

sim_grid_y=Ny;
sim_grid_x=Nx;

if nargin<5
    options=[];
end
if ~isfield(options,'do_cond')
    options.do_cond=0;
end
if ~isfield(options,'sV')
    options.sV=length(unique(cell2mat(TI)));
end
if ~isfield(options,'Tx')
    options.Tx=15;
end
if ~isfield(options,'covar_type')
    options.covar_type=2;
end
if ~isfield(options,'range')
    options.range=20;
end
if ~isfield(options,'Ty')
    options.Ty=8;
end
if ~isfield(options,'random_path')
    options.random_path=6;
end

% Learn the one-point-statistics from the logs:
Hist1D=zeros(1,options.sV);
for i=1:length(TI)
    logi=TI{i};
    for j=1:options.sV
        Hist1D(j)=Hist1D(j)+sum(logi==j);
    end
end
options.pdf1D=Hist1D/sum(Hist1D);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combined two-point and multi-point sim      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ALL_sim=zeros(sim_grid_y,sim_grid_x,Nsim);

if options.do_cond==1
    data=options.data(:,1);
    pos_y=options.data(:,2);
    pos_x=options.data(:,3);
end

% Set up template for mps:
TT=1:options.Ty;
LT=length(TT);
Order=zeros(2*options.Ty,1);
Order(1:2:end-1)=-TT';
Order(2:2:end)=TT';
T=[zeros(2*LT,1),Order,zeros(2*LT,1)];

lim=[options.Tx options.Tx];

% Populate search tree using training images and template:
if ~isfield(options,'ST')
    ST=mps_tree_populate(TI,T);
else
   ST=options.ST; 
end

% Geometry of the field to be simulated
Ny=sim_grid_y+2*options.Ty;
Nx=sim_grid_x;
X=1:Nx;
Y=1+options.Ty:Ny-options.Ty;
[XX,YY]=meshgrid(X,Y);

% Covariance matrix used for two-point simulation:
if options.covar_type==1;
    Va=sprintf('1 Exp(%d,0,0.00001)',options.range);
elseif options.covar_type==2;
    Va=sprintf('1 Sph(%d,0,0.00001)',options.range);
elseif options.covar_type==3
    Va=sprintf('1 Gau(%d,0,0.00001)',options.range);
end
if ~isfield(options,'Cm')
    Cm=precal_cov_2d(1,Nx,1,1,Va);
else
   Cm=options.Cm; 
end

cat=0:1:options.sV-1;

for ns=1:Nsim
%     if round(ns/1)==ns/1
%         progress_txt(ns,Nsim,'Simulates');
%     end
    
    % Initialize grid to be simualted:
    sim=ones(sim_grid_y+2*options.Ty,sim_grid_x)*NaN;
    
    if options.random_path==4
        n_y=0;
    elseif options.random_path==5
        n_x=0;
    elseif options.random_path==3
        n_y=1;
        list3=1:length(X);
        list3=list3(isnan(sim(X(1):X(end))));
    elseif options.random_path==2
        list2=1:length(Y);
        list2=list2(isnan(sim(Y(1):Y(end))));
        n_x=1;
    elseif options.random_path==6
        list1=1:length(X)*length(Y);
        list1=list1(isnan(sim(Y(1):Y(end),X(1):X(end))));
        list1_2D=reshape(list1,sim_grid_y,sim_grid_x);
        list_tmp=[]; % Not empthy
        ix=1;
        iy=1+options.Ty;
    end
    
    if options.do_cond==1
        % Fill in the conditional data in the 'sim' matrix:
        index1 = sub2ind(size(sim), pos_y+options.Ty, pos_x);
        sim(index1)=data;
        index2 = sub2ind([sim_grid_y sim_grid_x], pos_y, pos_x);
    end
    
    Nseqsim=length(list1);
    
    for i=1:Nseqsim
        % Random node to be simulated:
        if options.random_path==1
            [n,list1]=rand_list(list1);
            iy=YY(n);
            ix=XX(n);
            pos=[ix iy];
        elseif options.random_path==0
            % Raster manner simulation:
            n=n+1;
            iy=YY(n);
            ix=XX(n);
            pos=[ix iy];
        elseif options.random_path==2
            [n_y,list2]=rand_list(list2);
            iy=YY(1,n_y);
            ix=XX(n_x,1);
            if isempty(list2)
                list2=1:length(Y);
                list2=list2(isnan(sim(Y(1):Y(end))));
                n_x=n_x+1;
            end
        elseif options.random_path==3
            [n_x,list3]=rand_list(list3);
            ix=XX(n_x,1);
            iy=YY(1,n_y);
            if isempty(list3)
                list3=1:length(X);
                list3=list3(isnan(sim(X(1):X(end))));
                n_y=n_y+1;
            end
        elseif options.random_path==4
            % Jump randomly to different x positions and simulate raster in
            % the y direction:
            if n_y==0
                [n_x,list3]=rand_list(list3);
            end
            n_y=n_y+1;
            ix=XX(n_x,1);
            iy=YY(1,n_y);
            if n_y==sim_grid_y
                n_y=0;
            end
        elseif options.random_path==5
            % Jump randomly to different x positions and simulate raster in
            % the y direction:
            if n_x==0
                [n_y,list2]=rand_list(list2);
            end
            n_x=n_x+1;
            ix=XX(n_x,1);
            iy=YY(1,n_y);
            if n_x==sim_grid_x
                n_x=0;
            end
        elseif options.random_path==6
            % Chose a random direction (1 or 2).
            dir=ceil(rand*2);
            list_tmp1_xdir=list1_2D(iy-options.Ty,~isnan(list1_2D(iy-options.Ty,:)) & isnan(sum(list1_2D,1)));
            list_tmp1_ydir=list1_2D(~isnan(list1_2D(:,ix)) & isnan(sum(list1_2D,2)),ix);
            
            if i==1 % Simulate in a completely random position:
                % This fist position have to be in the same row or
                % column as a conditioning point (if any).
                if options.do_cond~=1;
                    n=rand_list(list1_2D(:));
                    iy=YY(n);
                    ix=XX(n);
                    pos=[ix iy];
                else
                    n=rand_list(index2);
                    iy=YY(n);
                    ix=XX(n);
                    pos=[ix iy];
                end
            elseif ~isempty(list_tmp1_ydir) % Check vertically for "crossing" with previous simulations
                n=rand_list(list_tmp1_ydir);
                iy=YY(n);
                pos=[ix iy];
            elseif ~isempty(list_tmp1_xdir) % Check horizontally for "crossing" with previous simulations
                n=rand_list(list_tmp1_xdir);
                ix=XX(n);
                pos=[ix iy];
            elseif dir==1 % Go to a new position along horizontal with no crossing
                list_tmp=list1_2D(~isnan(list1_2D(:,ix)) & ~isnan(sum(list1_2D,2)),ix);
                
                if isempty(list_tmp) % Looking along y-direction (horizontally) of another x value:
                    try
                        list_tmp=list1_2D(iy,~isnan(list1_2D(iy,:)) & ~isnan(sum(list1_2D,1)));
                        n=rand_list(list_tmp);
                        ix=XX(n);
                        list_tmp=list1_2D(~isnan(list1_2D(:,ix)),ix);
                    catch
                        % All positions in this column have been
                        % simualted -> change direction, which happens
                        % after the next 'catch' eight lines down.
                    end
                end
                
                try
                    n=rand_list(list_tmp);
                    iy=YY(n);
                    pos=[ix iy];
                catch % Change direction
                    list_tmp=list1_2D(iy-options.Ty,~isnan(list1_2D(iy-options.Ty,:)) & ~isnan(sum(list1_2D,1)));
                    n=rand_list(list_tmp);
                    ix=XX(n);
                    pos=[ix iy];
                end
            elseif dir==2 % Go to a new position along vertical with no crossing
                list_tmp=list1_2D(iy-options.Ty,~isnan(list1_2D(iy-options.Ty,:)) & ~isnan(sum(list1_2D,1)));
                
                if isempty(list_tmp) % Looking along horizontal for another y-value:
                    try
                        list_tmp=list1_2D(~isnan(list1_2D(:,ix)) & ~isnan(sum(list1_2D,2)),ix);
                        n=rand_list(list_tmp);
                        iy=YY(n);
                        list_tmp=list1_2D(iy,~isnan(list1_2D(iy,:)));
                    catch
                        % All positions in this row have been simualted
                        % -> change direction, which happens
                        % after the next 'catch' eight lines down.
                    end
                end
                
                try
                    n=rand_list(list_tmp);
                    ix=XX(n);
                    pos=[ix iy];
                catch % Change direction
                    list_tmp=list1_2D(~isnan(list1_2D(:,ix)) & ~isnan(sum(list1_2D,2)),ix);
                    n=rand_list(list_tmp);
                    iy=YY(n);
                    pos=[ix iy];
                end
            end
            % Mark which nodes that have been simulated:
            list1_2D(iy-options.Ty,ix)=NaN;
        end
        
        if isnan(sim(iy,ix)) % This line can be removed if no conditional data are used
            
            % The two-point statistics in relation to mixsim:
            
            % Chose neighborhood:
            if lim(1)>0
                used=set_resim_data(X,Y,sim,lim,pos,0);
                used=used(iy-options.Ty,:);
            else
                used=zeros(size(sim));
                used=used(iy,:);
            end
            
            sim_tmp=sim(iy,:); % Remove two-point conditioing above and below the simulation
            
            % The neighborhood values of conditioning data:
            Neig=sim_tmp(used==0);
            
            % Take the values in the neighborhood that are known or allready
            % simualted:
            val_known=Neig(~isnan(Neig))';
            
            % Data-to-data covariance:
            A1=used(1:end,1:end)==0;
            A2=~isnan(sim_tmp(1:end,1:end));
            K=Cm(A1(:) & A2(:),A1(:) & A2(:));
            
            % data-to-unknown covariance:
            tmp=zeros(size(sim_tmp));
            tmp(ix)=NaN;
            B2=isnan(tmp(1:end,1:end));
            k=Cm(A1(:) & A2(:),A1(:) & B2(:));
            
            % Kriging:
            Ci=Cm(1,1);
            if isempty(K) % No previously simulated parameters within the neighborhood
                pdf_tp=options.pdf1D;
            else
                for j=1:options.sV
                    Vmean=options.pdf1D(j);
                    d_obs=zeros(size(val_known));
                    d_obs(val_known==j)=1;
                    
                    lambda = K\k;
                    pdf_tp(j)=Vmean+lambda'*(d_obs-Vmean);
                end
            end
  
            
            % The multi-point statistics in relation to combined sim %
            
            % Take out the area to be simualted:
            marginal_mp=sim(iy-LT:iy+LT,ix)-1;
            d_cond=marginal_mp(LT+1+T(:,2));
            
            % get conditinal pdf from search tree
            pdf_mp=mps_tree_get_cond(ST,d_cond,cat);
            pdf_mp=pdf_mp/sum(pdf_mp);
            
            % The MIXED-point statistics in relation to combined sim %
            % Combined part of the calculations %
            comb_pdf=(pdf_tp.*pdf_mp)./options.pdf1D;
            comb_pdf=comb_pdf/sum(comb_pdf);
            
            % Simulate from the combined 1Dpdf
            ra=rand;
            sim_val=find(cumsum(comb_pdf)>ra,1,'first');
            
            % Insert simulated value:
            try
                sim(iy,ix)=sim_val;
            catch
                value=ceil(rand*5);
                sim(iy,ix)=value;
                disp('Inconsistency')
                keyboard
            end
        end
    end
    
    sim=sim(options.Ty+1:end-options.Ty,:);
    
    ALL_sim(:,:,ns)=sim;
    
end












