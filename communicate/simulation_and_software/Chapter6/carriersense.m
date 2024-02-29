% Program 6-9
% carriersense.m
%
% The function of the carrier sense
%
% Input arguments
%   no       : terminal which carrier sensing
%   now_time : now time
%
% Output argument
%   result   : 0: idle  1:busy
%
% Programmed by M.Okita
% Checked by H.Harada
%

function [result] = carriersense(no,now_time)

global Mnum Mstime Ttime Dtime                                          % definition of the global variable

delay = Dtime * Ttime;                                                  % calculation of the delay time

idx = find((Mstime+delay)<=now_time & now_time<=(Mstime+delay+Ttime));  % carrier sense
if length(idx) > 0                                                      % carrier is detected
    result = 1;                                                         % channel is busy
else                                                                    % charier canÅft be detected
    result = 0;                                                         % channel is idle
end

%%%%%%%%%%%%%%%%%%%%%% end of file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
