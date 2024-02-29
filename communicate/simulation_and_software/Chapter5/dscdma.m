% Program 5-6
%
% Simulation program to realize DS-CDMA system
%
% dscdma.m
%
% Programmed by M.Okita and H.Harada
% 

%**************************** Preparation part *****************************

sr   = 256000.0;                                                    % symbol rate
ml   = 2;                                                           % number of modulation levels
br   = sr * ml;                                                     % bit rate
nd   = 100;                                                         % number of symbol
ebn0 = 3;                                                           % Eb/No

%************************** Filter initialization **************************

irfn   = 21;                                                        % number of filter taps
IPOINT =  8;                                                        % number of oversample
alfs   =  0.5;                                                      % roll off factor
[xh]   = hrollfcoef(irfn,IPOINT,sr,alfs,1);                         % T FILTER FUNCTION
[xh2]  = hrollfcoef(irfn,IPOINT,sr,alfs,0);                         % R FILTER FUNCTION

%********************** Spreading code initialization **********************

user  = 1;                                                          % number of users
seq   = 1;                                                          % 1:M-sequence  2:Gold  3:Orthogonal Gold
stage = 3;                                                          % number of stages
ptap1 = [1 3];                                                      % position of taps for 1st
ptap2 = [2 3];                                                      % position of taps for 2nd
regi1 = [1 1 1];                                                    % initial value of register for 1st
regi2 = [1 1 1];                                                    % initial value of register for 2nd

%******************** Generation of the spreading code *********************

switch seq
case 1                                                              % M-sequence
    code = mseq(stage,ptap1,regi1,user);
case 2                                                              % Gold sequence
    m1   = mseq(stage,ptap1,regi1);
    m2   = mseq(stage,ptap2,regi2);
    code = goldseq(m1,m2,user);
case 3                                                              % Orthogonal Gold sequence
    m1   = mseq(stage,ptap1,regi1);
    m2   = mseq(stage,ptap2,regi2);
    code = [goldseq(m1,m2,user),zeros(user,1)];
end
code = code * 2 - 1;
clen = length(code);

%************************** Fading initialization **************************

rfade  = 0;                                                         % Rayleigh fading 0:nothing 1:consider
itau   = [0,8];                                                     % delay time
dlvl1  = [0.0,40.0];                                                % attenuation level
n0     = [6,7];                                                     % number of waves to generate fading
th1    = [0.0,0.0];                                                 % initial Phase of delayed wave
itnd1  = [3001,4004];                                               % set fading counter
now1   = 2;                                                         % number of directwave + delayed wave
tstp   = 1 / sr / IPOINT / clen;                                    % time resolution
fd     = 160;                                                       % doppler frequency [Hz]
flat   = 1;                                                         % flat Rayleigh environment
itndel = nd * IPOINT * clen * 30;                                   % number of fading counter to skip

%**************************** START CALCULATION ****************************

nloop = 1000;                                                       % simulation number of times
noe   = 0;
nod   = 0;

for ii=1:nloop
    
%****************************** Transmitter ********************************
    data = rand(user,nd*ml) > 0.5;
    
    [ich, qch]  = qpskmod(data,user,nd,ml);                         % QPSK modulation
    [ich1,qch1] = spread(ich,qch,code);                             % spreading
    [ich2,qch2] = compoversamp2(ich1,qch1,IPOINT);                  % over sampling
    [ich3,qch3] = compconv2(ich2,qch2,xh);                          % filter
    
    if user == 1                                                    % transmission
        ich4 = ich3;
        qch4 = qch3;
    else
        ich4 = sum(ich3);
        qch4 = sum(qch3);
    end
    
%***************************** Fading channel ******************************
 
    if rfade == 0
        ich5 = ich4;
        qch5 = qch4;
    else
        [ich5,qch5] = sefade(ich4,qch4,itau,dlvl1,th1,n0,itnd1, ... % fading channel
                             now1,length(ich4),tstp,fd,flat);
        itnd1 = itnd1 + itndel;
    end
    
%******************************** Receiver *********************************
  
    spow = sum(rot90(ich3.^2 + qch3.^2)) / nd;                      % attenuation Calculation
    attn = sqrt(0.5 * spow * sr / br * 10^(-ebn0/10));
    
    [ich6,qch6] = comb2(ich5,qch5,attn);                            % Add White Gaussian Noise (AWGN)
    [ich7,qch7] = compconv2(ich6,qch6,xh2);                         % filter
    
    sampl = irfn * IPOINT + 1;
    ich8  = ich7(:,sampl:IPOINT:IPOINT*nd*clen+sampl-1);
    qch8  = qch7(:,sampl:IPOINT:IPOINT*nd*clen+sampl-1);
    
    [ich9 qch9] = despread(ich8,qch8,code);                         % despreading
    
    demodata = qpskdemod(ich9,qch9,user,nd,ml);                     % QPSK demodulation
    
%************************** Bit Error Rate (BER) ***************************

    noe2 = sum(sum(abs(data-demodata)));
    nod2 = user * nd * ml;
    noe  = noe + noe2;
    nod  = nod + nod2;
    
    fprintf('%d\t%e\n',ii,noe2/nod2);
    
end

%******************************** Data file ********************************

ber = noe / nod;
fprintf('%d\t%d\t%d\t%e\n',ebn0,noe,nod,noe/nod);                   % fprintf: built in function
fid = fopen('BER.dat','a');
fprintf(fid,'%d\t%e\t%f\t%f\t\n',ebn0,noe/nod,noe,nod);             % fprintf: built in function
fclose(fid);

%******************************** end of file ********************************