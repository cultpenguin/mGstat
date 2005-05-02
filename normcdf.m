function p = normcdf(x,m,s);
% NORMCDF returns normal cumulative distribtion function
%
% cdf = normcdf(x,m,s);
%
% Computes the CDF of a the normal distribution 
%    with mean m and standard deviation s
%    default: m=0; s=1;
% x,m,s must be matrices of same size, or any one can be a scalar. 
%
% see also: NORMPDF, NORMINV 

% Reference(s):

%	$Revision: 1.1 $
%	$Id: normcdf.m,v 1.1 2005-05-02 18:15:55 cultpenguin Exp $
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
z = (x-m)./s;	  % if this line causes an error, input arguments do not fit. 

p = (1 + erf(z/sqrt(2)))/2;

z = (s==0);
p((x<m) & z) = 0;

p((x==m)& z) = 0.5;

p((x>m) & z) = 1;

p(isnan(x) | isnan(m) | isnan(s) | (s<0)) = nan;





