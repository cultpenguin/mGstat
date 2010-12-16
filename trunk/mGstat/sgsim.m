% sgsim : DO NOT USE YET....

%
%
%
%

function [sim_mul]=sgsim(pos_known,val_known,pos_sim,V,options);%

if nargin==0;
    
    use_ex=2;
    if use_ex==1;
        % example
        pos_known=10*rand(10,1);
        val_known=rand(size(pos_known)); % adding some uncertainty
        pos_sim=[0:.01:10]';
        V=deformat_variogram('1 Sph(1)');
        options.max=10;
        options.nsim=10;
        [d_sim]=sgsim(pos_known,val_known,pos_sim,V,options);
        %plot(pos_sim,d_est,'r.',pos_sim,d_var,'b.',pos_known,val_known(:,1),'g*')
        %legend('SK estimate','SK variance','Observed Data')
        sim_mul=d_sim;
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

if (size(val_known,2)==1)
    val_known(:,2)=0;
end

if ischar(V),
    V=deformat_variogram(V);
end


%pos_known_all=pos_known;
%val_known_all=val_known;

% START BY ASSIGNING DATA AT GRID NOTES A VALUE !!!
% OTHERWISE WE GET NAN VALUES !!!


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
    
    
    % add conditional data
    %if n_cond>0
    %    pos_known(1:n_cond,:)=pos_known_all;
    %    val_known(1:n_cond,size(val_known_all,2))=val_known_all;
    %end
    %j_cond=n_cond;
    %j_cond=0;
    
    disp(sprintf('j=%d/%d',j,options.nsim))
    d_sim=ones(size(pos_sim,1),1).*NaN;
    i_use_cond=ones(size(pos_known,1),1);
    
    for i=1:size(pos_sim,1)
        if ((i/100)==round(i/100))
            disp(sprintf('j=%d/%d, i=%d/%d',j,options.nsim,i,size(pos_sim,1)))
        end
        i_pos=i_path(i);
        
        % Find the data observations that should be used as conditional
        % (This should exclude data at datalocations allready simulated)
        i_cond=find(i_use_cond);
        
        % FIND ALL CONDITIONAL DATA : Observed + Simulated
        pos_all = [pos(1:(i-1),:) ; pos_known(i_cond,:)];
        val_all = [val(1:(i-1),:) ; val_known(i_cond,:)];
        %disp(sprintf('i=%d, ncond=%d',i,size(pos_all,1)))
        
        % COMPUTE LOCAL CONDITIONAL PDF
        try
            if iscell(V);
                %[mean_est,var_est] = krig(pos_known(i_cond,:),val_known(i_cond,:),pos_sim(i_pos,:),V{i_pos},options);
                [mean_est,var_est] = krig(pos_all,val_all,pos_sim(i_pos,:),V{i_pos},options);
            else
                %[mean_est,var_est] = krig(pos_known(i_cond,:),val_known(i_cond,:),pos_sim(i_pos,:),V,options);
                [mean_est,var_est] = krig(pos_all,val_all,pos_sim(i_pos,:),V,options);
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
        if (isreal(mean_est)==0)
            keyboard
        end
        
        
        % DRAW A REALIZATION
        d_sim(i_pos) = norminv(rand(1),mean_est,sqrt(var_est));
        
        if (isreal(d_sim(i_pos))==0)
            keyboard
        end
        
        
        % ADD SIMULATED VALUE TO LIST OF KNOWN VALUES
        pos(i,:)=[pos_sim(i_pos,:)];
        if size(val,2)==1
            val(i,:)=[d_sim(i_pos)];
        else
            val(i,:)=[d_sim(i_pos) 0 ];
        end
        %
        
        %scatter(pos(:,1),pos(:,2),10,val(:,1),'filled');drawnow;
    end
    sim_mul(:,j)=d_sim;
end









