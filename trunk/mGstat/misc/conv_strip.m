%conv_strip : as conv but strips leading and trailing tails of convolved
%data
function C=conv_strip(A,B,npad)

nA=length(A);
nB=length(B);

if nargin<3
    npad=ceil(nB/2);
end



if npad>0
    if size(A,1)==1
        padl=ones(1,npad).*A(1);
        padr=ones(1,npad).*A(length(A));
        A=[padl A padr];
    else
        try
            padl=flipud(A(2:(npad+1)));
            padr=flipud(A( (length(A)-npad-1) : (length(A)-1) ));
        catch
            padl=ones(npad,1).*A(1);
            padr=ones(npad,1).*A(length(A));
            %padl=flipud(A(2:(npad+1)));
            %padr=flipud(A( (length(A)-npad-1) : (length(A)-1) ));
        end
        A=[padl;A;padr];
    end
end

C=conv(A,B);

ic1=npad+ceil(nB/2);
ic2=ic1+nA-1;

C=C(ic1:ic2);





