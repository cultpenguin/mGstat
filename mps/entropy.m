function [H,I]=entropy(p)
i=p>0;

I=-log2(p(i)); 
P=p(i);

H = sum( P.*I );