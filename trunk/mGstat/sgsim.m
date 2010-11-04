% sgsim : DO NOT USE YET....
function [sim_mul]=sgsim(pos_known,val_known,pos_est,V,options);

if nargin<5;
    options.null=1;
end

if ~isfield(options,'nsim');
    options.nsim=10;
end

pos_known_all=pos_known;
val_known_all=val_known;

for j=1:options.nsim
    % COMPUTE RANDOM PATH
    n_pos=size(pos_est,1);
    rp(:,1)=1:1:n_pos;rp(:,2)=rand(n_pos,1);
    i_path=sortrows(rp,2);;
    i_path=i_path(:,1);
    rand_path(:,1)=i_path;
    
    n_cond=size(pos_known_all,1);

    % pre allocate 
    pos_known=zeros(n_pos+n_cond,size(pos_known_all,2));
    val_known=zeros(n_pos+n_cond,size(val_known_all,2));
    
    % add conditional data
    pos_known(1:n_cond,:)=pos_known_all;
    val_known(1:n_cond,:)=val_known_all;
    
    j_cond=n_cond;
    
    disp(sprintf('j=%d/%d',j,options.nsim))
    d_sim=ones(size(pos_est,1),1).*NaN;
    for i=1:size(pos_est,1)
        if ((i/100)==round(i/100))
            disp(sprintf('j=%d/%d, i=%d/%d',j,options.nsim,i,size(pos_est,1)))
        end
        i_pos=i_path(i);

        % COMPUTE LOCAL CONDITIONAL PDF
        
        try
            [mean_est,var_est] = krig(pos_known(1:j_cond,:),val_known(1:j_cond,:),pos_est(i_pos,:),V,options);
        catch
            keyboard
        end
          
        %if i==10;
        %    keyboard
        %end
        
        % DRAW A REALIZATION
        d_sim(i_pos) = norminv(rand(1),mean_est,sqrt(var_est));
        
        % ADD SIMULATED VALUE TO LIST OF KNOWN VALUES        
        j_cond=j_cond+1;
        pos_known(j_cond)=[pos_est(i_pos)];
        if size(val_known,2)==1            
            val_known(j_cond,:)=[d_sim(i_pos)];
        else
            val_known(j_cond,:)=[d_sim(i_pos) 0 ];
        end
        %
    end
    sim_mul(:,j)=d_sim;
end









