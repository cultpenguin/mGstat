% cmap_cmr : 
%
% From Rappaport, C. 2002 - A Color Map for Effective Black-and-white Rendering of Color-Scale Images
% Antennas and Propagation Magazine, IEEE  (Volume:44 ,  Issue: 3 )
% See http://dx.doi.org/10.1109/MAP.2002.1028735
%

function CMRmap=cmap_cmr;

CMRmap = [
0.00 0.00 0.00;
0.15 0.15 0.50;
0.30 0.15 0.75;
0.60 0.20 0.50;
1.00 0.25 0.15;
0.90 0.50 0.00;
0.90 0.75 0.10;
0.90 0.90 0.50;
1.00 1.00 1.00];

cmap=cmap_linear(CMRmap);