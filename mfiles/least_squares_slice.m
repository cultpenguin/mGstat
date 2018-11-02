% least_squares_slice : least sq. inversion using partitioning
%
%
% CALL : [m_est,Cm_est]=least_squares_slice(G,Cm,Cd,m0,d0,id,im);
function [m_est,Cm_est]=least_squares_slice(G,Cm,Cd,m0,d0,id,im);

if nargin<6
    id=[];
end
if nargin<7
    im=[];
end

nd=size(G,1);
nm=size(G,2);

if isempty(id)
    id=1:nd;
end
if isempty(im)
    im=1:nm;
end

id=id(find(id<=nd));
im=im(find(im<=nm));

[m_est_s,C_est_s]=least_squares_inversion(G(id,im),Cm(im,im),Cd(id,id),m0(im),d0(id),2);

% update m_est,Cm_est

m_est=m0;
m_est(im)=m_est_s;
Cm_est=Cm;
for iim=1:length(im);
    Cm_est(im(iim),im)=C_est_s(iim,:);
end
