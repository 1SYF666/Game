function Z=Rayfadsim(Fd,Ts,Ns)
%------------------------------------------------------------------------------------
% This function can be used to generate multiple uncorrelated Rayleigh 
% channel fading waveforms with accurate second-order statistics compared
% with those of Clark's reference model.
%
%   Fd: maximum Doppler frequency 
%   Ts: sampling period
%   Ns: number of samples
%   Z: (1,Ns) complex fading vector with unit variance,i.e.,R_{ZZ}(\tau)=J_0(2\pi Fd \tau).
%  
%   Reference:
%   This simulator is built based on the following paper:
%   Yahong R.Zheng and Chengshan Xiao,"Improved models for the generation of multiple
%   uncorrelated Rayleigh fading waveform" IEEE communications Letters,vol.6,June 2002
%
%   There are many ways to implement the 16 models provided by Zheng and Xiao.This one
%   is only an example and it is good for generating long sequence of the fading, with
%   limited computer memory. However,this example is not the most computationally efficient
%   one due to the "for-loop" fact in Matlab.To remove the "for-loop" will need more
%   computer memories.
%------------------------------------------------------------------------------------
%---[set up fading channel parameters]--------------------------------------------
M=16;N=4*M;
dop_gain=sqrt(1/M)*ones(1,M); % This gain differs sqrt(2)
                              % from the paper to get Var(Z)=1.
theta=(2*rand-1)*pi;
doppler=Fd*cos(2*pi/N*[1:M]+theta/N-pi/N);
phi=(2*rand(M,1)-1)*pi;
varphi=(2*rand(M,1)-1)*pi;
state=zeros(M,1);
dop_update=(2*pi*doppler*Ts).';
%---[generate fading channel samples]------------------------------------------------
Z=zeros(1,Ns);
for (k=1:Ns)
    Z(k)=dop_gain*[cos(state+phi)+i*sin(state+varphi)];
    state=dop_update+state;
end

