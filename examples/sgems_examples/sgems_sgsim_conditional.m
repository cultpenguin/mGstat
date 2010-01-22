% sgems_sgsim_conditional : 
%     Conditional SGSIM using hard data from variable

% GET Default par file
S=sgems_get_par('sgsim');

% Define observed data=
S.d_obs=[18 13 0 0; 5 5 0 1; 2 28 0 1];

S.XML.parameters.Nb_Realizations.value=10;
S=sgems_grid(S);

% PLOT DATA
cax=[-2 2];
for i=1:S.XML.parameters.Nb_Realizations.value;
  subplot(4,3,i);
  imagesc(S.x,S.y,S.D(:,:,1,i)');axis image;caxis(cax);title(sprintf('SIM#=%d',i))
end

print('-dpng','sgems_sgsim_conditional')