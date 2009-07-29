%conv2_strip : as conv2 but strips leading and trailing tails of convolved
%data
function C=conv_strip2(A,B,npad)

[a1,a2]=size(A);
[b1,b2]=size(B);

C=conv2(A,B);
[c1,c2]=size(C);


ic1=[ ceil(b1/2):1:(ceil(b1/2)+a1-1) ];
ic2=[ ceil(b2/2):1:(ceil(b2/2)+a2-1) ];

C=C(ic1,ic2);




