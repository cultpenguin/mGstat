% Goovaerts Example : simGoo : Sequential Simulation Example
[data,header]=read_eas('transect.dat');

x=data(:,1);
Cd=data(:,4);


% find data
id=find(Cd~=-99);
x_obs=x(id);
Cd_obs=Cd(id);

x=linspace(0,5,200);


%x=[min(x):.01:max(x)];

%V='0.3 Nug(0) + 0.30 Sph(0.2) + 0.26 Sph(1.3)';
%V='0.3 Nug(0) + 0.30 Gau(0.2) + 0.26 Gau(1.3)';
%V='0 Nug(0) + 1 Sph(2)';
%V='0.2 Nug(0) + .8 Sph(2)';
%V='0.5 Nug(0) + .5 Sph(2)';
%V='0.8 Nug(0) + .2 Sph(2)';
%V='0 Nug(0) + 1 Sph(2)';
V='.01 Nug(1) + 0.4 Sph(.3)';
if isstr(V),
	V=deformat_variogram(V);
end 



x_obs_org=x_obs;
Cd_obs_org=Cd_obs;

for ii=1:10
x_obs=x_obs_org;
Cd_obs=Cd_obs_org;
for i=1:length(x);

  if (find(x_obs_org==x(i)))
      % DO NOTHING
      keyboard
  %      pred(i)
    pred(i)=0;
  else  
    [d(i),d_var(i),lambda_ok(:,i),dmean_ok(i)]=krig_ok(x_obs,Cd_obs,x(i),V);
    val=d(i)+randn(1).*d_var(i);
    val=d(i);
    d(i)=val;
    x_obs=[x_obs;x(i)];
    Cd_obs=[Cd_obs;val];
    pred(i)=val;
  end       
    
  
%  [d_trtr(i)]=krig_trend_trend(x_obs,Cd_obs,x(i),V);
end

ppred(ii,:)=pred;

end

figure(gcf);
plot(x,ppred,'k-',x,pred,'r-',x_obs_org,Cd_obs_org,'ro','linewidth',2)
%%plot(x_obs,Cd_obs,'b*',x_obs_org,Cd_obs_org,'ko','linewidth',2)
%plot(x,d,'b-',x_obs_org,Cd_obs_org,'ko','linewidth',2)
