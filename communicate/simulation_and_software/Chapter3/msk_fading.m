% Program 3-14
% msk_fading.m
%
% Simulation program to realize MSK transmission system
% (under one path fading)
%
% Programmed by H.Harada and T.Yamamura
%

%******************** preparation part *************************************

sr=256000.0; % Symbol rate
ml=1;        % ml:Number of modulation levels 
br=sr.*ml;   % Bit rate
nd = 100;    % Number of symbols that simulates in each loop
ebn0=10;     % Eb/N0
IPOINT=8;    % Number of oversamples

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
fd=320;       

% You can decide two mode to simulate fading by changing the variable flat
% flat     : flat fading or not 
% (1->flat (only amplitude is fluctuated),0->nomal(phase and amplitude are fluctutated)
flat =1;

%******************** START CALCULATION *************************************

nloop=1000;  % Number of simulation loops

noe = 0;    % Number of error data
nod = 0;    % Number of transmitted data

for iii=1:nloop
    
%*************************** Data generation ********************************  

    data1=rand(1,nd)>0.5;  % rand: built in function

%*************************** MSK Modulation ********************************  
  
    [ich,qch]=qpskmod(data1,1,nd/2,2);
    smooth1=cos(pi/2*[-1+1./4.*[0:IPOINT-1]]); %IPOINT point filtering

    for ii=1:length(ich)
       ich2((ii-1)*IPOINT+1:ii*IPOINT)=(-1)^(ii-1)*smooth1.*ich(ii);
       qch2((ii-1)*IPOINT+1:ii*IPOINT)=(-1)^(ii-1)*smooth1.*qch(ii);
    end

    ich21=[ich2 zeros(1,IPOINT/2)];
    qch21=[zeros(1,IPOINT/2) qch2];
   
%**************************** Attenuation Calculation ***********************

    spow=sum(ich21.*ich21+qch21.*qch21)/nd/2    ;  % sum: built in function
	attn=0.5*spow*sr/br/2*10.^(-ebn0/10);
	attn=sqrt(attn);                             % sqrt: built in function
   
%********************** Fading channel **********************

  % Generated data are fed into a fading simulator
    [ifade,qfade]=sefade(ich21,qch21,itau,dlvl,th1,n0,itnd1,now1,length(ich21),tstp,fd,flat);
  
  % Updata fading counter
    itnd1 = itnd1+ itnd0;

%********************* Add White Gaussian Noise (AWGN) **********************
	
    [ich3,qch3]= comb(ifade,qfade,attn);% add white gaussian noise

    syncpoint=1;

	ich5 = ich3(syncpoint+IPOINT/2:IPOINT:length(ich2));
	qch5 = qch3(syncpoint+IPOINT:IPOINT:length(ich2)+IPOINT/2);
   
    ich5(2:2:length(ich5))=-1*ich5(2:2:length(ich5));
    qch5(2:2:length(ich5))=-1*qch5(2:2:length(ich5));

%**************************** MSK Demodulation *****************************

    [demodata]=qpskdemod(ich5,qch5,1,nd/2,2);

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
fid = fopen('BERmskfad.dat','a');
fprintf(fid,'%d\t%e\t%f\t%f\t\n',ebn0,noe/nod,noe,nod);  % fprintf: built in function
fclose(fid);

%******************** end of file ***************************