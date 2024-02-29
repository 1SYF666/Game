% Program 3-16
% msk2_fading.m
%
% Simulation program to realize MSK transmission system
% (under one path fading)
%
% Programmed by R.Sawai and H.Harada
%

%******************** Preparation part *************************************

sr=256000.0; % Symbol rate
ml=1;        % ml:Number of modulation levels 
br=sr.*ml;   % Bit rate
nd = 100;    % Number of symbols that simulates in each loop
ebn0=15;     % Eb/N0
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
  
itnd1=[3000];

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

    data1=rand(1,nd*ml)>0.5;  % rand: built in function

%*************************** MSK Modulation ********************************  
  
    data11=2*data1-1;
    data2=oversamp2(data11,length(data11),IPOINT);

    th=zeros(1,length(data2)+1);
    ich2=zeros(1,length(data2)+1);
    qch2=zeros(1,length(data2)+1);

    for ii=2:length(data2)+1
  	    th(1,ii)=th(1,ii-1)+pi/2*data2(1,ii-1)./IPOINT;
    end

    ich2=cos(th);
    qch2=sin(th);
    
%**************************** Attenuation Calculation ***********************

    spow=sum(ich2.*ich2+qch2.*qch2)/(nd*IPOINT);  % sum: built in function
    attn=0.5*spow*sr/br*10.^(-ebn0/10);
	attn=sqrt(attn);  % sqrt: built in function
   
   
%********************** Fading channel **********************
  
  % Generated data are fed into a fading simulator
    [ifade,qfade]=sefade(ich2,qch2,itau,dlvl,th1,n0,itnd1,now1,length(ich2),tstp,fd,flat);
  
  % Updata fading counter
    itnd1 = itnd1+ itnd0;

%********************* Add White Gaussian Noise (AWGN) **********************
	[ich3,qch3]= comb(ifade,qfade,attn);% add white gaussian noise

    syncpoint = 1;
    ich5=ich3(syncpoint:IPOINT:length(ich3));
    qch5=qch3(syncpoint:IPOINT:length(qch3));
        
%**************************** MSK Demodulation *****************************
	
    demoddata2(1,1)=-1;

    for k=3:2:nd*ml+1
         demoddata2(1,k)=ich5(1,k)*qch5(1,k-1)*cos(pi*(k))>0;
    end

    for n=2:2:nd*ml+1
         demoddata2(1,n)=ich5(1,n-1)*qch5(1,n)*cos(pi*(n))>0;
    end

    [demodata]=demoddata2(1,2:nd*ml+1);

%************************** Bit Error Rate (BER) ****************************

    noe2=sum(abs(data1-demodata));  % sum: built in function
	nod2=length(data1);  % length: built in function
	noe=noe+noe2;
	nod=nod+nod2;

	fprintf('%d\t%e\n',iii,noe2/nod2);  % fprintf: built in function


end % for iii=1:nloop    

%****************************** Data file ***********************************

ber = noe/nod;
fprintf('%d\t%d\t%d\t%e\n',ebn0,noe,nod,noe/nod);  % fprintf: built in function
fid = fopen('BERmsk2fad.dat','a');
fprintf(fid,'%d\t%e\t%f\t%f\t\n',ebn0,noe/nod,noe,nod);  % fprintf: built in function
fclose(fid);

%******************** end of file ***************************


