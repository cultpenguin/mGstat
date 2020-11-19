% mps_get_realization_from_template: Sample from training image using Direct Sampling 
%
% Call:
%   [sim_val,C,ix_ti_min,iy_ti_min,DIS_MIN]=mps_get_realization_from_template(TI,V,L,options)
%
%  % optional inputs
%    options.n_max_ite=1e+9; % Max number of iterations in 
%    options.min_dist=0; % Stop scanning TI when distance is below options.min_dist.
%    
%    options.distance_measure=1; % DISCRETE distance (for discrete TIs)
%    options.distance_measure=2; % EUCLIDEAN distance (for continous TIs)
%
% See also: mps_enesim.m
%

function [sim_val,C,ix_ti_min,iy_ti_min,DIS_MIN]=mps_get_realization_from_template(TI,V,L,options)

if ~isfield(options,'n_max_ite')
    options.n_max_ite=1e+9;
end

if ~isfield(options,'min_dist')
   options.min_dist=0;
end

if ~isfield(options,'distance_w')
   options.distance_w=100;
end



if ~isfield(options,'distance_measure')
   options.distance_measure=1; % DISCRETE
   %options.distance_measure=2; % EUCLIDEAN
end

C=0;
N_TI=prod(size(TI.D));
N_COND=length(V);

% random start point
ix_1=ceil(rand(1)*TI.nx);
iy_1=ceil(rand(1)*TI.ny);

% create arrays of x and y
ix_arr=circshift(1:1:TI.nx,ix_1,2);
iy_arr=circshift(1:1:TI.ny,iy_1,2);


% LOOP OVER TI,

ij=0;
DIS_MIN=1e+5;

break_flag=0; % needed to break out of double loop

% Distance to conditioning events;
h=sqrt(sum(L.^2,2));
          

for iy_ti=iy_arr;for ix_ti=ix_arr;
    
    ij=ij+1;
    
    %if ij==1;
    %    disp(sprintf('start-point: ix,iy=%d,%d',ix_ti,iy_ti))
    %end
    
    if N_COND==0;
      DIS_MIN=0;
      iy_ti_min=iy_ti;
      ix_ti_min=ix_ti;
      break_flag=1;break
    else
      % GET INDEX CENTER INDEX IN TI
      
      % COMPUTE DISTANCE
      if options.distance_measure==1;
          % DISCRETE
          DIS=0;
          D=zeros(size(L,1),1);
          for k=1:size(L,1);
              iy_test=L(k,1)+iy_ti;
              ix_test=L(k,2)+ix_ti;
              
              
              if ((iy_test>0)&&(iy_test<=TI.ny)&&(ix_test>0)&(ix_test<=TI.nx))
                  if TI.D(iy_test,ix_test)==V(k);
                      DIS=DIS+0;
                      D(k)=0;
                  else
                      %% Weighted distance perhaps
                      D(k)=1;
                      DIS=DIS+1;
                  end
              else
                  D(k)=1;
                  DIS=DIS+1;
              end
          end
          
          % weighted distance (Mariethoz et al., 2010)
          hw=h.^(-options.distance_w);
          DIS=sum(D.*hw)/sum(hw);
          
          
      elseif options.distance_measure==2;
          % CONTINIOUS / EUCLIDEAN
          DIS_all=zeros(size(L,1),1);
          
          for k=1:size(L,1);
              iy_test=L(k,1)+iy_ti;
              ix_test=L(k,2)+ix_ti;
              
              
              if ((iy_test>0)&&(iy_test<=TI.ny)&&(ix_test>0)&(ix_test<=TI.nx))
                  DIS_all(k)= (TI.D(iy_test,ix_test)-V(k));                  
              else
                  DIS_all(k)=100;options.min_dist;                  
              end
          end
          DIS = sqrt(sum(DIS_all.^2));
      else
          %%
      end
      
      
      
      
      %% keep track of the pattern with the smallesty dist so far
      if DIS<DIS_MIN
        DIS_MIN=DIS;
        iy_ti_min=iy_ti;
        ix_ti_min=ix_ti;
        %disp(sprintf('id=%04d DIS_MIN=%g',ij,DIS_MIN))
      end
      
      % store how many iteration in the TI is performed
      %options.C(iy,ix)=ij;
      
      C=ij;
      
      %% STOP, if perfect match has been reached      
      if DIS<=options.min_dist;
        iy_ti_min=iy_ti;
        ix_ti_min=ix_ti;
        break_flag=1;break
      end
      
      %% STOP, if maximum number of allowed iterations have been reached
      if ij>=options.n_max_ite;
        break_flag=1;break;
      end
      
      
    end
    %end;
  end;
  if break_flag==1;
    break;
  end;
end

%disp(sprintf('BREAK id=%04d DIS_MIN=%g',ij,DIS_MIN))
% UPDATE SIM GRID WITH CONDITIONAL VALAUE
sim_val=TI.D(iy_ti_min,ix_ti_min);
