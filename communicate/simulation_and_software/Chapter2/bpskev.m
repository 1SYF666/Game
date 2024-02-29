% Program 2-8
% bpskev.m
%
% Evaluation program of fading counter based BPSK transmission scheme
% This program is one of example simulations that include fading
% As for the explanation, you can check Chapter 3.
%
% Programmed by H.Harada
%

%******************** Preparation part **********************

% Time resolution
% In this case, 0.5us is used as an example
tstp = 0.5*1.0e-6; 

% Symbol rate
% In this case we assume that each sample time is equal to 1/(symbol rate).
% In this case 200 kbps is considered.
sr = 1/tstp ;

% Arrival time for each multipath normalized by tstp
% In this simulation four-path Rayleigh fading are considered
itau = [0, 2, 3, 4];

% Mean power for each multipath normalized by direct wave.
% In this simulation four-path Rayleigh fading are considered.
% This means that the second path is -10dB less than the first direct path.
dlvl = [0 ,10 ,20 ,25];

% Number of waves to generate fading for each multipath.
% In this simulation four-path Rayleigh fading are considered.
% In normal case, more than six waves are needed to generate Rayleigh fading
n0=[6,7,6,7];

% Initial Phase of delayed wave
% In this simulation four-path Rayleigh fading are considered.
th1=[0.0,0.0,0.0,0.0];

% Number of fading counter to skip (50us/0.5us)
% In this case we assume to skip 50 us
itnd0=100*2;

% Initial value of fading counter
% In this simulation four-path Rayleigh fading are considered.
% Therefore four fading counter are needed.
  
itnd1=[1000,2000, 3000, 4000];

% Number of directwave + Number of delayed wave
% In this simulation four-path Rayleigh fading are considered
now1=4;        

% Maximum Doppler frequency [Hz]
% You can insert your favorite value
fd=200;       

% Number of data to simulate one loop
% In this case 100 data are assumed to consider
nd = 100;

% You can decide two mode to simulate fading by changing the variable flat
% flat     : flat fading or not 
% (1->flat (only amplitude is fluctuated),0->nomal(phase and amplitude are fluctutated)
flat =1;


%******************** START CALCULATION *********************

nloop = 1000; % Number of simulation loop
noe = 0; % Initial number of errors
nod = 0; % Initial number of transmitted data

for iii=1:nloop 
    
%******************** Data generation ***********************
    
	data=rand(1,nd)>0.5;  % rand: built in function

%******************** BPSK modulation ***********************  

	data1=data.*2-1;  % Change data from 1 or 0 notation to +1 or -1 notation
    
%********************** Fading channel **********************

    % Generated data are fed into a fading simulator
    % In the case of BPSK, only Ich data are fed into fading counter
    [data6,data7]=sefade(data1,zeros(1,length(data1)),itau,dlvl,th1,n0,itnd1,now1,length(data1),tstp,fd,flat);

    % Updata fading counter
    itnd1 = itnd1+ itnd0;
    
%******************** BPSK Demodulation *********************
	
    demodata=data6 > 0;

%******************** Bit Error Rate (BER) ******************

    % count number of instantaneous errors
    noe2=sum(abs(data-demodata));  % sum: built in function
    
    % count number of instantaneous transmitted data
	nod2=length(data);  % length: built in function
   
	fprintf('%d\t%e\n',iii,noe2/nod2);
    
    noe=noe+noe2; 
	nod=nod+nod2;

end % for iii=1:nloop    

%********************** Output result ***************************

%ber = noe/nod;
fprintf('%d\t%d\t%e\n',noe,nod,noe/nod);

% ************************end of file***********************************


