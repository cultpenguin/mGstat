% mps_get_conditional_from_template: Get conditional distritution
%
% Call:
%    [C_PDF,TI]=mps_get_conditional_from_template(TI,V,L)
%
%    V : [d1; d2]
%    L : [iy1, ix1; iy2, ix2]
%    TI: training image struct
%       TI.x, TI.y, TI.D
%function [C_PDF,N_PDF,TI]=mps_get_conditional_from_template(TI,V,L,COUNT_MAX,N_MAX_ITE)
function [C_PDF,N_PDF,TI]=mps_get_conditional_from_template(TI,V,L,options)

if nargin<4
    options.null='';
end

if ~isfield(options,'n_max_condpd')
    options.n_max_condpd=1e+9;
end

if ~isfield(options,'n_max_ite')
    options.n_max_ite=1e+9;
end

N_TI=prod(size(TI.D));
N_COND=length(V);
%if N_COND>3, keyboard;end
if ~isfield(TI,'N_CAT');TI.N_CAT=length(unique(TI.D));end

j_start=ceil(rand(1)*N_TI);
j_arr(1:(N_TI-j_start+1))=j_start:1:N_TI;
j_arr((N_TI-j_start+2):N_TI)=1:(j_start-1);

ij=0;
DIS_MIN=1e+5;



break_flag=0;
count=0;

%% REMEMMBER TO RANDOMIZE START LOCATION

% random start point
ix_1=ceil(rand(1)*TI.nx);
iy_1=ceil(rand(1)*TI.ny);

% create arrays of x and y
ix_arr=circshift(1:1:TI.nx,ix_1,2);
iy_arr=circshift(1:1:TI.ny,iy_1,2);


[ixx,iyy]=meshgrid(ix_arr,iy_arr);
ixy_path=[ixx(:) iyy(:)];
%% SHUFFLE PATH IN TI
doShuffle=1;
if doShuffle==1;
    col=[ixy_path,rand(TI.nx*TI.ny,1)];
    col=sortrows(col,3);
    ixy_path=col(:,1:2);
end

DIS_MIN=1e+5;


C_PDF=zeros(1,TI.N_CAT);
C_PDF_SOFAR=C_PDF;
        
options.n_max_ite=min([options.n_max_ite TI.nx*TI.ny]);   




for j=1:(TI.nx*TI.ny);
    ix_ti=ixy_path(j,1);
    iy_ti=ixy_path(j,2);
%for ix_ti=ix_arr;1:TI.nx;
%    for iy_ti=iy_arr;1:TI.ny;
%        j=j+1;
        %disp(sprintf('[ix,iy]=[%d,%d] j=%4d',ix_ti,iy_ti,j))
        if N_COND==0;
            iy_ti_min=iy_ti;
            ix_ti_min=ix_ti;
            V_cond=TI.D(iy_ti,ix_ti);
            C_PDF(V_cond+1)=C_PDF(V_cond+1)+1;
            count=count+1;
        else
            
            %if length(V)>2;   keyboard;end
            % COMPUTE DISTANCE
            DIS=0;
            for k=1:size(L,1);
                iy_test=L(k,1)+iy_ti;
                ix_test=L(k,2)+ix_ti;
                
                if ((iy_test>0)&&(iy_test<=TI.ny)&&(ix_test>0)&(ix_test<=TI.nx))
                    if TI.D(iy_test,ix_test)==V(k);
                        DIS=DIS+0;
                    else
                        DIS=DIS+1;
                    end
                else
                    DIS=DIS+1;
                end
            end    
            if DIS==0
                % perfect match
                count=count+1;
                V_cond=TI.D(iy_ti,ix_ti);
                C_PDF(V_cond+1)=C_PDF(V_cond+1)+1;
            else
                if DIS<DIS_MIN
                    % update min distance
                    V_cond=TI.D(iy_ti,ix_ti);
                    C_PDF_SOFAR=zeros(1,TI.N_CAT);
                    C_PDF_SOFAR(V_cond+1)=C_PDF_SOFAR(V_cond+1)+1;
                    DIS_MIN=DIS;
                end

            end
                
            
        end
        
        if j>=options.n_max_ite;
            % max allowed number of iterations reached
            
            if (sum(C_PDF))==0
                C_PDF=C_PDF_SOFAR;
            end
            
            break_flag=1;
            break;
        end
        
        
        if count>=options.n_max_condpd;
            break_flag=1;
            break;
        end
        
    %end;
    %if (break_flag==1);break;end
end

%end

% prior distribution of counts... C_pdf will never be empty..
%C_PDF_prior=ones(1,TI.N_CAT)./11;
%C_PDF_prior=[0 0]/10;
%C_PDF=C_PDF+C_PDF_prior;

% normalize
N_PDF=sum(C_PDF);
C_PDF=C_PDF./N_PDF;

