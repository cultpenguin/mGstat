% lsm : list m-files in directory
% 
% Call : 
%   lsm
%   lsm(path)
% 
function lsm(p)

if nargin==0
    p=pwd;
end
W=what;
for i=1:length(W.m);
    disp(sprintf('%s',W.m{i}));
end
