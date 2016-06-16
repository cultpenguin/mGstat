% checkboard
%
% Call:
%   C = checkboard(n)
%
% from: http://matlabtricks.com/post-31/three-ways-to-generate-a-checkerboard-matrix
function C = checkboard(n)


method=2;

if method==1;
    % generate the parity map
    p = mod(1 :n, 2);
    % pass the xor operator, a column and a row vector
    % containing the parity data
    C = bsxfun(@xor, p', p);
elseif method==2
    l = 1;
    m = n;
    %n = 10;
    
    C = zeros(n,m,l);
    for k = 1:l
        for j = 1:m
            for i = 1:n
                C(i,j,k) = ceil(mod( (i-j-k) ,2));
            end
        end
    end
    
    %% if 'd' ~= 1 ,, INTERP
end