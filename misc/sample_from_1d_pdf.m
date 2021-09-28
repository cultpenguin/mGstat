% sample_from_1d_pdf
% 
%   % generate one realization from the pdf [x,P]
%   [x_sim,ir_x]=sample_from_1d_pdf(P,x);
%   % generate nr realizations from the pdf [x,P]
%   [x_sim,ir_x]=sample_from_1d_pdf(P,x,nr);
%   % generate nr realizations from the pdf [x_int,P_int], where
%   %  (pdf interpolated to n_int intervals)
%   [x_sim,ir_x]=sample_from_1d_pdf(P,x,nr,n_int);
%
% See also sample_from_2d_pdf
%
function [x_sim,ir_x,x,P]=sample_from_1d_pdf(P,x,nr,n_int);

if nargin<3, nr=1;end
if nargin<4, n_int=0;end
if n_int>0
    x_new = linspace(x(1),x(end),n_int);
    P_new = interp1(x,P,x_new,'spline');
    x=x_new(:);
    P=P_new(:);    
end


CPDF_x = cumsum(P);
CPDF_x=CPDF_x./CPDF_x(end);

r=rand(1,nr);

for i=1:length(r)
    ir=find(r(i)<CPDF_x);ir=ir(1);
    x_sim(i) = x(ir);
    ir_x(i) = ir;
end