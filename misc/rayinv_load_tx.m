% rayinv_load_tx : load travel time formatted rayinv2 file
%
% CALL : 
%   rayinv_load_tx(filename,use_type,xmin,xmax)
%
function D = rayinv_load_tx(filename,use_type,xmin,xmax)
if nargin==0, filename='tx.in'; end
if nargin<2, use_type=[1:1:100];end
if nargin<3, xmin=-1e+9;end
if nargin<4, xmax=1e+9;end


tx=load(filename);
xcoor=tx(:,1);
data=tx(:,2);
unc=tx(:,3);
itype=tx(:,4);

is=0;
for i=1:size(tx,1);
    if (((data(i)==1)|(data(i)==-1))&(unc(i)==0)&(itype(i)==0))
        newshotpoint=1;
        if is>1
            if (xcoor(i)==D(is).shotx)
                newshotpoint=0;
            end
%            j=length(D(is).recx(j));
        end
        if newshotpoint==1;
            is=is+1;
            D(is).isign=data(i);
            D(is).shotx=xcoor(i);
            j=0;
        end
    else
        if length(find(itype(i)==use_type))>0          
            x=xcoor(i);
            if ((x>xmin)&(x<xmax))
                j=j+1;
                D(is).recx(j)=xcoor(i);
%                D(is).recx(j)=D(is).shotx+D(is).isign.*xcoor(i);
                D(is).data(j)=data(i);
                D(is).unc(j)=unc(i);
                D(is).itype(j)=itype(i);
            end
        end
    end
end


for i=1:length(D)
    D(i).n=length(D(i).recx);
end