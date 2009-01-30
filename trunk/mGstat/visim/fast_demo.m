% fast_demo : demonstration of ways to call FAST from Matlab

if ~exist('V')
    % Make reference model, m_ref
    x=[0:.25:10];
    y=[0:.25:20];
    z=0;
    V=visim_init(x,y,z);
    V.nsim=1;
    V=visim(V);
    visim_clean; % Clean up after visim;
    v_ref=V.D';
end
figure(1);
imagesc(x,y,v_ref);axis image;


% EX 1 : One source
Sources=[1 8];
t=fast_fd_2d(x,y,v_ref,Sources);
figure(2);
contourf(x,y,t);
hold on; plot(Sources(1),Sources(2),'k*');hold off
set(gca,'ydir','revers');axis image
title('One Source')

% EX 2 : 9 sources
Sources2(:,2)=1:1:9;
Sources2(:,1)=1;
t=fast_fd_2d(x,y,v_ref,Sources2);
figure(3);
for i=1:9
    subplot(3,3,i);
    contourf(x,y,t(:,:,i));set(gca,'ydir','revers');axis image
hold on; plot(Sources2(i,1),Sources2(i,2),'k*');hold off
end
suptitle('9 Sources')

% EX 3 : Calculate only the firstarrival times between sourced and receievers
Sources3(:,2)=1:1:19;
Sources3(:,1)=1;
Rec3(:,2)=1:1:19;
Rec3(:,1)=9;
t=fast_fd_2d_traveltime(x,y,v_ref,Sources3,Rec3)
figure(4);
plot(t);
xlabel('raynumber');ylabel('travel time')
title('First arrival time calculation')

% Ex 4 : First arrival times for all sets of sources and receivers
t=fast_fd_2d_traveltime_matrix(x,y,v_ref,Sources3,Rec3)
figure(5);
plot(t);
xlabel('raynumber');ylabel('travel time')
title('First arrival time calculation')

% CLEAN UP AFTER FAST
fast_fd_clean;