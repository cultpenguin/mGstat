% sample_from_2d_pdf
% 
%   [x_sim,y_sim,ir_x,ir_y]=sample_from_2d_pdf(P,x,y);
%
function [x_sim,y_sim,ir_x,ir_y]=sample_from_2d_pdf(P,x,y);

CPDF_x = cumsum((sum(P)));
CPDF_x=CPDF_x./max(CPDF_x(:));

r=rand(1);
ir=find(r<CPDF_x);ir=ir(1);
x_sim = x(ir);
ir_x = ir;

ix = find(x==x_sim);
CPDF_y = cumsum(P(:,ix));
CPDF_y=CPDF_y./max(CPDF_y(:));
r=rand(1);
ir=find(r<CPDF_y);ir=ir(1);
y_sim = y(ir);
ir_y=ir;