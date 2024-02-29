% Program 6-1
% main.m
%
% Packet communication system
%
% MATLAB version
% Programmed by M.Okita
% Checked by H.Harada
%

clear;

                                                % definition of the global variable
global STANDBY TRANSMIT COLLISION PERMIT
global Srate Plen Ttime Dtime
global Mnum Mplen Mstime Mstate
global Tint Rint
global Spnum Splen Tplen Wtime

STANDBY    = 0;                                 % definition of the fixed number
TRANSMIT   = 1;
COLLISION  = 2;
PERMIT     = 3;

                                                % definition of the protocol
protocol = { 'paloha'	...                     % Pure ALOHA        : pno = 1
             'saloha'	...                     % Slotted ALOHA     : pno = 2
             'npcsma'	...                     % np-CSMA           : pno = 3
             'snpisma'	...                     % Slotted np-ISMA   : pno = 4
           };
                                                % definition of communication channel
brate = 512e3;                                  % bit rate
Srate = 256e3;                                  % symbol rate
Plen  = 128;                                    % length of a packet
Dtime = 0.01;                                   % normalized propagation delay
alfa  = 3;                                      % decline fixed number of propagation loss
sigma = 6;                                      % standard deviation of shadowing [dB]

                                                % definition of the access point
r   = 100;                                      % service area radius [m]
bxy = [0, 0, 5];                                % position of the access point (x,y,z)[m]
tcn = 10;                                       % capture ratio [dB]

                                                % definition of the access terminals
Mnum  = 100;                                    % number of the access terminal
mcn   = 30;                                     % C/N at the access point when transmitted from area edge

                                                % simulation condition
pno     = 1;                                    % protocol number
capture = 0;                                    % capture effect  0:nothing  1:consider
spend   = 10000;                                % number of packets that simulation is finished
outfile = 'test.dat';                           % result output file name

Ttime = Plen / Srate;                           % transmission time of one packet
mpow  = 10^(mcn/10) * sqrt(r^2+bxy(3)^2)^alfa;  % true value of C/N

fid = fopen(outfile,'w');
fprintf(fid,'Protocol                = %d\n',pno);
fprintf(fid,'Capture                 = %d\n',capture);
fprintf(fid,'Normalize_delay_time    = %f\n',Dtime);
fprintf(fid,'Bit_rate           (bps)= %d\n',brate);
fprintf(fid,'Symbol_rate        (sps)= %d\n',Srate);
fprintf(fid,'Length_of_Packet   (sbl)= %d\n',Plen);
fprintf(fid,'Number_of_mobile_station= %d\n',Mnum);
fprintf(fid,'Transmission_power (C/N)= %f\n',mcn);
fprintf(fid,'Capture_ratio       (dB)= %f\n',tcn);
fprintf(fid,'Number_of_Packet        = %d\n',spend);

fprintf('\n********* Simulation Start *********\n\n');
if capture == 0
    fprintf(' %s without capture effect\n\n',char(protocol(pno)));
else
    fprintf(' %s with capture effect\n\n',char(protocol(pno)));
end

mxy  = position(r,Mnum,0);                      % positioning of the access terminals
randn('state',sum(100*clock));                  % resetting of the random table
mrnd = randn(1,Mnum);                           % decision of the shadowing

for G=[0.1:0.1:1,1.2:0.2:2]                     % offered traffic
    if G >= Mnum
        break
    end
    
    Tint  = -Ttime / log(1-G/Mnum);             % expectation value of the packet generation interval
    Rint  = Tint;                               % expectation value of the packet resending interval
    Spnum = 0;
    Splen = 0;
    Tplen = 0;
    Wtime = 0;
    
    now_time = feval(char(protocol(pno)),-1);   % initialize of the access terminals
    
    while 1
        next_time = feval(char(protocol(pno)),now_time);
        if Spnum >= spend
            break
        end
        idx = find(Mstate==TRANSMIT | Mstate==COLLISION);
        if capture == 0                         % without capture effect
            if length(idx) > 1
                Mstate(idx) = COLLISION;        % collision occurs
            end
        else                                    % with capture effect
            if length(idx) > 1
                dxy  = distance(bxy,mxy(idx,:),1);                      % calculation of the distance
                pow  = mpow * dxy.^-alfa .* 10.^(sigma/10*mrnd(idx));   % calculation of received power
                [maxp no] = max(pow);
                if Mstate(idx(no)) == TRANSMIT
                    if length(idx) == 1
                        cn = 10 * log10(maxp);
                    else
                        cn = 10 * log10(maxp/(sum(pow)-maxp+1));
                    end
                    Mstate(idx) = COLLISION;
                    if cn >= tcn                    % received power larger than capture ratio
                        Mstate(idx(no)) = TRANSMIT; % transmitting success
                    end
                else
                    Mstate(idx) = COLLISION;
                end
            end
        end
        now_time = next_time;                       % time is advanced until the next state change time
    end
    
    traffic = Tplen / Srate / now_time;             % calculation of the traffic
    ts      = theorys(pno,traffic,Dtime);           % calculation of the theory value of the throughput
    fprintf(fid,'%f\t%f\t%f\t%f\t%f\t%f\t%f\n',G,now_time   ...
               ,Splen/Srate,Tplen/Srate,Wtime,Tint,Rint);
    fprintf('G=%f\tS=%f\tTS=%f\n',traffic,Splen/Srate/now_time,ts);
end
fprintf('\n********** Simulation End **********\n\n');
fclose(fid);
graph(outfile);

%%%%%%%%%%%%%%%%%%%%%% end of file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
