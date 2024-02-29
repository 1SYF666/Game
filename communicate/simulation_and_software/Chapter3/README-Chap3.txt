%
% README Chapter 3
%
% by Hiroshi Harada
%
% If you have any bugs and questions in our simulation programs, please e-mail
% to harada@ieee.org. We try to do our best to answer your questions.
%

In this directory, we can find the twenty-eight files. The relationship between file name and the number of program written in the book is shown in as follows.

Program3-1   bpsk.m
Program3-2   bpsk_fading.m
Program3-3   hrollfcoef.m
Program3-4   oversamp.m
Program3-5   qpsk.m
Program3-6   qpsk_fading.m
Program3-7   compconv.m
Program3-8   compoversamp.m
Program3-9   qpskmod.m
Program3-10  qpskdemod.m
Program3-11  oqpsk.m
Program3-12  oqpsk_fading.m
Program3-13  msk.m
Program3-14  msk_fading.m
Program3-15  msk2.m
Program3-16  msk2_fading.m
Program3-17  oversamp2.m
Program3-18  gmsk.m
Program3-19  gmsk_fading.m
Program3-20  gaussf.m
Program3-21  qam16.m
Program3-22  qam16_fading.m
Program3-23  qammod.m
Program3-24  qamdemod.m
Program2-4   comb.m
Program2-5   fade.m
Program2-6   sefade.m
Program2-7   delay.m

If you would like to try to use the above programs by using MATLAB.First of all, please copy all of files to your created adequate directory. Then, you start to run MATLAB and you can see the following command prompt in the command window.

>>

Next, you can go to the directory that have all of programs in this section by using change directory (cd) command. If you copy all of files to /matlabR12/work/chapter3, you only type the following command.

>> cd /matlabR12/work/chapter3

In this directory, we can find fourteen main functions, bpsk.m, bpsk_fading.m, qpsk.m, qpsk_fading.m, oqpsk.m, oqpsk_fading.m, msk.m, msk_fading.m, msk2.m, msk2_fading.m, gmsk.m, gmsk_fading.m, qam16.m and qam16_fading.m

#########################################################
(1) Simulation of "bpsk.m"
#########################################################

This program simulates the transmission performance of BPSK under Additive White Gausian Noise (AWGN) environment.

(a) Set paremeters

First of all, we set simulation parameters in "bpsk.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=1;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 1000;   % Number of symbols that simulates in each loop
ebn0=3;      % Eb/N0
IPOINT=8;    % Number of oversamples

%******************** START CALCULATION *********************
nloop=100;  % Number of simulation loops

(b) Type just the following command

>> clear
>> bpsk

(c) Then, you can see the following simulation result on your command window.
(example)
3	2275	100000	2.275000e-002	

where first number 3 is Eb/No, second number 2275 is the number of error data, third number 100000 is the number of transmitted data, and fourth number 2.275000e-002 is bit error rate (BER) performance. And, the simulation result is stored in the file (BERbpsk.dat).

#########################################################
(2) Simulation of "bpsk_fading.m"
#########################################################

This program simulates the transmission performance of BPSK under Rayleigh fading environment.

(a) Set paremeters

First of all, we set simulation parameters in "bpsk_fading.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=1;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 100;   % Number of symbols that simulates in each loop
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
fd=160;       

% You can decide two mode to simulate fading by changing the variable flat
% flat     : flat fading or not 
% (1->flat (only amplitude is fluctuated),0->nomal(phase and amplitude are fluctutated)
flat =1;

%******************** START CALCULATION *********************
nloop=1000;  % Number of simulation loops

(b) Type just the following command

>> clear
>> bpsk_fading

(c) Then, you can see the following simulation result on your command window.
(example)
10	2143	100000	2.143000e-002	

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERbpskfad.dat).

#########################################################
(3) Simulation of "qpsk.m"
#########################################################

This program simulates the transmission performance of QPSK under Additive White Gausian Noise (AWGN) environment.

(a) Set paremeters

First of all, we set simulation parameters in "qpsk.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=2;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 1000;   % Number of symbols that simulates in each loop
ebn0=3;      % Eb/N0
IPOINT=8;    % Number of oversamples

%******************** START CALCULATION *********************
nloop=100;  % Number of simulation loops

(b) Type just the following command

>> clear
>> qpsk

(c) Then, you can see the following simulation result on your command window.
(example)
3	4475	200000	2.237500e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERqpsk.dat).

#########################################################
(4) Simulation of "qpsk_fading.m"
#########################################################

This program simulates the transmission performance of QPSK under Rayleigh fading environment.

(a) Set paremeters

First of all, we set simulation parameters in "qpsk_fading.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=2;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 1000;   % Number of symbols that simulates in each loop
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
fd=160;       

% You can decide two mode to simulate fading by changing the variable flat
% flat     : flat fading or not 
% (1->flat (only amplitude is fluctuated),0->nomal(phase and amplitude are fluctutated)
flat =1;

%******************** START CALCULATION *********************
nloop=1000;  % Number of simulation loops

(b) Type just the following command

>> clear
>> qpsk_fading

(c) Then, you can see the following simulation result on your command window.
(example)
10	4218	200000	2.109000e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERqpskfad.dat).

#########################################################
(5) Simulation of "oqpsk.m"
#########################################################

This program simulates the transmission performance of OQPSK under Additive White Gausian Noise (AWGN) environment.

(a) Set paremeters

First of all, we set simulation parameters in "oqpsk.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=2;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 1000;   % Number of symbols that simulates in each loop
ebn0=3;      % Eb/N0
IPOINT=8;    % Number of oversamples

%******************** START CALCULATION *********************
nloop=100;  % Number of simulation loops

(b) Type just the following command

>> clear
>> oqpsk

(c) Then, you can see the following simulation result on your command window.
(example)
3	4529	200000	2.264500e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERoqpsk.dat).

#########################################################
(6) Simulation of "oqpsk_fading.m"
#########################################################

This program simulates the transmission performance of OQPSK under Rayleigh fading environment.

(a) Set paremeters

First of all, we set simulation parameters in "oqpsk_fading.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=2;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 1000;   % Number of symbols that simulates in each loop
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

%******************** START CALCULATION *********************
nloop=200;  % Number of simulation loops

(b) Type just the following command

>> clear
>> oqpsk_fading

(c) Then, you can see the following simulation result on your command window.
(example)
10	8552	400000	2.138000e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERoqpskfad.dat).

#########################################################
(7) Simulation of "msk.m"
#########################################################

This program simulates the transmission performance of MSK under Additive White Gausian Noise (AWGN) environment.

(a) Set paremeters

First of all, we set simulation parameters in "msk.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=1;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 1000;   % Number of symbols that simulates in each loop
ebn0=3;      % Eb/N0
IPOINT=8;    % Number of oversamples

%******************** START CALCULATION *********************
nloop=100;  % Number of simulation loops

(b) Type just the following command

>> clear
>> msk

(c) Then, you can see the following simulation result on your command window.
(example)
3	2222	100000	2.222000e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERmsk.dat).

#########################################################
(8) Simulation of "msk_fading.m"
#########################################################

This program simulates the transmission performance of MSK under Rayleigh fading environment.

(a) Set paremeters

First of all, we set simulation parameters in "msk_fading.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=1;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 100;   % Number of symbols that simulates in each loop
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

%******************** START CALCULATION *********************
nloop=1000;  % Number of simulation loops

(b) Type just the following command

>> clear
>> msk_fading

(c) Then, you can see the following simulation result on your command window.
(example)
10	2058	100000	2.058000e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERmskfad.dat).

#########################################################
(9) Simulation of "msk2.m"
#########################################################

This program simulates the transmission performance of MSK2 under Additive White Gausian Noise (AWGN) environment.

(a) Set paremeters

First of all, we set simulation parameters in "msk2.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=1;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 1000;   % Number of symbols that simulates in each loop
ebn0=5;      % Eb/N0
IPOINT=8;    % Number of oversamples

%******************** START CALCULATION *********************
nloop=100;  % Number of simulation loops

(b) Type just the following command

>> clear
>> msk2

(c) Then, you can see the following simulation result on your command window.
(example)
5	1179	100000	1.179000e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERmsk2.dat).

#########################################################
(10) Simulation of "msk2_fading.m"
#########################################################

This program simulates the transmission performance of MSK2 under Rayleigh fading environment.

(a) Set paremeters

First of all, we set simulation parameters in "msk2_fading.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=1;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 100;   % Number of symbols that simulates in each loop
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

%******************** START CALCULATION *********************
nloop=1000;  % Number of simulation loops

(b) Type just the following command

>> clear
>> msk2_fading

(c) Then, you can see the following simulation result on your command window.
(example)
15	1243	100000	1.243000e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERmsk2fad.dat).

#########################################################
(11) Simulation of "gmsk.m"
#########################################################

This program simulates the transmission performance of GMSK under Additive White Gausian Noise (AWGN) environment.

(a) Set paremeters

First of all, we set simulation parameters in "gmsk.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=1;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 1000;   % Number of symbols that simulates in each loop
ebn0=5;      % Eb/N0
IPOINT=8;    % Number of oversamples

%******************** START CALCULATION *********************
nloop=100;  % Number of simulation loops

(b) Type just the following command

>> clear
>> gmsk

(c) Then, you can see the following simulation result on your command window.
(example)
5	2634	100000	2.634000e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERgmsk.dat).

#########################################################
(12) Simulation of "gmsk_fading.m"
#########################################################

This program simulates the transmission performance of GMSK under Rayleigh fading environment.

(a) Set paremeters

First of all, we set simulation parameters in "gmsk_fading.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=1;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 100;   % Number of symbols that simulates in each loop
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

%******************** START CALCULATION *********************
nloop=1000;  % Number of simulation loops

(b) Type just the following command

>> clear
>> gmsk_fading

(c) Then, you can see the following simulation result on your command window.
(example)
15	1546	100000	1.546000e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERgmskfad.dat).

#########################################################
(13) Simulation of "qam16.m"
#########################################################

This program simulates the transmission performance of 16QAM under Additive White Gausian Noise (AWGN) environment.

(a) Set paremeters

First of all, we set simulation parameters in "qam16.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=4;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 1000;   % Number of symbols that simulates in each loop
ebn0=6;      % Eb/N0
IPOINT=8;    % Number of oversamples

%******************** START CALCULATION *********************
nloop=100;  % Number of simulation loops

(b) Type just the following command

>> clear
>> qam

(c) Then, you can see the following simulation result on your command window.
(example)
6	11121	400000	2.780250e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERqam.dat).

#########################################################
(14) Simulation of "qam16_fading.m"
#########################################################

This program simulates the transmission performance of 16QAM under Rayleigh fading environment.

(a) Set paremeters

First of all, we set simulation parameters in "qam16_fading.m".
%******************** Preparation part **********************

sr=256000.0; % Symbol rate 256 ksymbol/s
ml=4;        % Number of modulation levels
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 100;   % Number of symbols that simulates in each loop
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

(b) Type just the following command

>> clear
>> qam16_fading

(c) Then, you can see the following simulation result on your command window.
(example)
15	5105	400000	1.276250e-002

The meaning of each value is the same of the result from "bpsk.m".
The simulation result is stored in the file (BERqamfad.dat).


By changing the value of Eb/N0 (variable ebn0), you can obtain the graph that shows the relationship between Eb/N0 and BER and that can been seen in the figures of the book.


********** end of file ********** 
