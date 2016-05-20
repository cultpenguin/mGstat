% frequency_mathching: Compute the frequency of occurence of a set of outcomes
% 
%  Ex: 
%  TI=channels;
%  O.N=5; % Number of conditional points
%  [H,Oout]=frequency_matching(TI,O);
%
% See also mps_template
%
function [H,O]=frequency_matching(TI,O);

if nargin<1;
    TI=channels;
    TI=TI(2:2:end,2:2:end);
    O.N_CAT_TI=length(unique(TI)); % TI MUSH CONTAIN ONLY 0,1,2,... VALUES
end
    
if nargin<2
    O.null='';
end

if ~isfield(O,'N_CAT_TI');
    O.N_CAT_TI=length(unique(TI)); % TI MUSH CONTAIN ONLY 0,1,2,... VALUES
end    

O.ND=ndims(TI);

if ~isfield(O,'T')
    if ~isfield(O,'N')
        O.N=5;
    end
    % template not set, use default
    T0=mps_template(O.N-1,O.ND,1);
    O.T=[0 0 0;T0];    
else
    O.N=size(O.T,1); % number of conditional points in template
end



O.NH=O.N_CAT_TI^O.N;

H=zeros(1,O.NH);

b=zeros(1,O.N);

x_min=min([O.T(:,1)]);
x_max=max([O.T(:,1);0]);
y_min=min(O.T(:,2));
y_max=max([O.T(:,2);0]);

for ix0=(1-x_min):1:(size(TI,2)-x_max);
for iy0=(1-y_min):1:(size(TI,1)-y_max);
    
    ix=O.T(:,1)+ix0;
    iy=O.T(:,2)+iy0;
   
    
    %% find matched template
    % for loop, but faster
    for i=1:O.N
        b(i)=TI(iy(i),ix(i));
    end
    
    % no for loop but slower
    %ind = sub2ind(size(TI), iy, ix);
    %b=TI(ind);
    
    %% find index in fmm distribtion
    % Faster Approach
    if ~isfield(O,'base')
        [n,O.base] = id2n(1, O.N_CAT_TI-1, O.N);        
    end
    h_bin=n2id(b(:),O.base);
    
    % Alternate Slower Approach
    % h_bin=bi2de(b,O.N_CAT_TI)+1;
    
    H(h_bin)=H(h_bin)+1;
    
end
end
