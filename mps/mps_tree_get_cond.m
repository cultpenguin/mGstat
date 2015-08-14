% [c_pdf,c]=mps_tree_get_cond(ST,d_cond,cat);
%
% see also: mps_tree_get_cond_notes
function [c_pdf,c]=mps_tree_get_cond(ST,d_cond,cat)


if nargin<2, d_cond=[];end
if nargin<3, cat=0:1:(length(ST{1}.count)-1); end

i_notes=[]; % contain the index of all the 'conditional' notes to be summed
n_cond=length(d_cond);
j=0;
while isempty(i_notes)
  j=j+1;
  use_cond=1:(n_cond-j+1);
  i_notes=mps_tree_get_cond_notes(ST,d_cond(use_cond));
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

c_pdf=c./sum(c);

