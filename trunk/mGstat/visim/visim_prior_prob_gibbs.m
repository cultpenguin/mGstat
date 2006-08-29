% visim_prior_prob_gibbs
%
% Call : 
%    [V,gibbs]=visim_prior_prob_gibbs(V,options);
% 
% Sample the probability density function using a GIBBS sampler. 
%
% options.maxit : max number of samples
%
%
% See also : visim_prior_prob;
%
function [V,gibbs]=visim_prior_prob_gibbs(V,options);

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
        options.maxit=5;        
    end
    
    if isfield(options,'a_hmax')==1
        a_hmax=options.a_hmax;
    else
        a_hmax.step=4;
        a_hmax.min=1;
        a_hmax.max=10;
    end
    if isfield(options,'a_hmin')==1
        a_hmax=options.a_hmin;
    else
        a_hmin.step=4;
        a_hmin.min=1;
        a_hmin.max=10;
    end
    if isfield(options,'ang1')==1
        a_hmax=options.ang1;
    else
        ang1.step=1;
        ang1.min=-5;
        ang1.max=10;
    end

    if isfield(options,'a_hmax_sample')==1
        a_hmax_sample=options.a_hmax_sample;
    else
        a_hmax_sample=1;
    end
    if isfield(options,'a_hmin_sample')==1
        a_hmin_sample=options.a_hmin_sample;
    else
        a_hmin_sample=1;
    end
    if isfield(options,'ang1_sample')==1
        ang1_sample=options.ang1_sample;
    else
        ang1_sample=1;
    end

    
    
    [p,f]=fileparts(V.parfile);
    V.parfile=sprintf('%s_gibbs.par',f);
    
           
    fid=fopen('optim.txt','w');
    
    a_hmax.arr=[a_hmax.min:a_hmax.step:a_hmax.max];
    a_hmin.arr=[a_hmin.min:a_hmin.step:a_hmin.max];
    ang1.arr=[ang1.min:ang1.step:ang1.max];
    
    Va.old=V.Va;

    j=0;
    
    for i=1:options.maxit;
                
        % Primary Direction
        idir=1;
        if ((idir==1)&(a_hmax_sample==1))
            clear Lmean L1mean L2mean
            for ihmax=1:length(a_hmax.arr);
                V.Va.a_hmax=a_hmax.arr(ihmax);                                           
                [Lmean(ihmax),L,Vc,Vu,L1,L2]=visim_prior_prob(V,options);
                L1mean(ihmax)=mean(L1);L1mean(ihmax)=mean(L2);
                
                j=j+1;
                gibbs(j).a_hmax=V.Va.a_hmax;gibbs(j).a_hmin=V.Va.a_hmin;gibbs(j).ang1=V.Va.ang1;
                gibbs(j).L=Lmean(ihmax);gibbs(j).L1=mean(L2);gibbs(j).L2=mean(L2); 
                pl_gibbs(gibbs)
           end            
            p=exp(Lmean-max(Lmean));
            cp=cumsum(p)./sum(p);
            
            h_max_select=interp1(cp,a_hmax.arr,rand(1));
            V.Va.a_hmax=h_max_select;
            [Lmean,L,Vc,Vu,L1,L2]=visim_prior_prob(V,options);

            j=j+1;
            gibbs(j).a_hmax=V.Va.a_hmax;gibbs(j).a_hmin=V.Va.a_hmin;gibbs(j).ang1=V.Va.ang1;
            gibbs(j).L=Lmean;gibbs(j).L1=mean(L2);gibbs(j).L2=mean(L2);

            pl_gibbs(gibbs)
        end

        % Secondary Direction
        idir=2;
        if ((idir==2)&(a_hmin_sample==1))
            clear Lmean L1mean L2mean
            for ihmin=1:length(a_hmin.arr);
                V.Va.a_hmin=a_hmin.arr(ihmin);                                           
                [Lmean(ihmin),L,Vc,Vu,L1,L2]=visim_prior_prob(V,options);
                L1mean(ihmin)=mean(L1);L1mean(ihmin)=mean(L2);                
                j=j+1;
                gibbs(j).a_hmax=V.Va.a_hmax;gibbs(j).a_hmin=V.Va.a_hmin;gibbs(j).ang1=V.Va.ang1;
                gibbs(j).L=Lmean(ihmin);gibbs(j).L1=mean(L2);gibbs(j).L2=mean(L2);
                pl_gibbs(gibbs)
            end            
            p=exp(Lmean-max(Lmean));
            cp=cumsum(p)./sum(p);
            
            h_max_select=interp1(cp,a_hmin.arr,rand(1));
            V.Va.a_hmin=h_max_select;
            [Lmean,L,Vc,Vu,L1,L2]=visim_prior_prob(V,options);
            j=j+1;
            gibbs(j).a_hmax=V.Va.a_hmax;gibbs(j).a_hmin=V.Va.a_hmin;gibbs(j).ang1=V.Va.ang1;
            gibbs(j).L=Lmean;gibbs(j).L1=mean(L2);gibbs(j).L2=mean(L2);

            pl_gibbs(gibbs)
        end
            
            
        % DIP
        idir=3;
        if ((idir==3)&(ang1_sample==1))
            clear Lmean L1mean L2mean
            for iang1=1:length(ang1.arr);
                V.Va.ang1=ang1.arr(ihmin);                                           
                [Lmean(ihmin),L,Vc,Vu,L1,L2]=visim_prior_prob(V,options);
                L1mean(ihmin)=mean(L1);L1mean(ihmin)=mean(L2);                
                j=j+1;
                gibbs(j).a_hmax=V.Va.a_hmax;gibbs(j).a_hmin=V.Va.a_hmin;gibbs(j).ang1=V.Va.ang1;
                gibbs(j).L(j)=Lmean(ihmin);gibbs(j).L1(j)=mean(L2);gibbs(j).L2(j)=mean(L2);
            end            
            p=exp(Lmean-max(Lmean));
            cp=cumsum(p)./sum(p);
            
            h_max_select=interp1(cp,ang1.arr,rand(1));
            V.Va.ang1=h_max_select;
            [Lmean,L,Vc,Vu,L1,L2]=visim_prior_prob(V,options);
            j=j+1;
            gibbs(j).a_hmax=V.Va.a_hmax;gibbs(j).a_hmin=V.Va.a_hmin;gibbs(j).ang1=V.Va.ang1;
            gibbs(j).L=Lmean;gibbs(j).L1=mean(L2);gibbs(j).L2=mean(L2);

            pl_gibbs(gibbs)
        end
        
               
    end
    

function pl_gibbs(gibbs)
    prob=exp([gibbs.L]-max([gibbs.L]));
    figure(10)
    plot([gibbs.a_hmax],[gibbs.a_hmin],'k-')
    hold on
    scatter([gibbs.a_hmax],[gibbs.a_hmin],800.*prob,prob,'.')
    hold off
    drawnow;
    save gibbs_test
    