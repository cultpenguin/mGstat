% rayinv_load_tx
% function rayinv_load_tx(file)
%if nargin==0
%    filename='tx.in';
%end
%if nargin<2
%    use_type=[1:1:100];
%end

filename='tx.in';
use_type=[1,2,3,10];



tx=load(filename);
xcoor=tx(:,1);
data=tx(:,2);
unc=tx(:,3);
itype=tx(:,4);

is=0;
for i=1:size(tx,1);
    if ((data(i)==1)|(data(i)==-1))
        is=is+1;
        D(is).isign=data(i);
        D(is).shotx=xcoor(i);
        j=0;
    else
        if length(find(itype(i)==use_type))>0
            j=j+1;
            D(is).drecx(j)=xcoor(i);
            D(is).recx(j)=D(is).shotx+D(is).isign.*xcoor(i);
            D(is).data(j)=xcoor(i);
            D(is).unc(j)=xcoor(i);
            D(is).itype(j)=itype(i);
        end
    end
end