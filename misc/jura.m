% jura : Jura data set from Pierre Goovaerts book
%
% Call : 
%  [d_prediction,d_transect,d_validation,h_prediction,h_transect,h_validation]=jura;
%
function [d_prediction,d_transect,d_validation,h_prediction,h_transect,h_validation]=jura;

data_dir = [mgstat_dir,filesep,'examples',filesep,'data',filesep,'jura',filesep];

[d_prediction,h_prediction]=read_eas([data_dir,'prediction.dat']);
[d_transect,h_transect]=read_eas([data_dir,'transect.dat']);
[d_validation,h_validation]=read_eas([data_dir,'validation.dat']);