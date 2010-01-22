% sgems_sgsim_conditional_hard_data_from_file : 
%     Conditional SGSIM using hard data from file

% GET Default par file
S=sgems_get_par('sgsim');

% Define observed data=
d_obs=[18 13 0 0; 5 5 0 1; 2 28 0 1];
sgems_write_pointset('obs.sgems',d_obs);
S.f_obs='obs.sgems';

S.XML.parameters.Nb_Realizations.value=10;
S=sgems_grid(S);


%% PLOT DATA
cax=[-2 2];
for i=1:S.XML.parameters.Nb_Realizations.value;
  subplot(4,3,i);
  imagesc(S.x,S.y,S.D(:,:,1,i)');axis image;caxis(cax);title(sprintf('SIM#=%d',i))
end
[m,v]=etype(S.D);
subplot(4,3,11);
imagesc(S.x,S.y,m');axis image;caxis(cax);title('Etype mean')
subplot(4,3,12);
imagesc(S.x,S.y,v');axis image;caxis([0 2]);title('Etype variance')
hold on
plot(d_obs(:,1),d_obs(:,2),'wo','MarkerSize',10)
hold off
colorbar

print('-dpng','sgems_sgsim_conditional_hard_data_from_file')
