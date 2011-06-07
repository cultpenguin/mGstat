% sgsim : sequential Gaussian simulation
%
% Call : 
%   [sim_mul]=sgsim(pos_known,val_known,pos_sim,V,options);%
% 
% all arguments are the same as for 'krig.m', except the number of
% generated realizations can be set using :
%    options.nsim=10; (default is options.nsim=1)
%
% note: this algorithm is very slow and for teaching purposes 
%       if you intend to simulate large fields use either the 
%       'gstat' or 'mgstat' simulation options.
%
%
% see also: krig

function [sim_mul]=sgsim(pos_known,val_known,pos_sim,V,options);%

if nargin==0;
    
    use_ex=1;
    if use_ex==1
        pos_known=[1 2 4.5]';
        val_known=[-1 .5 -.5]';
        pos_est=0:.05:5;
        pos_sim=[pos_est(:)];
        V=deformat_variogram('0.00001 Nug(0) + 1 Gau(3)');
        options.max=10;
        options.nsim=14;
        options.mean=0;
        [sim_mul]=sgsim(pos_known,val_known,pos_sim,V,options);
        plot(pos_sim,sim_mul);
        
    elseif use_ex==2
        pos_known=[2.01 2;4.01 4;2.01 4;4.01 2];
        val_known=[-1;-.5;.5;1];
        x_est=[0:.25:5];
        y_est=[0:.25:5];
        [xx,yy]=meshgrid(x_est,y_est);
        pos_sim=[xx(:) yy(:)];
        V=deformat_variogram('0.01 Nug(0) + 1 Sph(1)');
        options.max=10;
        options.nsim=4;
        options.mean=0;
        [sim_mul]=sgsim(pos_known,val_known,pos_sim,V,options);
        for i=1:options.nsim
            subplot(2,ceil(options.nsim/2),i);
            scatter(pos_sim(:,1),pos_sim(:,2),10,sim_mul(:,i),'filled');axis image
        end
    elseif use_ex==3
        pos_known=[];
        val_known=[];
        x_est=[0:.25:5];
        y_est=[0:.25:5];
        [xx,yy]=meshgrid(x_est,y_est);
        pos_sim=[xx(:) yy(:)];
        V=deformat_variogram('0.01 Nug(0) + 1 Sph(1)');
        options.max=10;
        options.nsim=4;
        options.mean=0;
        [sim_mul]=sgsim(pos_known,val_known,pos_sim,V,options);
        for i=1:options.nsim
            subplot(2,ceil(options.nsim/2),i);
            scatter(pos_sim(:,1),pos_sim(:,2),10,sim_mul(:,i),'filled');axis image
        end
    end
    return
end

if nargin<5;
    options.null=1;
end

if ~isfield(options,'nsim');
    options.nsim=1;
end

if (size(pos_known,2)==1)
    pos_known(:,2)=0;
    pos_sim(:,2)=0;
end


if (size(val_known,2)==1)
    val_known(:,2)=0;
end

if ischar(V),
    V=deformat_variogram(V);
end

for j=1:options.nsim
    % COMPUTE RANDOM PATH
    n_pos=size(pos_sim,1);
    rp(:,1)=1:1:n_pos;rp(:,2)=rand(n_pos,1);
    i_path=sortrows(rp,2);;
    i_path=i_path(:,1);
    rand_path(:,1)=i_path;
    
    
    n_cond=size(pos_known,1);
    if (n_cond==0); nc=2;end
    
    % pre allocate
    nc=size(pos_sim,2);
    pos=zeros(n_pos,nc);
    val=zeros(n_pos,nc);
        
    disp(sprintf('%s : realization %d/%d',mfilename,j,options.nsim))
    d_sim=ones(size(pos_sim,1),1).*NaN;
    i_use_cond=ones(size(pos_known,1),1);
    
    for i=1:size(pos_sim,1)
        if ((i/100)==round(i/100))
            disp(sprintf('%s : realization=%d/%d, i=%d/%d',mfilename,j,options.nsim,i,size(pos_sim,1)))
        end
        i_pos=i_path(i);
        
        % Find the data observations that should be used as conditional
        % (This should exclude data at datalocations allready simulated)
        i_cond=find(i_use_cond);
        
        % FIND ALL CONDITIONAL DATA : Observed + Simulated
        pos_all = [pos(1:(i-1),:) ; pos_known(i_cond,:)];
        val_all = [val(1:(i-1),:) ; val_known(i_cond,:)];
        
        % COMPUTE LOCAL CONDITIONAL PDF
        options_krig=options;
        try;options_krig=rmfield(options_krig,'nsim');end
        
        try
            if iscell(V);
                [mean_est,var_est] = krig(pos_all,val_all,pos_sim(i_pos,:),V{i_pos},options_krig);
            else
                [mean_est,var_est] = krig(pos_all,val_all,pos_sim(i_pos,:),V,options_krig);
            end
            
        catch
            keyboard
        end
        
        % FIND OUT IF WE JUST KRIGED AN 'OBSERVED' LOCATION
        if n_cond>0
            ir=find_row_array(pos_known,pos_sim(i_pos,:));
            if ~isempty(ir)
                i_use_cond(ir)=0;
            end
        end
        
        % DRAW A REALIZATION
        d_sim(i_pos) = norminv(rand(1),mean_est,sqrt(var_est));
        
        % ADD SIMULATED VALUE TO LIST OF KNOWN VALUES
        pos(i,:)=[pos_sim(i_pos,:)];
        if size(val,2)==1
            val(i,:)=[d_sim(i_pos)];
        else
            val(i,:)=[d_sim(i_pos) 0 ];
        end
        
    end
    sim_mul(:,j)=d_sim;
end









