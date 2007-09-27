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
% options.maxit : max number of samples
% options.anneal : [1] simulated annealing [0:def] mcmc
%
% options.
%
% See also : visim_prior_prob;
%
function [L,li,h,d,gv,mf,mfAll]=visim_prior_prob_mcmc(V,options);

    mf=[];    mfAll=[];
    if nargin==0
        V=read_visim('visim_20050322.par');
        V.parfile='test.par';
        V.nsim=60;
        V.volnh.max=4;
        V.gvar=4e-4;
        V.Va.cc=V.gvar;
    end
        
    if nargin<2, 
        options.null='';
    end
        
    if isfield(options,'maxit')==0
        options.maxit=1000;        
    end
    if isfield(options,'isotropic')==0
        options.isotropic=0;
    end
    
    fid=fopen('optim.txt','w');

    if isfield(options,'a_hmax')==0, options.a_hmax.null=0;end
    if isfield(options,'a_hmin')==0, options.a_hmin.null=0;end
    if isfield(options,'a_vert')==0, options.a_vert.null=0;end
    if isfield(options,'ang1')==0, options.ang1.null=0;end
    if isfield(options,'ang2')==0, options.ang2.null=0;end
    if isfield(options,'ang3')==0, options.ang3.null=0;end
    
    d_int=20;

    % RANGES
    if isfield(options.a_hmax,'min')==0,  options.a_hmax.min=0; end
    if isfield(options.a_hmin,'min')==0,  options.a_hmin.min=0; end
    if isfield(options.a_vert,'min')==0,  options.a_vert.min=0; end
    if isfield(options.a_hmax,'max')==0,  options.a_hmax.max=2*(max(V.x)-min(V.x)); end
    if isfield(options.a_hmin,'max')==0,  options.a_hmin.max=2*(max(V.y)-min(V.y)); end
    if isfield(options.a_vert,'max')==0,  options.a_vert.max=2*(max(V.z)-min(V.z)); end
    if isfield(options.a_hmax,'step')==0,  
      options.a_hmax.step= (options.a_hmax.max-options.a_hmax.min)/d_int;    
    end
    if isfield(options.a_hmin,'step')==0,  
      options.a_hmin.step= (options.a_hmin.max-options.a_hmin.min)/d_int;    
    end
    if isfield(options.a_vert,'step')==0,  
      options.a_vert.step= (options.a_vert.max-options.a_vert.min)/d_int;    
    end

    % angles
    if isfield(options.ang1,'min')==0,  options.ang1.min=90-10; end
    if isfield(options.ang1,'max')==0,  options.ang1.max=90+10; end
    if isfield(options.ang2,'min')==0,  options.ang2.min=90-10; end
    if isfield(options.ang2,'max')==0,  options.ang2.max=90+10; end
    if isfield(options.ang3,'min')==0,  options.ang3.min=90-10; end
    if isfield(options.ang3,'max')==0,  options.ang3.max=90+10; end
    if isfield(options.ang1,'step')==0,  
      options.ang1.step= (options.ang1.max-options.ang1.min)/d_int;    
      options.ang1.step=0;
    end
    if isfield(options.ang2,'step')==0,  
      options.ang2.step= (options.ang2.max-options.ang2.min)/d_int;    
      options.ang2.step=0;
    end
    if isfield(options.ang3,'step')==0,  
      options.ang3.step= (options.ang3.max-options.ang3.min)/d_int;    
      options.ang3.step=0;
    end

    if isfield(options,'anneal')==0,  
      options.anneal=0;
    end
    if isfield(options,'accept_only_increase')==0,  
      options.accept_only_increase=0;
    end
    
    gvar.step=0;
    
    Va.old=V.Va;

    
    
    
    % Initial Likelihood :
    %L.old=visim_prior_prob(V,options);
    L.old=-1000;
    

    keepon=1;
    i_all=0;
    i_acc=0;

    anneal.T0=1;
    anneal.i_start=100;
    anneal.decay=1000;
    
    while (keepon==1)
        i_all=i_all+1;
        
        if ((options.anneal==1)&(i_all>anneal.i_start))
            T=anneal.T0*exp(-(i_all-anneal.i_start)/anneal.decay);
        else
            T=1; % NO ANNEALING
        end
        
        
        % Pertub Prior
        Va.new=Va.old;
        
        Va.new.a_hmax=Va.new.a_hmax+randn(1)*options.a_hmax.step;        
        Va.new.a_hmin=Va.new.a_hmin+randn(1)*options.a_hmin.step;        
        Va.new.a_vert=Va.new.a_vert+randn(1)*options.a_vert.step;        

        Va.new.ang1=Va.new.ang1+randn(1)*options.ang1.step;        
        Va.new.ang2=Va.new.ang2+randn(1)*options.ang2.step;        
        Va.new.ang3=Va.new.ang3+randn(1)*options.ang3.step;        

        % CHECK FOR ISOTROPIC
        if options.isotropic==1;
          Va.new.a_hmin=Va.new.a_hmax;
          Va.new.a_vert=Va.new.a_hmax;
          %Va.new.ang1=0;
          %Va.new.ang2=0;
          %Va.new.ang3=0;
        end

                
        % Check Prior Bounds
        outofbounds=0;
        if ((options.a_hmax.step)~=0)
          if Va.new.a_hmax<options.a_hmax.min; outofbounds=1; end
          if Va.new.a_hmax>options.a_hmax.max; outofbounds=1; end
        end
        if ((options.a_hmin.step)~=0)
          if Va.new.a_hmin<options.a_hmin.min; outofbounds=1; end
          if Va.new.a_hmin>options.a_hmin.max; outofbounds=1; end
        end
        if ((options.a_vert.step)~=0)
          if Va.new.a_vert<options.a_vert.min; outofbounds=1; end
          if Va.new.a_vert>options.a_vert.max; outofbounds=1; end
        end
        if ((options.ang1.step)~=0)
          if Va.new.ang1<options.ang1.min; outofbounds=1, end
          if Va.new.ang1>options.ang1.max; outofbounds=1, end
        end
        if ((options.ang2.step)~=0)
          if Va.new.ang2<options.ang2.min; outofbounds=1, end
          if Va.new.ang2>options.ang2.max; outofbounds=1, end
        end
        if ((options.ang3.step)~=0)
          if Va.new.ang3<options.ang3.min; outofbounds=1, end
          if Va.new.ang3>options.ang3.max; outofbounds=1, end
        end
        
        
        % Calculate LogL
        if outofbounds==0
          V.Va=Va.new;
          % [L.new,a,b,Vc,Vu,mfP,mfPAll,Lmean_u]=visim_prior_prob(V,options);
          [L.new,Vc,Vu,out]=visim_prior_prob(V,options);
        %L.new=-10*rand(1);
        else
          L.new=-1e+8;
          Lmean_u=L.new;
          %mfP=1e+9;
          %mfPAll=1e+9.*ones(1,V.nsim);
          disp(sprintf('a_hmax=%5.2g',Va.new.a_hmax))
        end
        li_all(i_all)=L.new;
        %li_all_u(i_all)=Lmean_u;
        h_all(i_all,:)=[Va.new.a_hmax Va.new.a_hmin Va.new.a_vert];
        d_all(i_all,:)=[Va.new.ang1 Va.new.ang2 Va.new.ang3];
        gv_all(i_all,:)=Va.new.cc;
        %mf_all(i_all)=mfP;
        %mf_mfAll(i_all,:)=mfPAll;

        % 
        Pacc=min([1,exp( (L.new-L.old)./T)  ]);

        if (options.accept_only_increase==1)
          % ACCPETH ONLY INCREASE
          if L.new>L.old
            Pacc=1;
          else
            Pacc=0;
          end
        end
        
        r=rand(1);
        if Pacc>r
            i_acc=i_acc+1;
            % ACCEPTING
            L.old=L.new;
            
            Va.old=Va.new;
            
            h(i_acc,:)=[Va.old.a_hmax Va.old.a_hmin Va.old.a_vert];
            d(i_acc,:)=[Va.old.ang1 Va.old.ang2 Va.old.ang3];
            gv(i_acc,:)=Va.old.cc;
            li(i_acc)=L.old;
          
            %mf(i_acc)=mfP;
            %mfAll(i_acc,:)=mfPAll;
            % write info to screen
            
            txt2=sprintf('[h1,h2,h3]=[%5.3f,%5.3f,%5.3f]',Va.old.a_hmax,Va.old.a_hmax,Va.old.a_vert);
            %disp(txt2)
        end
        txt=sprintf('i=%4d(%4d) T=%4.1g Pacc=%4.3f  L=%5.1g',i_all,i_acc,T,Pacc,L.old);
        try
            fprintf(fid,'%s\n',txt);
        catch 
        end
        if isfield(options,'name')
          eval(sprintf('save TEST_%s',options.name));
        else
          save TEST
        end
        
        if i_all==options.maxit; keepon=0; end        
        %if i_acc==200; keepon=0; end            
        if i_all==30000; keepon=0; end            
        if (T<.001), keepon=0; end

        
    end
    
    fclose all;
