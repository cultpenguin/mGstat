function x = norminv(p,m,s);
% NORMINV returns inverse cumulative function of the normal distribution
%
% x = norminv(p,m,s);
%
% Computes the quantile (inverse of the CDF) of a the normal 
%    cumulative distribution with mean m and standard deviation s
%    default: m=0; s=1;
% p,m,s must be matrices of same size, or any one can be a scalar. 
%
% see also: NORMPDF, NORMCDF 

% Reference(s):

%	$Revision: 1.1 $
%	$Id: norminv.m,v 1.1 2005-05-02 18:15:55 cultpenguin Exp $
%	Version 1.28   Date: 13 Mar 2003
%	Copyright (c) 2000-2003 by  Alois Schloegl <a.schloegl@ieee.org>	

%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

if nargin==1,
        m=0; s=1;
elseif nargin==2,
        s=1;
end;        

% allocate output memory and check size of arguments
x = sqrt(2)*erfinv(2*p - 1).*s + m;  % if this line causes an error, input arguments do not fit. 

x((p>1) | (p<0) | isnan(p) | isnan(m) | isnan(s) | (s<0)) = nan;

k = (s==0) & ~isnan(m);		% temporary variable, reduces number of tests.

x((p==0) & k) = -inf;

x((p==1) & k) = +inf;

k = (p>0) & (p<1) & k;
if prod(size(m))==1,
        x(k) = m;
else
        x(k) = m(k);
end;        
