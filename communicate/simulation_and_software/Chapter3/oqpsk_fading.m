% Program 3-12
% oqpsk_fading.m
%
% Simulation program to realize OQPSK transmission system
% (under one path fading)
%
% Programmed by H.Harada and T.Yamamura
%

%******************** Preparation part *************************************

sr=256000.0; % Symbol rate
ml=2;        % ml:Number of modulation levels (BPSK:ml=1, QPSK:ml=2, 16QAM:ml=4)
br=sr .* ml; % Bit rate
nd = 1000;    % Number of symbols that simulates in each loop 
ebn0=10;     % Eb/N0
IPOINT=8;    % Number of oversamples

%************************* Filter initialization ***************************

irfn=21;                  % Number of taps
alfs=0.5;                 % Rolloff factor
[xh] = hrollfcoef(irfn,IPOINT,sr,alfs,1);   %Transmitter filter coefficients 
[xh2] = hrollfcoef(irfn,IPOINT,sr,alfs,0);  %Receiver filter coefficients 

%******************* Fading initialization ********************
% If you use fading function "sefade", you can initialize all of parameters.
% Otherwise you can comment out the following initialization.
% The detailed explanation of all of valiables are mentioned in Program 2-8.

% Time resolution

tstp=1/sr/IPOINT; 

% Arrival time for each multipath normalized by tstp
% If you would like to simulate under one path fading model, you have only to set 
% direct wave.

itau = [0];

% Mean power for each multipath normalized by direct wave.
% If you would like to simulate under one path fading model, you have only to set 
% direct wave.
dlvl = [0];

% Number of waves to generate fading for each multipath.
% In normal case, more than six waves are needed to generate Rayleigh fading
n0=[6];

% Initial Phase of delayed wave
% In this simulation four-path Rayleigh fading are considered.
th1=[0.0];

% Number of fading counter to skip 
itnd0=nd*IPOINT;

% Initial value of fading counter
% In this simulation one-path Rayleigh fading are considered.
% Therefore one fading counter are needed.
  
itnd1=[1000];

% Number of directwave + Number of delayed wave
% In this simulation one-path Rayleigh fading are considered
now1=1;        

% Maximum Doppler frequency [Hz]
% You can insert your favorite value
fd=160;       

% You can decide two mode to simulate fading by changing the variable flat
% flat     : flat fading or not 
% (1->flat (only amplitude is fluctuated),0->nomal(phase and amplitude are fluctutated)
flat =1;

%******************** START CALCULATION *************************************

nloop=200;  % Number of simulation loops

noe = 0;    % Number of error data
nod = 0;    % Number of transmitted data

for iii=1:nloop
    
%*************************** Data generation ********************************  

    data1=rand(1,nd*ml)>0.5;  % rand: built in function

%*************************** OQPSK Modulation ********************************  
 
    [ich,qch]=qpskmod(data1,1,nd,ml);
    [ich1,qch1]=compoversamp(ich,qch,length(ich),IPOINT);
    ich21=[ich1 zeros(1,IPOINT/2)];
    qch21=[zeros(1,IPOINT/2) qch1];
    [ich2, qch2]=compconv(ich21,qch21,xh); 
 
%**************************** Attenuation Calculation ***********************

    spow=sum(ich2.*ich2+qch2.*qch2)/nd;  % sum: built in function
    attn=0.5*spow*sr/br*10.^(-ebn0/10);
    attn=sqrt(attn);  % sqrt: built in function
   
%********************** Fading channel **********************
 
  % Generated data are fed into a fading simulator
    [ifade,qfade]=sefade(ich2,qch2,itau,dlvl,th1,n0,itnd1,now1,length(ich1),tstp,fd,flat);
  
  % Updata fading counter
    itnd1 = itnd1+ itnd0;

%********************* Add White Gaussian Noise (AWGN) **********************
    
    [ich3,qch3]= comb(ifade,qfade,attn);% add white gaussian noise
	[ich4,qch4]= compconv(ich3,qch3,xh2);

    syncpoint=irfn*IPOINT+1;
    ich5=ich4(syncpoint:IPOINT:length(ich4));
    qch5=qch4(syncpoint+IPOINT/2:IPOINT:length(qch4));
        
%**************************** OQPSK Demodulation *****************************
   
    [demodata]=qpskdemod(ich5,qch5,1,nd,ml);

%************************** Bit Error Rate (BER) ****************************

    noe2=sum(abs(data1-demodata));  % sum: built in function
    nod2=length(data1);  % length: built in function
    noe=noe+noe2;
    nod=nod+nod2;

    fprintf('%d\t%e\n',iii,noe2/nod2);  % fprintf: built in function

end % for iii=1:nloop    

%********************** Output result ***************************

ber = noe/nod;
fprintf('%d\t%d\t%d\t%e\n',ebn0,noe,nod,noe/nod);  % fprintf: built in function
fid = fopen('BERoqpskfad.dat','a');
fprintf(fid,'%d\t%e\t%f\t%f\t\n',ebn0,noe/nod,noe,nod);  % fprintf: built in function
fclose(fid);


%******************** end of file ***************************
