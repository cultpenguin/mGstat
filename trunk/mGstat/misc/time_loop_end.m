function [t_end_txt,t_left_seconds]=time_loop_end(t0,i,n,datestr_format);
% time_left : computes and displays an estimate time when a loop is finished
%
% Call : 
%   [t_end_txt,t_left_seconds]=time_loop_end(t0,i,n,datestr_format);
%     t0 : initial time, from t0=now;
%     i : current iteration number
%     N : number of iterations
%     datestr_format : format for dispplaying end time, def='dd/mm/yyyy HH:MM:SS'
%
% Example
%    N=100;
%    t0=now;
%    for i=1:N
%       inv(rand(2000));
%       time_loop_end(t0,i,N);
%    end
%
%
if nargin<1
    disp('You need to specify a start time, t0=now;')
end

if nargin<4 
    datestr_format='dd/mm/yyyy HH:MM:SS';
end

% time left
tnow=now;

t_elapsed=(tnow-t0);
t_per_iteration=t_elapsed/i;
n_ite_left=n-i;

t_left = n_ite_left*t_per_iteration;

t_end= tnow+n_ite_left*t_per_iteration;


t_per_iteration_seconds=t_per_iteration*24*3600;
t_left_seconds=t_left*24*3600;

t_end_txt=sprintf('end:%s sec-per-ite = %4.1f s',datestr(t_end,datestr_format),t_per_iteration_seconds);
if nargout==0
    disp(t_end_txt)
end
            