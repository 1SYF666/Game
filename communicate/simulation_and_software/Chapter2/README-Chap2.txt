%
% README Chapter 2
%
% by Hiroshi Harada
%
% If you have any bugs and questions in our simulation programes, please e-mail
% to harada@ieee.org . We try to do our best to answer your questions.
%

In this directory, we can find the eight files. The relationship between file name and the number of program written in the book is shown in as follows. 

Program2-1   mvalue.m
Program2-2   disper.m
Program2-3   main.m
Program2-4   comb.m
Program2-5   fade.m
Program2-6   sefade.m
Program2-7   delay.m
Program2-8   bpskev.m

If you would like to try to use the above programs by using MATLAB. First of all, please copy all of files to your created adequate directory. Then, you start to run MATLAB and you can see the following command prompt in the command window.

>>

Next, you can go to the directory that have all of programs in this section by using change directory (cd) commmand. If you copy all of files to /matlabR12/work/chapter2, you only type the following command.

>>cd /matlabR12/work/chapter2

As for chapter2, we have two main functions: main.m and bpskev.m.

(1) To simulate main.m, you just type the following command

>> main

Then you can obtain the following value.
(example)
meanvalue = 0.515658 
dispersion = 0.085317 
standard deviation=0.292091 

(2) To simulate bpskev.m, first of all you set the following 
parameters;

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

Then, type just the following command

>> clear
>> bpskev

You can see the following simulation result on your command window.
(example)
4637	100000	4.637000e-002	

where first number 4637 is the number of error data, second number 100000 is the number of transmitted data BER, and third number 4.637000e-002 is BER(Bit Error Rate) performance.

********** end of file ********** 
