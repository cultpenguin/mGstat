

function draw_boxes(pos_x,pos_y,w,color)

% Call: draw_boxes(pos_x,pos_y,w,color)
% pos_x,pos_y are the center positions of the boxes
% w is the width of the frame
% color: e.g. 'g' for green frame
%
% Knud S. Cordua, 2017

if nargin<4
    color='k';
end
if nargin<3
    w=2;
end


for i=1:size(pos_x,1);
    x1=pos_y(i)-0.5;
    x2=pos_y(i)+0.5;
    y1=pos_x(i)-0.5;
    y2=pos_x(i)+0.5;
    
    % --- sorte streger
    hold on
    streg_x=[y1 y2];
    streg_y=[x2 x2];
    plot(streg_x,streg_y,color,'linewidth',w)
    hold on
    streg_x=[y2 y2];
    streg_y=[x1 x2];
    plot(streg_x,streg_y,color,'linewidth',w)
    hold on
    streg_x=[y1 y2];
    streg_y=[x1 x1];
    plot(streg_x,streg_y,color,'linewidth',w)
    hold on
    streg_x=[y1 y1];
    streg_y=[x1 x2];
    plot(streg_x,streg_y,color,'linewidth',w)
    
end