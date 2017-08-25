function [pdf_tp, Neig, lim]=tps_mixsim(X,Y,sim,lim,pos,iy,ix,Cm,pdf_tp,options)

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
