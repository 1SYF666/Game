% Program 6-10
% snpisma.m
%
% Slotted non-persistent ISMA System
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

function [next_time] = snpisma(now_time)

global STANDBY TRANSMIT COLLISION PERMIT                % definition of the global variable
global Srate Plen Dtime
global Mnum Mplen Mstime Mstate
global Tint Rint
global Spnum Splen Tplen Wtime

persistent mgtime mtime slot                            % definition of the static variable

if now_time < 0                                         % initialize access terminals
    rand('state',sum(100*clock));                       % resetting of the random table
    mgtime        = -Tint * log(1-rand(1,Mnum));        % packet generation time
    Mstime        = zeros(1,Mnum) - inf;                % packet transmitting time
    mtime         = mgtime;                             % inhibit sensing time
    Mstate        = zeros(1,Mnum);
    Mplen(1:Mnum) = Plen;                               % packet length
    next_time     = min(mtime);                         % state change time
    slot          = Plen / Srate * Dtime;               % idle slot length
    return
end

idx = find(mtime==now_time & Mstate==TRANSMIT);         % finding of the terminal which transmission succeeded
if length(idx) > 0
    Spnum       = Spnum + 1;
    Splen       = Splen + Mplen(idx);
    Wtime       = Wtime + now_time - mgtime(idx);
    Mstate(idx) = STANDBY;
    mgtime(idx) = now_time - Tint * log(1-rand);        % next packet generation time
    mtime(idx)  = mgtime(idx);
end

idx = find(mtime==now_time & Mstate==COLLISION);        % finding of the terminal which transmission failed
if length(idx) > 0
    Mstate(idx) = STANDBY;
    mtime(idx)  = now_time - Rint * log(1-rand(1,length(idx))); % resending time
end

idx = find(mtime==now_time & Mstate==STANDBY);          % finding of the terminal which inhibit sensing
if length(idx) > 0
    Tplen = Tplen + sum(Mplen(idx));
    for ii=1:length(idx)
        jj = idx(ii);
        if inhibitsense(jj,now_time) == 0               % channel is idle
            Mstate(jj) = PERMIT;
            [temp1 kk] = max(Mstime);                   % calculation of the transmitting start time slot
            if temp1 < 0
                mtime(jj) = ceil(now_time/slot) * slot;
            else
                temp1 = temp1 + Mplen(kk) / Srate;
                temp2 = now_time - temp1;
                if temp2 < 0
                    mtime(jj) = temp1 + slot;
                else
                    mtime(jj) = temp1 + ceil(temp2/slot) * slot;
                end
            end
        else                                            % channel is busy
            mtime(jj) = now_time - Rint * log(1-rand);  % waiting time
        end
    end
end

idx = find(mtime==now_time & Mstate==PERMIT);           % finding the terminal which transmission start
if length(idx) > 0
    Mstate(idx) = TRANSMIT;
    Mstime(idx) = now_time;
    mtime(idx)  = now_time + Mplen(idx) / Srate;        % end time of transmitting
end

next_time = min(mtime);                                 % next state change time

%%%%%%%%%%%%%%%%%%%%%% end of file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
