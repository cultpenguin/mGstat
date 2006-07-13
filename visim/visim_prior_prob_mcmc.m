% visim_prior_prob_mcmc
%
% Call : 
%    [L,h,d,gv]=visim_prior_prob_mcmc(V,options);
% 
% Sample the probability density function 
% describing the likelihood that a sample of the 
% posterior (conditional simulation) is a samples of
% the prior pdf (unconditional simulation)
%
%
%
%
% See also : visim_prior_prob;
%
function [L,h,d,gv]=visim_prior_prob_mcmc(V,options);

    if nargin==0
        V=read_visim('visim_20041026.par');
        V.nsim=10;
        V.volnh.max=4;
    end
        
    if nargin<2, 
        options.null='';
    end
        
    if isfield(options,'maxit')==0
        options.maxit=1000;        
    end
    

    fid=fopen('optim.txt','w');
    
    % STEP
    a_hmax.step=1;
    a_hmin.step=1;
    a_vert.step=0;
    ang1.step=.5;
    ang2.step=0;
    ang3.step=0;
    gvar.step=0;
    
    Va.old=V.Va;
    
    
    % Initial Likelihood :
    L.old=visim_prior_prob(V);
    %L.old=-10*rand(1);
    

    keepon=1;
    i_all=0;
    i_acc=0;

    anneal.T0=1;
    anneal.i_start=100;;
    anneal.decay=1000;
    option.anneal=1;
    
    
    while (keepon==1)
        i_all=i_all+1;
        
        if ((option.anneal==1)&(anneal.i_start>i_all))
            T=anneal.T0*exp(-(i_all-anneal.i_start)/anneal.decay);
        end
        
        
        % Pertub Prior
        Va.new=Va.old;
        
        Va.new.a_hmax=Va.new.a_hmax+randn(size(a_hmax.step))*a_hmax.step;        
        Va.new.a_hmin=Va.new.a_hmin+randn(size(a_hmin.step))*a_hmin.step;        
        Va.new.a_vert=Va.new.a_vert+randn(size(a_vert.step))*a_vert.step;        

        Va.new.ang1=Va.new.ang1+randn(size(ang1.step))*ang1.step;        
        Va.new.ang2=Va.new.ang2+randn(size(ang2.step))*ang2.step;        
        Va.new.ang3=Va.new.ang3+randn(size(ang3.step))*ang3.step;        
        % Check Prior Bounds

        
        % Calculate LogL
        V.Va=Va.new;
        L.new=visim_prior_prob(V);
        %L.new=-10*rand(1);
        
        % 
        Pacc=min([1,exp( (L.new-L.old)./T)  ]);

        r=rand(1);
        if Pacc>r
            i_acc=i_acc+1;
            % ACCEPTING
            L.old=L.new;
            
            Va.old=Va.new;
            
            h(i_acc,:)=[Va.old.a_hmax Va.old.a_hmin Va.old.a_vert];
            d(i_acc,:)=[Va.old.ang1 Va.old.ang2 Va.old.ang3];
            gv(i_acc,:)=Va.old.cc;
            
            
            % write info to screen
            
            txt2=sprintf('[h1,h2,h3]=[%5.3f,%5.3f,%5.3f]',Va.old.a_hmax,Va.old.a_hmax,Va.old.a_vert);
            %disp(txt2)
        end
        txt=sprintf('i=%4d(%d) T=%4.1g Pacc=%4.3f  L=%5.1g',i_all,i_acc,T,Pacc,L.old);
        fprintf(fid,'%s\n',txt);
        
        
        if i_acc==3000; keepon=0; end            
        if i_all==30000; keepon=0; end            
        if (T<.001), keepon=0; end
        
    end

fclose all;