%
% README Chapter 5
%
% by Hiroshi Harada
%
% If you have any bugs and questions in our simulation programs, please e-mail
% to harada@ieee.org. We try to do our best to answer your questions.
%

In this directory, we can find the seventeen files. The relationship between file name and the number of program written in the book is shown in as follows.

Program5-1   autocorr.m
Program5-2   crosscorr.m
Program5-3   mseq.m
Program5-4   shift.m
Program5-5   goldseq.m
Program5-6   dscdma.m
Program5-7   spread.m
Program5-8   despread.m
Program5-9   compoversamp2.m
Program5-10  compconv2.m
Program5-11  comb2.m
Program2-5   fade.m
Program2-6   sefade.m
Program2-7   delay.m
Program3-3   hrollfcoef.m
Program3-9   qpskmod.m
Program3-10   qpskdemod.m

If you would like to try to use the above programs by using MATLAB.
First of all, please copy all of files to your created adequate directory.
Then, you start to run MATLAB and you can see the following command prompt in the command window.

>>

Next, you can go to the directory that have all of programs in this section by using change directory (cd) command. If you copy all of files to /matlabR12/work/chapter5, you only type the following command.

>> cd /matlabR12/work/chapter5

(I) Usage of the functions

(1) Calculation of auto-correlation

If you would like to calculate of a sequence [1 1 1 -1 -1 1 -1], you can type the following command

>> autocorr([1 1 1 -1 -1 1 -1])

As a result, the following auto-correlation value is obtained.

ans =

     7    -1    -1    -1    -1    -1    -1

(2) Calculation of cross-correlation

If you would like to calculate of sequences [1 1 1 -1 -1 1 -1] and [1 -1 1 -1 1 -1 1], you can type the following command.

>> crosscorr([1 1 1 -1 -1 1 -1],[1 -1 1 -1 1 -1 1])

As a result, the following cross-correlation value is obtained.

ans =

    -1     3    -1     3    -5     3    -1

(3) Generation of M-sequence

The function mseq(X,Y,Z) outputs an M-sequence of the stage number X, the position of feedback taps Y, and the initial value of registers Z.
In case of X=3, Y=[1 3], and Z=[1 1 1],

>> mseq(3,[1 3],[1 1 1])

ans =

     1     1     1     0     1     0     0

And, the function mseq(X,Y,Z,N) outputs N one-chip shifted M-sequences.

>> mseq(3,[1 3],[1 1 1],3)

ans =

     1     1     1     0     1     0     0
     0     1     1     1     0     1     0
     0     0     1     1     1     0     1

(4) Generation of Gold sequence

First of all, you must prepare preferred pair of M-sequences.
For example, you type the following commands, and generate M-sequences m1, m2.

>> m1=mseq(3,[1 3],[1 1 1])

m1 =

     1     1     1     0     1     0     0

>> m2=mseq(3,[2 3],[1 1 1])

m2 =

     1     1     1     0     0     1     0

Next, you type the following command.

>> goldseq(m1,m2)

ans =

     0     0     0     0     1     1     0

As a result, you can get a Gold-sequence [0 0 0 0 1 1 0].
And, the function goldseq(m1,m2,N) outputs N one-chip shifted Gold-sequences.

>> goldseq(m1,m2,3)

ans =

     0     0     0     0     1     1     0
     1     0     0     1     1     0     1
     0     1     0     1     0     0     0

(II) Simulation of synchronous DS-CDMA

(1) Set paremeters

First of all, we set simulation parameters in "dscdma.m".

(a) Symbol rate
sr   = 256000.0;

(b) Number of modulation levels
ml   = 2;

(c) Number of symbols
nd   = 100;

(d) Eb/No
ebn0 = 3;

(e) Number of filter taps
irfn   = 21;

(f) Number of oversample
IPOINT =  8;

(g) Roll off factor
alfs   =  0.5;

(h) Number of users
user    = 1;

(i) Code sequence (1-M-sequence, 2-Gold sequence, 3-Orthogonal Gold sequecne)
seq     = 1;

(j) Number of stages
stage   = 3;

(k) Position of feedback taps for 1st
ptap1   = [1 3];

(l) Position of feedback taps for 2nd
ptap2   = [2 3];

(m) Initial value of registers for 1st
regi1   = [1 1 1];

(n) Initial value of registers for 2nd
regi2   = [1 1 1];

(o) Do you include the Rayleigh fading or not ? (0-No, 1-Yes)
rfade   = 0;

(p) Delay time
itau    = [0,8];

(q) Attenuation level
dlvl1   = [0.0,40.0];

(r) Number of waves to generate fading
n0      = [6,7];

(s) Initial phase of delayed wave
th1     = [0.0,0.0];

(t) Set fading counter
itnd1   = [3001,4004];

(u) Number of direct wave + delayed wave
now1    = 2;

(v) Doppler frequency [Hz]
fd      = 160;

(w) Flat fading or not (0-Normal, 1-Flat)
flat    = 1;

(x) Simulation number of times
nloop = 1000;

(y) Output file name to store the simulation results
fid = fopen('BER.dat','a');

(2) Type just the following command

>> dscdma

(3) Then, you can see the following simulation result on your command window.

3	4492	200000	2.246000e-002

where first number 3 is Eb/No, second number 4492 is the number of errors, third number 200000 is the number of data, and fourth number 2.246000e-002 is BER. And, simulation result is stored in the file (BER.dat) defined with (1)-(y).
If you change the paramter rfade from 0 to 1, you can include the effect of fading.

By changing the value of Eb/N0 (variable ebn0), you can obtain the graph that shows the relationship between Eb/N0 and BER and that can been seen in the figures of the book.

********** end of file ********** 
