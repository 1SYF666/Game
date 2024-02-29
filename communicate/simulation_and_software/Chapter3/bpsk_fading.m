% Program 3-2
% bpsk_fading.m
%
% Simulation program to realize BPSK transmission system
% (under one path fading)
%
% Programmed by H.Harada and T.Yamamura,
%

%******************** Preparation part **********************

sr=256000.0; % Symbol rate
ml=1;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 100;    % Number of symbols that simulates in each loop
ebn0=10;     % Eb/N0
IPOINT=8;    % Number of oversamples

%******************* Filter initialization ********************

irfn=21;     % Number of filter taps          
alfs=0.5;    % Rolloff factor
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
itnd0=nd*IPOINT*100;

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

%******************** START CALCULATION *********************

nloop=1000;  % Number of simulation loops

noe = 0;    % Number of error data
nod = 0;    % Number of transmitted data

for iii=1:nloop
	
%******************** Data generation *********************** 

    data=rand(1,nd)>0.5;  % rand: built in function

%******************** BPSK Modulation ***********************  

    data1=data.*2-1;
	[data2] = oversamp( data1, nd , IPOINT) ;
	data3 = conv(data2,xh);  % conv: built in function


%****************** Attenuation Calculation *****************
	
    spow=sum(data3.*data3)/nd;
	attn=0.5*spow*sr/br*10.^(-ebn0/10);
	attn=sqrt(attn);
   
%********************** Fading channel **********************

  % Generated data are fed into a fading simulator
  % In the case of BPSK, only Ich data are fed into fading counter
  [ifade,qfade]=sefade(data3,zeros(1,length(data3)),itau,dlvl,th1,n0,itnd1,now1,length(data3),tstp,fd,flat);
  
  % Updata fading counter
  itnd1 = itnd1+ itnd0;


%************ Add White Gaussian Noise (AWGN) ***************
	
    inoise=randn(1,length(ifade)).*attn;  % randn: built in function
	data4=ifade+inoise;
	data5=conv(data4,xh2);  % conv: built in function

	sampl=irfn*IPOINT+1;
	data6 = data5(sampl:8:8*nd+sampl-1);
    
%******************** BPSK Demodulation *********************
	
    demodata=data6 > 0;

%******************** Bit Error Rate (BER) ******************
	
    % count number of instantaneous errors
    noe2=sum(abs(data-demodata));  % sum: built in function
	
    % count number of instantaneous transmitted data
    nod2=length(data);  % length: built in function
	
    noe=noe+noe2;
	nod=nod+nod2;

	fprintf('%d\t%e\n',iii,noe2/nod2);
end % for iii=1:nloop    

%********************** Output result ***************************

ber = noe/nod;
fprintf('%d\t%d\t%d\t%e\n',ebn0,noe,nod,noe/nod);
fid = fopen('BERbpskfad.dat','a');
fprintf(fid,'%d\t%e\t%f\t%f\t\n',ebn0,noe/nod,noe,nod);
fclose(fid);

%******************** end of file ***************************
 
