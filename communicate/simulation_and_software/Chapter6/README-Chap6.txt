%
% README Chapter 6
%
% by Hiroshi Harada
%
% If you have any bugs and questions in our simulation programs, please e-mail
% to harada@ieee.org. We try to do our best to answer your questions.
%

In this directory, we can find the eleven files. The relationship between file name and the number of program written in the book is shown in as follows. 

Program6-1   main.m
Program6-2   positon.m
Program6-3   distance.m
Program6-4   theorys.m
Program6-5   graph.m
Program6-6   paloha.m
Program6-7   saloha.m
Program6-8   npcsma.m
Program6-9   carriersense.m
Program6-10  snpisma.m
Program6-11  inhibitsense.m

If you would like to try to use the above programs by using MATLAB.
First of all, please copy all of files to your created adequate directory.
Then, you start to run MATLAB and you can see the following command prompt in the command window.

>>

Next, you can go to the directory that have all of programs in this section by using change directory (cd) command. If you copy all of files to /matlabR12/work/chapter6, you only type the following command.

>>cd /matlabR12/work/chapter6

As for chapter6, we have a main function: main.m. By using only one main program, we can simulate four protocols, pure ALOHA, slotted ALOHA, non-persistent CSMA, and slotted non-persistent ISMA. The following is a procedure to perform these simulations.

(1) Set parameters

First of all, we set simulation parameters in "main.m".

(a) Bit rate (bps)
brate   = 512e3;

(b) Symbol rate [sps]
Srate   = 256e3;  

(c) Packet Length [symbols]
Plen    = 128;

(d) Normalized transmission delay
Dtime   = 0.01;

(e) Attenuation constant for propagation loss
alfa    = 3;

(f) Standard deviation for shadowing
sigma   = 6;

(g) Radius of cellular zone [m]
r  = 100;

(h) The position of access point (x,y,z)[m]
bxy     = [0, 0, 5];

(i) Capture ratio for capture effect[dB]
tcn     = 10; 

(j) Number of access terminals
Mnum    = 100;

(k) Carrier to noise power ratio of the transmitter of the access terminal, but mcn is defined as C/N [dB] at the access point when a packet that was transmitted from end of cellular zone suffered only propagation loss.

mcn     = 30; 

(l) Access protocol (1-pure ALOHA, 2-slotted ALOHA, 3-non-persistent CSMA, 4-non-persistent slotted ISMA)
pno     = 1;  

(m) Do you include the capture effect or not? (0-No, 1- Yes)
capture = 0; 

(n) The maximum number of packets that can successfully transmitted to the access point, this number is one of index to terminate simulation
spend   = 10000; 

(o) Output file name to store the simulation results
outfile = 'test.dat'; 

(p) Offered traffic
for G=[0.1:0.1:1,1.2:0.2:2]  

(2) Type just the following command

>> main

(3) Then, you can find the following progress report on your command window.
(It takes several ten minutes...)
(Example)
********* Simulation Start *********

 paloha without capture effect

G=0.101247	S=0.082678	TS=0.082688
G=0.198852	S=0.134278	TS=0.133601
G=0.299714	S=0.163948	TS=0.164581
G=0.400204	S=0.180891	TS=0.179750
G=0.500014	S=0.184636	TS=0.183940
G=0.600109	S=0.183694	TS=0.180710
G=0.692799	S=0.175184	TS=0.173320
G=0.793340	S=0.162029	TS=0.162320
G=0.893643	S=0.150839	TS=0.149608
G=0.999630	S=0.136660	TS=0.135385
G=1.185882	S=0.112490	TS=0.110662
G=1.385606	S=0.085676	TS=0.086720
G=1.591802	S=0.065746	TS=0.065958
G=1.784259	S=0.049095	TS=0.050312
G=1.983398	S=0.036744	TS=0.037554

********** Simulation End **********       

where G is a given offered traffic, S is a simulated value of the throughput, and TS is theoretical value of the throughput when G is assumed as the given offered traffic.

(4) After finishing the simulation, we can find the relationships between offered traffic and throughput and between offered traffic and averaged transmission delay time on the figures automatically.

(5) All of simulation results are stored in the file that was decided by the variable "outfile". When outfile = 'test.dat' and we can see the simulation results, we just type the following command.
>> graph test.dat

********** end of file **********  
