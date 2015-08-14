% mps_tree_populate: populate search tree from traing image
%
% Call:
%   [ST,template]=mps_tree_populate(ti,template,d_cell,ST);
%   INPUT:
%     ti: training image [1D, 2D]
%     template: Template with condtional index locations
%             output from mps_template
%     d_cell: [def=1]; Skip every 'd_cell' pixels in ti. 
%           used to infer search trees for multiple grid approach
%     ST: [optional] Search Tree data structure. 
%           If ST is input, then this ST will be updated from the given ti
%           Otherwise a new ST data structure will be generated
%  OUTPUT
%   ST: [optional] Search Tree data structure. 
%   template: The used template
%
% Example 1:
%  ti=channels;
%  n_max=9;n_dim=2;
%  [template]=mps_template(n_max,n_dim);
%  [ST]=mps_tree_populate(ti,template);
% 
%  % conditinal data event
%  d_cond = [NaN NaN 0 1]; % conditional data event
%  % conditional probability at the center note given the data event.
%  [c_pdf,d_count]=mps_tree_get_cond(ST,d_cond);
%
%
% Example 2: Multiple training images
%   ti=channels;
%   ti_mul{1}=ti(1:125,1:125);
%   ti_mul{2}=ti(126:250,1:125);
%   ti_mul{3}=ti(1:125,126:250);
%   ti_mul{4}=ti(126:250,126:250);
%   [ST]=mps_tree_populate(ti_mul{1},template);
%   [ST]=mps_tree_populate(ti_mul{2},template,1,ST);
%   [ST]=mps_tree_populate(ti_mul{3},template,1,ST);
%   [ST]=mps_tree_populate(ti_mul{4},template,1,ST);
%
%
% See also: mps_tree_get_cond, mps_tree_get_cond_notes, mps_template
%
function [ST,template]=mps_tree_populate(ti,template,d_cell,ST);
if nargin<1, ti=channels;end
if nargin<2, template=mps_template;end
if nargin<3, d_cell=1;end % Multiple grid spacing

if iscell(ti);
  % assume that multiple TIs are given in a cell structure
  for i=1:length(ti);
    mgstat_verbose(sprintf('%s: populating search tree from ti #%d/%d',mfilename,i,length(ti)));
    if i==1;
      [ST,template]=mps_tree_populate(ti{i},template,d_cell);
    else
      [ST,template]=mps_tree_populate(ti{i},template,d_cell,ST);
    end
  end
  return
end

%%
v_level=-1;

n_max=size(template,1);
cat=unique(ti(:));
n_cat=length(cat);

%% Initiaize tree
if ~exist('ST','var')
  ST{1}.cat=cat;
  ST{1}.count=zeros(1,n_cat);
  ST{1}.child=zeros(1,n_cat);
  cat=ST{1}.cat;
end

[ny,nx,nz]=size(ti);
for iz=1;1:nz;
  for iy=1:ny;
    for ix=1:nx;
      
      mgstat_verbose(sprintf('%s: at location [x,y,z]=[%d,%d,%d]',mfilename,ix,iy,iz),1)
      loop_continue=1;
      
      %% Update base
      % find index of category
      i_cat_base=find(ti(iy,ix)==cat);
      % update count of category
      ST{1}.count(i_cat_base)=ST{1}.count(i_cat_base)+1;
      
      %%
      
      i_father=1;
      %i_cat_father=i_cat_base;
      
      if v_level>0
        disp(sprintf(' - u=%d ',cat(i_cat_base)));
      end  
      % loop over all conditional points
      % (look over the template in order)
      clear d_cond;
      for i=1:n_max
        % find relative index for current note
        idx=template(i,1)*d_cell;
        idy=template(i,2)*d_cell;
        idz=template(i,3)*d_cell;
        
        x_g=ix+idx;
        y_g=iy+idy;
        z_g=iz+idz;
        
        if (x_g<1)|(x_g>nx)|(y_g<1)|(y_g>ny)
          loop_continue=0;
        end
        if loop_continue==1
          % only progress if template is within boundaries
          
          % find index of category
          i_cat=find(ti(y_g,x_g)==cat);
          
          % Find child based in i_cat
          try
          i_child=ST{i_father}.child(i_cat);
          catch
            keyboard
          end
          % locate child tree node, and create it if it does not exist
          if i_child==0;
            [ST,i_child]=mps_tree_add_note(ST,i_father);
            ST{i_father}.child(i_cat)=i_child;
          end
          try
          d_cond(i)=cat(i_cat);
          catch
            keyboard
          end
          if v_level>1
            txt=[];for j=1:i;txt=sprintf('%s u_%d=%d ',txt,i,d_cond((j)));end
            disp(sprintf(' - u=%d - %s ',cat(i_cat_base),txt));
          end
          % update count
          ST{i_child}.count(i_cat_base)=ST{i_child}.count(i_cat_base)+1;
          
          %ST{i_child}.d_cond=d_cond; % NOT NECESSARY only convenient
          
          % move from father to chile at set child as father
          i_father=i_child;
          %i_cat_father=i_cat;
          
        end
      end
      
      
    end
  end
end


function [ST,iST]=mps_tree_add_note(ST,i_father);
nST=length(ST);iST=nST+1;
n_cat=length(ST{i_father}.count);
% ST{iST}.father=i_father; % NOT NECESSARY, only convenint
ST{iST}.count=zeros(1,n_cat);
ST{iST}.child=zeros(1,n_cat);


