% mode_from_reals, get modem entropy and probability from sample of discrete parameter
%
% Call:
%  [m_mode,m_entropy,P,cat]=mode_from_reals(sample,cat,direction); 
%  [m_mode,m_entropy,P,cat]=mode_from_reals(sample,cat);
%  [m_mode,m_entropy,P,cat]=mode_from_reals(sample);
% Input 
%  sample [n_modelparameters, n_reals]
%  cat [1:ncat]: Integer of category
%  direction [0:def,1], if direction=1, sample-->[n_reals,n_modelparameters];
%
function [m_mode,m_entropy,P,cat]=mode_from_reals(sample,cat,direction);

if nargin<2
    cat = unique(sample);
end

if nargin<2
    direction = 0 ; % [nm,nr]
end

if direction == 1;
    sample = sample;
end
%%

[nm,nr]=size(sample);
ncat=length(cat);
P = zeros(nm,ncat);
m_entropy = zeros(nm,1);
m_mode = zeros(nm,1);

for im=1:nm;
    for icat=1:length(cat)
        P(im,icat)=mean(sample(im,:)==cat(icat));
    end
    m_entropy(im)=entropy(P(im,:),ncat);
    i_mode = find(P(im,:)==max(P(im,:)));
    m_mode(im) = cat(i_mode(1));

end

