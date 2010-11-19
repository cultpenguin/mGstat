% sgsim : DO NOT USE YET....

%
% 
%
%

function [sim_mul]=sgsim(pos_known,val_known,pos_est,V,options);%

if nargin==0;
    
    use_ex=2;
    if use_ex==1;
        % example
        pos_known=10*rand(10,1);
        val_known=rand(size(pos_known)); % adding some uncertainty
        pos_est=[0:.01:10]';
        V=deformat_variogram('1 Sph(1)');
        options.max=10;
        options.nsim=10;
        [d_sim]=sgsim(pos_known,val_known,pos_est,V,options);
        %plot(pos_est,d_est,'r.',pos_est,d_var,'b.',pos_known,val_known(:,1),'g*')
        %legend('SK estimate','SK variance','Observed Data')
        sim_mul=d_sim;
    elseif use_ex==2
        pos_known=[2.01 2;4.01 4;2.01 4;4.01 2];
        val_known=[-1;-.5;.5;1];
        x_est=[0:.25:5];
        y_est=[0:.25:5];
        [xx,yy]=meshgrid(x_est,y_est);
        pos_est=[xx(:) yy(:)];
        V=deformat_variogram('0.01 Nug(0) + 1 Sph(1)');
        options.max=10;
        options.nsim=4;
        options.mean=0;
        [sim_mul]=sgsim(pos_known,val_known,pos_est,V,options);
        for i=1:options.nsim
            subplot(2,ceil(options.nsim/2),i);
            scatter(pos_est(:,1),pos_est(:,2),10,sim_mul(:,i),'filled');axis image
        end
    elseif use_ex==3
        pos_known=[];
        val_known=[];
        x_est=[0:.25:5];
        y_est=[0:.25:5];
        [xx,yy]=meshgrid(x_est,y_est);
        pos_est=[xx(:) yy(:)];
        V=deformat_variogram('0.01 Nug(0) + 1 Sph(1)');
        options.max=10;
        options.nsim=4;
        options.mean=0;
        [sim_mul]=sgsim(pos_known,val_known,pos_est,V,options);
        for i=1:options.nsim
            subplot(2,ceil(options.nsim/2),i);
            scatter(pos_est(:,1),pos_est(:,2),10,sim_mul(:,i),'filled');axis image
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

pos_known_all=pos_known;
val_known_all=val_known;


% START BY ASSIGNING DATA AT GRID NOTES A VALUE !!!
% OTHERWISE WE GET NAN VALUES !!!


for j=1:options.nsim
    % COMPUTE RANDOM PATH
    n_pos=size(pos_est,1);
    rp(:,1)=1:1:n_pos;rp(:,2)=rand(n_pos,1);
    i_path=sortrows(rp,2);;
    i_path=i_path(:,1);
    rand_path(:,1)=i_path;
    
    n_cond=size(pos_known_all,1);

    % pre allocate 
    pos_known=zeros(n_pos+n_cond,size(pos_est,2));
    val_known=zeros(n_pos+n_cond,size(pos_known,2));
    
    % add conditional data
    if n_cond>0
        pos_known(1:n_cond,:)=pos_known_all;
        val_known(1:n_cond,size(val_known_all,2))=val_known_all;
    end
    j_cond=n_cond;
    
    disp(sprintf('j=%d/%d',j,options.nsim))
    d_sim=ones(size(pos_est,1),1).*NaN;
    for i=1:size(pos_est,1)
        if ((i/100)==round(i/100))
            disp(sprintf('j=%d/%d, i=%d/%d',j,options.nsim,i,size(pos_est,1)))
        end
        i_pos=i_path(i);

        % COMPUTE LOCAL CONDITIONAL PDF
        if j_cond==0
            mean_est=0;
            if isfield(options,'mean'); mean_est=options.mean;end
            if isfield(options,'mean_sk'); mean_est=options.mean_sk;end
            var_est=sum([V.par1]);
        else
        
            try
                if iscell(V);
                    [mean_est,var_est] = krig(pos_known(1:j_cond,:),val_known(1:j_cond,:),pos_est(i_pos,:),V{i_pos},options);
                else
                    [mean_est,var_est] = krig(pos_known(1:j_cond,:),val_known(1:j_cond,:),pos_est(i_pos,:),V,options);
                end
                
            catch
                keyboard
            end
        end
        if (isnan(mean_est))
            keyboard
        end
        
        %if i==10;
        %    keyboard
        %end
        
        % DRAW A REALIZATION
        d_sim(i_pos) = norminv(rand(1),mean_est,sqrt(var_est));
        %d_sim(i_pos) = mean_est;
        % ADD SIMULATED VALUE TO LIST OF KNOWN VALUES        
        %keyboard
        j_cond=j_cond+1;
        pos_known(j_cond,:)=[pos_est(i_pos,:)];
        if size(val_known,2)==1            
            val_known(j_cond,:)=[d_sim(i_pos)];
        else
            val_known(j_cond,:)=[d_sim(i_pos) 0 ];
        end
        %
        
    end
    sim_mul(:,j)=d_sim;
end









