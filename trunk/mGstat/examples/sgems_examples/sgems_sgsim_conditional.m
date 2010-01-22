S=sgems_get_par('sgsim');

% Define observed data=
S.d_obs=[18 13 0 0; 5 5 0 1; 2 28 0 1];

S.XML.parameters.Nb_Realizations.value=12;
S=sgems_grid(S);
for i=1:S.XML.parameters.Nb_Realizations.value;
  subplot(4,3,i);
  imagesc(S.x,S.y,S.D(:,:,1,i));axis image;
end
