% krig_optim_mcmc
% CALL :
%   [V_new,be_acc,L_acc,par2,nugfrac_acc,V_acc,options]=krig_optim_mcmc(pos_known,val_known,V,options)
%
function [V_new,be_acc,L_acc,par2,nugfrac_acc,V_acc,options]=krig_optim_mcmc(pos_known,val_known,V,options);

V_new=V;

if isstr(V),
    V=deformat_variogram(V);
end

options.isorange=1;

if isfield(options,'max_range')
    max_range=options.max_range;
else
    max_range=10*std(pos_known);
end

if isfield(options,'step_range')
    step_range=options.step_range;
else
    step_range=std(pos_known)/112;
end

if isfield(options,'step_nugfrac')
    step_nugfrac=options.step_nugfrac;
else
    step_nugfrac=.1;
end

if isfield(options,'annealing')
    annealing=options.annealing;
else
    annealing=0;
end

if isfield(options,'descent')
    descent=options.descent;
else
    descent=0;
end

if isfield(options,'gvar');
    gvar=options.gvar;
else
    gvar=var(val_known);
end


if isfield(options,'maxit');
    maxit=options.maxit;
else
    maxit=100;
end


if isfield(options,'method');
    method=options.method;
else
    method=1;
    % 1: Maximum Likelihood
    % 2: Maximum likelihood cross validation
end

ndim=size(pos_known,2);

options.dummy='';

nnug=13;
nugarr=linspace(0,1,nnug);nugarr(1)=.01;

std_known=std(pos_known);
mean_known=mean(pos_known);


% A PRIORI
na=25;
for idim=1:ndim
    narr{idim}=na;
    arr{idim}=linspace(0,2*std_known(idim),narr{idim});
    arr{idim}(1)=0.01;
end

V_init=V;
V_old=V;

% NEXT LINE SHOULD GO !!!
% [d_est,d_var,be_init,d_diff,L_init]=krig_blinderror(pos_known,val_known,pos_known,V_init,options);
if method==1
    L_init=krig_covar_lik(pos_known,val_known,V,options);
    be_init=0;
else
    [d_est,d_var,be_init,d_diff,L_init]=krig_blinderror(pos_known,val_known,pos_known,V_init,options);
end

if (isinf(L_init))
    L_init=1e-300;
end

if L_init==0
    L_init=1e-300;
end



be_old=be_init;
L_old=1.0001*L_init;
L_arr=[];
L_min=L_init;
L_new=L_init;
range_min=0.001;

%par2_all=zeros(maxit,length(par2));
L_all=zeros(1,maxit);
%be_all=zeros(1,maxit);
nugfrac_all=zeros(1,maxit);

t_old_plot=now;

nacc=0;
i=0;icum=0;
while i<=maxit
    i=i+1;
    icum=icum+1;
    % Simulated Annealing
    if annealing==1,
        T=exp(-(i-1)/1000);
        options.T=T;
    end

    % PERTURB MODEL
    V_new = V_old;

    % PERTURB RANGE
    V_new(2).par2=V_new(2).par2 + randn(size(step_range)).*step_range;

    % PERTURB NUGGET FRACTION
    nugfrac=V_new(1).par1./gvar;
    nugfrac=nugfrac+randn(1).*step_nugfrac;
    V_new(1).par1=gvar.*nugfrac;
    V_new(2).par1=gvar.*(1-nugfrac);

    % TEST FOR BOUNDS
    compL=1;
    if ~isempty(find(V_new(2).par2<=0)), compL=0; end
    for idim=1:ndim
        if ~isempty(find(V_new(2).par2(idim)>=max_range(idim))),
            compL=0;
        end
    end

    if ((nugfrac<0)|(nugfrac>1))
        compL=0;
    end

    if compL==1
        try
            if method==1,
                L_new=krig_covar_lik(pos_known,val_known,V_new,options);
                be_new=0;
            else
                [d1,d2,be_new,d_diff,L_new]=krig_blinderror(pos_known,val_known,pos_known,V_new,options);
            end

        catch
            %keyboard
        end

        par2_all(i,:)=V_new(2).par2;
        L_all(i) = L_new;
        be_all(i) = be_new;
        nugfrac_all(i) = nugfrac;

    else
        i=i-1; % THIS IS NOT A PARAMETER CHOICE TO BE CONSIDERED
        %L_new=-1e-45;
    end



    % When L is likelihood
    % Pacc=min([(L_new)/(L_old),1]);
    % When L is LOG likelihood
    Pacc=min([exp(L_new-L_old),1]);


    if compL==0
        Pacc=0;
    end

    if descent==1
        % ONLY ACCEPT IMPROVEMENETS
        Prand=1;
    else
        Prand=rand(1);
    end

    if Pacc>=Prand
        %  if Pacc==1  % ONLY ACCPET IMPROVEMENTS

        V_old=V_new;
        L_old=L_new;
        be_old=be_new;

        nacc=nacc+1;

        par2(nacc,:)=V_new(2).par2;

        L_acc(nacc) = L_new;
        be_acc(nacc) = be_new;
        V_acc{nacc} = V_new;
        nugfrac_acc(nacc) = nugfrac;

        doPlot=1;
        dt=(now-t_old_plot)*(3600*24);
        if ((doPlot==1)&(nacc>=1)&(dt>5));
            t_old_plot=now;
            subplot(2,1,1)
            plotyy(1:nacc,L_acc,1:nacc,-be_acc);
            nn=size(par2,1);nmax=400;ndd=ceil(nn/nmax);ii=[ndd:ndd:nn];
            if size(par2,2)==1
                % ONLY PLOT NMAX DATA
                

                subplot(2,3,4)
                %plot(par2(:,1),L_acc,'k.')
                %[ax,h1,h2]=plotyy(par2(:,1),L_acc,par2(:,1),-be_acc);
                %[ax,h1,h2]=plotyy(L_acc,par2(:,1),L_acc,nugfrac_acc);
                [ax,h1,h2]=plotyy(exp(L_acc(ii)),par2(ii,1),exp(L_acc(ii)),nugfrac_acc(ii));
                %[ax,h1,h2]=plotyy(L_all,par2_all(:,1),L_all,nugfrac_all);
                set(h1,'LineStyle','none')
                set(h2,'LineStyle','none')
                set(h1,'Marker','.')
                set(h2,'Marker','.')
                set(h1,'color','b')
                set(h2,'color','g')
                set(get(ax(1),'Ylabel'),'String','Range')
                set(get(ax(2),'Ylabel'),'String','NuggetFraction')
                xlabel('L');

                subplot(2,3,5)
                scatter(par2(ii,1),nugfrac_acc(ii),20,exp(L_acc(ii)),'filled')
                %scatter(par2(:,1),nugfrac_acc,20,exp(L_acc),'filled')
                %keyboard
                %scatter(par2_all(1:i,1),nugfrac_all(1:i),20,L_all(1:i),'filled')
                xlabel('Range');ylabel('Nugget Fraction');title('L')
                subplot(2,3,6)
                %if length(nugfrac_acc)>10
                %    scatter(par2(:,1),nugfrac_acc,20,-be_acc,'filled')
                %end
                %colorbar
                %xlabel('Range');ylabel('Nugget Fraction');title('BE')

                drawnow;
            elseif size(par2,2)==2
                subplot(2,3,4)
                scatter(par2(ii,1),par2(ii,2),22,exp(L_acc(ii)),'filled')
                xlabel('Range 1');ylabel('Range 2');title('Likelihood')
                %colorbar
                %%subplot(2,3,5)
                %%scatter(par2(:,1),par2(:,2),22,-be_acc,'filled')
                %%xlabel('Range 1');ylabel('Range 2');title('-be')
                %colorbar
                subplot(2,3,6)
                scatter3(par2(ii,1),par2(ii,2),nugfrac_acc(ii),20,exp(L_acc(ii)),'filled');
                xlabel('Range 1');ylabel('Range 2');zlabel('Nugget Fraction');title('Likelihood')
                drawnow;
            elseif size(par2,2)>2
                subplot(2,1,2)
                try
                    [ax,h1,h2]=plotyy(1:1:nacc,par2,1:1:nacc,nugfrac_acc);
                catch
                    keyboard
                end
                set(h1,'LineStyle','-','LineWidth',1)
                set(h2,'LineStyle','-','LineWidth',2)
                % set(h1,'Marker','.')
                % set(h2,'Marker','.')
                set(ax(1),'YScale','log')
                set(h2,'color','k')
                set(get(ax(1),'Ylabel'),'String','Range')
                set(get(ax(2),'Ylabel'),'String','NuggetFraction')
                xlabel('iteration');
                legend(num2str([1:1:size(pos_known,2)]))
                drawnow;
            end
        end
        V_old=V_new;
        L_old=L_new;
        disp(sprintf('%3d/%4d --OK-- L = %6.3g  , PA=%4.2g Prand=%4.2g : %s',i,maxit,L_new,Pacc,Prand,format_variogram(V_new)))
        %disp(sprintf('nugfrac=%5.4g  Accept rate = %4.2f%%',nugfrac,100.*nacc./i))
    else
        %if compL==1;
        %  disp(sprintf('%3d/%4d ------ L = %6.3g  , PA=%4.2g Prand=%4.2g : %s',i,maxit,L_new,Pacc,Prand,format_variogram(V_new)))
        %end
    end


end

% FIND BEST VARIOGRAM MODEL
i_max_L=find(L_acc==max(L_acc));
i_max_L=i_max_L(1);
V_new=V_acc{i_max_L};


