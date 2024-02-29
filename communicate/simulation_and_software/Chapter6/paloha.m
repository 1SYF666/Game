% Program 6-6
% paloha.m
%
% Pure ALOHA System
%
% Input argument
%   now_time  : now time   but, now_time<0 initializes the access terminals
%
% Output argument
%   next_time : next state change time
%
% Programmed by M.Okita
% Checked by H.Harada
%

function [next_time] = paloha(now_time)

global STANDBY TRANSMIT COLLISION                   % definition of the global variable
global Srate Plen
global Mnum Mplen Mstate
global Tint Rint
global Spnum Splen Tplen Wtime

persistent mgtime mtime                             % definition of the static variable

if now_time < 0                                     % initialize access terminals
    rand('state',sum(100*clock));                   % resetting of the random table
    mgtime        = -Tint * log(1-rand(1,Mnum));    % packet generation time
    mtime         = mgtime;                         % packet transmitting time
    Mstate        = zeros(1,Mnum);
    Mplen(1:Mnum) = Plen;                           % packet length
    next_time     = min(mtime);
    return
end

idx = find(mtime==now_time & Mstate==TRANSMIT);     % finding of the terminal which transmission succeeded
if length(idx) > 0
    Spnum       = Spnum + 1;
    Splen       = Splen + Mplen(idx);
    Wtime       = Wtime + now_time - mgtime(idx);
    Mstate(idx) = STANDBY;
    mgtime(idx) = now_time - Tint * log(1-rand);    % next packet generation time
    mtime(idx)  = mgtime(idx);                      % next packet transmitting time
end

idx = find(mtime==now_time & Mstate==COLLISION);    % finding of the terminal which transmission failed
if length(idx) > 0
    Mstate(idx) = STANDBY;
    mtime(idx)  = now_time - Rint * log(1-rand(1,length(idx))); % resending time
end

idx = find(mtime==now_time);                        % finding of the terminal which transmission start
if length(idx) > 0
    Mstate(idx) = TRANSMIT;
    mtime(idx)  = now_time + Mplen(idx) / Srate;    % end time of transmitting
    Tplen       = Tplen + sum(Mplen(idx));
end

next_time = min(mtime);                             % next state change time

%%%%%%%%%%%%%%%%%%%%%% end of file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
