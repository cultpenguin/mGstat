% sgems_plot_project : Plot an SGeMS project
%
% Call :
%    P=sgems_read_project('project.prj');
%    sgems_plot_project(P);
%
%    % alternatively use
%    P=sgems_plot_project('project.prj');
%
%
% See also: sgems_read_project, sgems_read, sgems_write
% 
function P=sgems_plot_project(P)

if ischar(P);
    P=sgems_read_project(P);
end

fn=fieldnames(P);

for i=1:length(fn);
    figure;
    % GET SGEMS STRUCTURE
    S=P.(fn{i});
    sgems_plot_structure(S);
end
    
end
