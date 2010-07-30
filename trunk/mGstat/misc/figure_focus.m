% figure_focus : set focus (without rasising) to figure window
%                i.e. window is not intrusively poppoing up in windows.
%
%
% Call : 
%   f=figure_focus(1); % open figure 1
%     plot(rand(10,10));
%   f=figure_focus(2,f); % open figure 2
%     imagesc(rand(10,10);
%   f=figure_focus(1,f);  % set focus for figure (1), but do not raise it
%     plot(rand(100,100));
%

function f=figure_focus(fig_id,f);
if nargin<1
    fig_id=1;
end
if nargin<2
    f(fig_id)=figure(fig_id);
end

if length(f)<fig_id
    f(fig_id)=0;
end

if f(fig_id)==0;
    f(fig_id)=figure(fig_id);
else;
    set(0,'CurrentFigure',f(fig_id));
end

