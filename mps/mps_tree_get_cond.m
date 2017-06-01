% mps_tree_get_cond: cond conditional from template
%
% Call:
%   [c_pdf,c,d_cond_use]=mps_tree_get_cond(ST,d_cond);
%
%   INPUT
%   ST: Search tree
%   d_cond: conditional data event on order of the template
%           unknown values are coded by 'NaN'
%
%   OUTPUT
%   c_pdf: conditional probabily of outcome at center note given d_cond
%   c: The counte matches leading to c_pdf
%   d_cond_use: The actual conditinoal data event after pruning
%
%
%
% see also: mps_tree_get_cond_notes, mps_tree_populate
%
function [c_pdf,c,d_cond_use]=mps_tree_get_cond(ST,d_cond,cat)

if nargin<2, d_cond=[];end
if nargin<3, cat=0:1:(length(ST{1}.count)-1); end

i_notes=[]; % contain the index of all the 'conditional' notes to be summed
n_cond=length(d_cond);
j=0;
while isempty(i_notes)
  j=j+1;
  use_cond=1:(n_cond-j+1);
  i_notes=mps_tree_get_cond_notes(ST,d_cond(use_cond),cat);
  if isempty(i_notes)
    mgstat_verbose(sprintf('%s pruning conditional data ',mfilename),1);
  end
end
for j=1:length(i_notes)
  if j==1
    c=ST{i_notes(j)}.count;
  else
    c=c+ST{i_notes(j)}.count;
  end
end


% optionally prune if only veruy few counts are found
doUsePruneForSmallCount=1;
if doUsePruneForSmallCount==1;
  
  min_count=10;
  if sum(c)<min_count
    % d_cond(1:(length(d_cond)-1))
    [c_pdf,c,d_cond_use]=mps_tree_get_cond(ST,d_cond(1:(length(d_cond)-1)),cat);
  else
    d_cond_use=d_cond(use_cond);
  end
  
else
  d_cond_use=d_cond(use_cond);
end


c_pdf=c./sum(c);

