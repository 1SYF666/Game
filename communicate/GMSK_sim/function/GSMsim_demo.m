function [ ] = GSMsim_demo(LOOPS,Lh)
%GSMsim_DEMO:
%   This function demonstrates the function of the GSMsim 
%   package. Use this file as a starting point for building 
%   your own simulations.
%
% SYNTAX: GSMsim_demo(LOOPS,Lh)
%
% INPUT: LOOPS: The number of loops that the demo is to run, 
%          each loop contain 10 burst.
%        Lh:    The length of the channel impulse response 
%               minus one.
%
% OUTPUT: None, but on screen.
%
% WARNINGS: Do not expect this example to be more than exactly that, 
%           an example. This example is NOT scientifically correct.
%
% AUTHOR:  Jan H. Mikkelsen / Arne Norre Ekstrøm
% EMAIL:   hmi@kom.auc.dk / aneks@kom.auc.dk
%
% $Id: GSMsim_demo.m,v 1.5 1998/10/01 10:19:04 hmi Exp $
%
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%
tTotal = clock;
%
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%
% THERE HAS NOT BEEN ANY ERRORS, YET...
%
B_ERRS = 0;
%
% gsm_set MUST BE RUN PRIOR TO ANY SIMULATIONS, SINCE IT DOES SETUP 
% OF VALUES NEEDED FOR OPERATION OF THE PACKAGE.
gsm_set;
%
% PREPARE THE TABLES NEEDED BY THE VITERBI ALGORITHM.
[ SYMBOLS , PREVIOUS , NEXT , START , STOPS ] = viterbi_init(Lh);
%
% THIS IS THE SIMULATION LOOP, OVER THE BURSTS
A_Loop = 0;
for Loop = 1 : LOOPS
    %
    % GET THE TIME
    t0 = clock;
    %
    for n = 1:10
    % GET DATA FOR A BURST
    tx_data = data_gen(INIT_L);
    %
    % THIS IS ALL THAT IS NEEDED FOR MODULATING A GSM BURST, IN THE FORMAT 
    % USED BY GSMsim. THE CALL INCLUDES GENERATION AND MODULATION OF DATA.
    % [ burst , I , Q ] = gsm_mod(tx_data,INIT_L,OSR,TRAINING);
    [ burst , I , Q ] = gsm_mod(Tb,OSR,BT,tx_data,TRAINING);
    
    %
    % LETS POINT OUT HERE THAT THE CHANNEL SELECTION, NOTE, THAT THE CHANNEL 
    % INCLUDES TRANSMITTER FRONT-END, AND RECEIVER FRONT-END. THE CHANNEL 
    % SELECTION IS BY NATURE INCLUDED IN THE RECEIVER FRONT-END.
    %
    % THE CHANNEL SIMULATOR INCLUDED IN THE GSMsim PACKAGE ONLY ADD 
    % NOISE, AND SHOULD _NOT_ BE USED FOR SCIENTIFIC PURPOSES.
    % r = channel_simulator([I Q],OSR);
    r = I + 1i*Q;
    
    %
    % RUN THE MATCHED FILTER, IT IS RESPONSIBLE FOR FILTERING SYNCHRONIZATION 
    % AND RETRIEVAL OF THE CHANNEL CHARACTERISTICS.
    [ Y , Rhh ] = mafi(r,Lh,T_SEQ,OSR);
    figure;subplot(2,1,1);plot(real(Y));title("real of mafi output ");
    subplot(2,1,2);plot(imag(Y));title("imag of mafi output ");

    %
    % HAVING PREPARED THE PRECALCULATABLE PART OF THE VITERBI 
    % ALGORITHM, IT IS CALLED PASSING THE CHANNEL INFORMATION ALONG WITH 
    % THE RECEIVED SIGNAL, AND THE ESTIMATED AUTOCORRELATION FUNCTION.
    rx_burst = viterbi_detector(SYMBOLS,NEXT,PREVIOUS,START,STOPS,Y,Rhh);
    
    %
    % RUN THE DEMUX
    rx_data = DeMUX(rx_burst);
    %
    % COUNT THE ERRORS
    B_ERRS = B_ERRS + sum(xor(tx_data,rx_data));
    %
    figure;plot(rx_data);hold on;plot(0.95*tx_data);title("解调输出与调制前对比图");


    end
%
% FIND THE LOOPTIME
elapsed = etime(clock,t0);
%
% FIND AVERAGE LOOP TIME
A_Loop=(A_Loop+elapsed)/2;
%
% FIND REMAINING TIME
Remain = (LOOPS-Loop)*A_Loop;
%
% UPDATE THE DISPLAY
fprintf(1,'\r');
fprintf(1,'Loop: %d, Average Loop Time: %2.1f seconds',Loop,A_Loop);
fprintf(1,',Remaining: %2.1f seconds ',Remain);
end

Ttime = etime(clock,tTotal);
BURSTS = LOOPS*10;

fprintf(1,'\n%d Bursts processed in %6.1f Seconds.\n',BURSTS,Ttime);
fprintf(1,'Used %2.1f seconds per burst\n',Ttime/BURSTS);
fprintf(1,'There were %d Bit-Errors\n',B_ERRS);
BER = (B_ERRS * 100)/(BURSTS*148);
fprintf(1,'This equals %2.1f Percent of the checked bits.\n',BER);
end