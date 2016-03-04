% [i_notes_out]=mps_tree_get_cond_notes(ST,d_cond,i_note_in,i_level,i_notes_out)
function [i_notes_out]=mps_tree_get_cond_notes(ST,d_cond,i_note_in,i_level,i_notes_out)
cat=0:1:(length(ST{1}.count)-1);

if nargin<2, d_cond=[];end
if nargin<3, 
  i_level=0;
  i_note_in=1;
end
if nargin<3, i_notes_out=[];end

if isempty(d_cond);
  i_notes_out=1;
  return
end

%% check if we are the base level
if i_level==length(d_cond)
  %mgstat_verbose(sprintf('%s: at end level',mfilename),1);
  %mgstat_verbose(sprintf('%s: i_note=%d',mfilename,i_note_in),21);
  i_notes_out=[i_notes_out,i_note_in];
  return
end

%% moving to next level
i_level=i_level+1;
%mgstat_verbose(sprintf('%s: moving to level %d',mfilename,i_level),2);

% FIND OUT HOW MANY NOTES MATCH THE CONDITIONAL DATA
% [either none, 1, or ALL 
if isnan(d_cond(i_level));
  i_child_notes=ST{i_note_in}.child;
else 
  v_cond=d_cond(i_level);
  
  i_child_next=find(v_cond==cat);
  i_child_notes=ST{i_note_in}.child(i_child_next);
end
% remove notes with no children
i_child_notes=i_child_notes(find(i_child_notes>0));
if isempty(i_child_notes)
  % NO conditoinal match -> return and prune
  return
end

%% verb
%txt=sprintf(' %d',i_child_notes);
%mgstat_verbose(sprintf('%s: L%03d  i_child_notes=[%s]',mfilename,i_level,txt),1);
%% verb


for i_child=1:length(i_child_notes);
  i_notes_out=mps_tree_get_cond_notes(ST,d_cond,i_child_notes(i_child),i_level,i_notes_out);
end


