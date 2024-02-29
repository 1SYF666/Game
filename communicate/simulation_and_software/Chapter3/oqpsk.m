% Program 3-11
% oqpsk.m
%
% Simulation program to realize OQPSK transmission system
%
% Programmed by H.Harada and T.Yamamura
%

%******************** Preparation part *************************************

sr=256000.0; % Symbol rate
ml=2;        % ml:Number of modulation levels (BPSK:ml=1, QPSK:ml=2, 16QAM:ml=4)
br=sr.*ml;   % bit rate
nd = 1000;   % Number of symbols that simulates in each loop 
ebn0=3;      % Eb/N0
IPOINT=8;    % Number of oversamples

%************************* Filter initialization ***************************

irfn=21;                  % Number of taps
alfs=0.5;                 % Rolloff factor
[xh] = hrollfcoef(irfn,IPOINT,sr,alfs,1);   %Transmitter filter coefficients 
[xh2] = hrollfcoef(irfn,IPOINT,sr,alfs,0);  %Receiver filter coefficients 

%******************** START CALCULATION *************************************

nloop=100;  % Number of simulation loops

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
    attn=sqrt(attn);                     % sqrt: built in function
   
%********************** Fading channel **********************
 
  % Generated data are fed into a fading simulator
  % [ifade,qfade]=sefade(ich2,qch2,itau,dlvl,th1,n0,itnd1,now1,length(ich1),tstp,fd,flat);
  
  % Updata fading counter
  %itnd1 = itnd1+ itnd0;


%********************* Add White Gaussian Noise (AWGN) **********************
    
    [ich3,qch3]= comb(ich2,qch2,attn);% add white gaussian noise
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
fid = fopen('BERoqpsk.dat','a');
fprintf(fid,'%d\t%e\t%f\t%f\t\n',ebn0,noe/nod,noe,nod);  % fprintf: built in function
fclose(fid);

%******************** end of file ***************************
