function colorbar_log10(Ticks)


cb=colorbar;
if nargin>0
    set(cb,'Ticks',log10(Ticks))
end
T=get(cb,'Ticks');
for it=1:length(T);TL{it}=sprintf('%3.1f',10.^T(it));end
set(cb,'TickLabels',TL)
        