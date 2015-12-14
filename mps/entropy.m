% [H,I]=entropy(P)
function [H,I]=entropy(p)
i=find(p>0);

I=-log2(p(i)); 
P=p(i);

H = sum( P.*I );