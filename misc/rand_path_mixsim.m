function [iy,ix,sim,list1_2D]=rand_path_mixsim(sim,YY,XX,list1_2D,iy,ix)

% field: A 2D grid with NaN in the positions to be simualted.
% Ny: Number of elements in sim along dim1
% Nx: Number of elements in sim along dim2

if nargin<5
    ix=1;
    iy=1;
end




%list1=list1(isnan(sim(Y(1):Y(end),X(1):X(end))));

% list1_2D=reshape(list1,Ny,Nx);
% list1_2D(~isnan(sim))=NaN;
%list_tmp=[]; % Not empthy
%Nseqsim=length(list1);

if nargin<5
    i=1;
else
    i=2;
end
    %figure
%for i=1:Nseqsim
    
    % Chose a random direction (1 or 2).
    dir=ceil(rand*2);
    list_tmp1_xdir=list1_2D(iy,~isnan(list1_2D(iy,:)) & isnan(sum(list1_2D,1)));
    list_tmp1_ydir=list1_2D(~isnan(list1_2D(:,ix)) & isnan(sum(list1_2D,2)),ix);

    if i==1
        % Simulate in a completely random position:
        n=rand_list(list1_2D(:));
        while isnan(n) % Only in case of conditional data
            n=rand_list(list1_2D(:));
        end
        iy=YY(n);
        ix=XX(n);
        pos=[ix iy];

%         % Mark which nodes that have been simulated:
%         list1_2D(iy,ix)=NaN;
        
        % Check for "crossing" with previous simulations and simulate if
        % exist:
    elseif ~isempty(list_tmp1_ydir) % Looking up/down. Re-use x-direction:
        
        % Simulate the "crossing position":
        n=rand_list(list_tmp1_ydir);
        iy=YY(n);
        pos=[ix iy];
        
%         % Mark which nodes that have been simulated:
%         list1_2D(iy,ix)=NaN;
    elseif ~isempty(list_tmp1_xdir) % Looking left/right, Re-use y-direction 
        
        % Simulate the "crossing position":
        n=rand_list(list_tmp1_xdir);
        ix=XX(n);
        pos=[ix iy];
        
    elseif dir==1 % Looking along y-direction
        % Locations where both a not NaN:
        list_tmp=list1_2D(~isnan(list1_2D(:,ix)) & ~isnan(sum(list1_2D,2)),ix);
        
        try
            list_tmp=list1_2D(iy,~isnan(list1_2D(iy,:)) & ~isnan(sum(list1_2D,1)));
            n=rand_list(list_tmp);
            ix=XX(n);
            list_tmp=list1_2D(~isnan(list1_2D(:,ix)),ix);
        catch
            % All positions in this column have been
            % simualted -> change direction, which happens
            % after the next 'catch' eight lines down.
        end
        
        % Simulate a "crossing position":
        try
            n=rand_list(list_tmp);
            iy=YY(n);
            pos=[ix iy];
        catch
            list_tmp=list1_2D(iy,~isnan(list1_2D(iy,:)) & ~isnan(sum(list1_2D,1)));
            n=rand_list(list_tmp);
            ix=XX(n);
            pos=[ix iy];
        end
        
    elseif dir==2 % Looking along x-direction
        list_tmp=list1_2D(iy,~isnan(list1_2D(iy,:)) & ~isnan(sum(list1_2D,1)));
        
        if isempty(list_tmp) % Looking along horizontal for another y-value:
            try
                list_tmp=list1_2D(~isnan(list1_2D(:,ix)) & ~isnan(sum(list1_2D,2)),ix);
                n=rand_list(list_tmp);
                iy=YY(n);
                list_tmp=list1_2D(iy,~isnan(list1_2D(iy,:)));
            catch
                % All positions in this row have been simualted
                % -> change direction, which happens
                % after the next 'catch' eight lines down.
            end
        end
        
        % Simulate a "crossing position":
        try
            n=rand_list(list_tmp);
            ix=XX(n);
            pos=[ix iy];
        catch % Change direction
            list_tmp=list1_2D(~isnan(list1_2D(:,ix)) & ~isnan(sum(list1_2D,2)),ix);
            n=rand_list(list_tmp);
            iy=YY(n);
            pos=[ix iy];
        end
        
        
    end
    % Mark which nodes that have been simulated:
    list1_2D(iy,ix)=NaN;
    
    
    sim(iy,ix)=1;
 
end