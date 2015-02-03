function d=pdist_tmh(X);

[n,ndim]=size(X);
d=zeros(n,n);
for i=1:n;
    for j=i:n
        dd=sqrt(sum((X(i,:)-X(j,:)).^2));
        %
        %dd=edist(X(i,:),X(j,:));        
        d(i,j)=dd;
        d(j,i)=dd;
    end
end
    