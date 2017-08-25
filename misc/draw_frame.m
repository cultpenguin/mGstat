

function draw_frame(x1,x2,y1,y2,w,color)

% Call: draw_frame(x1,x2,y1,y2,w,color);
% x1,x2,y1,y2 are the corners of the frame
% w is the width of the frame
% color: e.g. 'g' for green frame

if nargin<6
    color='k';
    
end

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