% Program 6-11
% inhibitsense.m
%
% The function of the inhibit sense
%
% Input arguments
%   no       : terminal which inhibit sensing
%   now_time : now time
%
% Output argument
%   inhibit  : 0: idle   1: busy
%
% Programmed by M.Okita
% Checked by H.Harada
%

function [inhibit] = inhibitsense(no,now_time)

global Mnum Mstime Ttime Dtime          % definition of the global variable

delay   = Dtime * Ttime;                % calculation of delay time
inhibit = 0;

idx = find((Mstime+delay)<=now_time & now_time<=(Mstime+delay+Ttime));  % inhibit sensing
if length(idx) > 0
    idx = find(idx~=no);                % except itself
    if length(idx) > 0                  % inhibit is detected
        inhibit = 1;                    % channel is busy
    end
end

%%%%%%%%%%%%%%%%%%%%%% end of file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
