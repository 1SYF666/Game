
% Program 3-5
% qpsk.m
%
% Simulation program to realize QPSK transmission system
%
% Programmed by H.Harada and T.Yamamura
%
clc;
close all;
clear;
%******************** Preparation part *************************************

sr=256000.0; % Symbol rate
ml=2;        % ml:Number of modulation levels (BPSK:ml=1, QPSK:ml=2, 16QAM:ml=4)
br=sr .* ml; % Bit rate
nd = 10000;   % Number of symbols that simulates in each loop
ebn0=-10:8;      % Eb/N0
IPOINT=8;    % Number of oversamples

% fre_carrier = 2000;
fre_carrier = 250490;
fre_sample = sr*IPOINT;

%************************* Filter initialization ***************************

irfn=21;                  % Number of taps
alfs=0.5;                 % Rolloff factor
[xh] = hrollfcoef(irfn,IPOINT,sr,alfs,1);   %Transmitter filter coefficients 
[xh2] = hrollfcoef(irfn,IPOINT,sr,alfs,0);  %Receiver filter coefficients 

%******************** START CALCULATION *************************************

nloop=100;  % Number of simulation loops

noe = 0;    % Number of error data
nod = 0;    % Number of transmitted data

for kkk=1:length(ebn0)
    ber222 = zeros(1,nloop);
    for iii=1:nloop

    %*************************** Data generation ********************************  

        data1=rand(1,nd*ml)>0.5;  % rand: built in function

    %*************************** QPSK Modulation ********************************  

        [ich,qch]=qpskmod(data1,1,nd,ml);
        [ich1,qch1]= compoversamp(ich,qch,length(ich),IPOINT); 
        [ich2,qch2]= compconv(ich1,qch1,xh); 
     
    %%% carrier
    time = 1:length(ich2);
    ich2_carrier = ich2.*cos(2*pi*fre_carrier.*time/fre_sample);
    qch2_carrier = qch2.*sin(2*pi*fre_carrier.*time/fre_sample);
    ch2_carrier =  ich2_carrier + 1i * qch2_carrier;

% %     %******************** randn函数加噪 ******************% 
%     %%% 
% %         spow=sum(ch2_carrier.*ch2_carrier)/nd;  % sum: built in function
%         spow=sum(ch2_carrier.*ch2_carrier)/length(ch2_carrier);  % sum: built in function
%         attn=0.5*spow*sr/br*10.^(-ebn0(kkk)/10);
%         attn=sqrt(attn);  % sqrt: built in function
% 
%     %%%
%         inoise = attn*randn(1,length(ch2_carrier));
%         qnoise = attn*randn(1,length(ch2_carrier));
% 
%         ch3_carrier = ch2_carrier + inoise.*cos(2*pi*fre_carrier.*time/fre_sample)-...
%                        1i * (qnoise.*sin(2*pi*fre_carrier.*time/fre_sample));
%         ich3_carrier = real(ch3_carrier);
%         qch3_carrier = imag(ch3_carrier);
        
%     %******************** awgn函数加噪 ******************%   
        snr(kkk) =ebn0(kkk)+10*log10(br/sr)-10 * log10(IPOINT) ; 
        ch3_carrier = awgn(ch2_carrier,snr(kkk),'measured');
        ich3_carrier = real(ch3_carrier);
        qch3_carrier = imag(ch3_carrier);
        

        ich3_carrier2 = ich3_carrier.*cos(2*pi*fre_carrier.*time/fre_sample);
        qch3_carrier2 = qch3_carrier.*sin(2*pi*fre_carrier.*time/fre_sample);
        
%         figure;plot(abs(fft(ich2)));title('成型前fft效果图');
%         figure;plot(abs(fft(ich3_carrier)));title('调制后fft效果图');
%         figure;plot(abs(fft(ich3_carrier2)));title('相干解调后fft效果图');
        
        
        % 滤波高频，保留基带信号
        LPF_fir128 = fir1(128,0.2);     % 生成低通滤波器
        
%         fvtool(LPF_fir128,'Analysis','impulse'); %将脉冲响应可视化
%         freqz(LPF_fir128,1);
        
        ich3 = filter(LPF_fir128,1,ich3_carrier2);
        qch3 = filter(LPF_fir128,1,qch3_carrier2);
        
%         figure;plot(abs(fft(ich3)));title('相干解调低通滤波后fft效果图');

        [ich4,qch4]= compconv(ich3,qch3,xh2);

        syncpoint=irfn*IPOINT+1 + (length(LPF_fir128)-1)/2;
        ich5=ich4(syncpoint:IPOINT:length(ich4));
        qch5=qch4(syncpoint:IPOINT:length(qch4));

    %**************************** QPSK Demodulation *****************************

        [demodata]=qpskdemod(ich5,qch5,1,nd,ml);

    %************************** Bit Error Rate (BER) ****************************

        noe2=sum(abs(data1-demodata));  % sum: built in function
        nod2=length(data1);  % length: built in function
        noe=noe+noe2;
        nod=nod+nod2;

%         fprintf('%d\t%e\n',iii,noe2/nod2);  % fprintf: built in function
        ber222(iii) = noe2/nod2;
    end % for iii=1:nloop   
    
%     ber(kkk) = noe/nod;
    ber(kkk)= mean(ber222);
    fprintf('%d\t%e\n',kkk,ber(kkk));
end
%********************** Output result ***************************

% ber = noe/nod;
% fprintf('%d\t%d\t%d\t%e\n',ebn0,noe,nod,noe/nod);  % fprintf: built in function
% fid = fopen('BERqpsk.dat','a');
% fprintf(fid,'%d\t%e\t%f\t%f\t\n',ebn0,noe/nod,noe,nod);  % fprintf: built in function
% fclose(fid);

%******************** end of file ***************************
ber_theory = 0.5*erfc(sqrt(10.^(ebn0/10)));
semilogy(ebn0,ber,'-*',ebn0,ber_theory,'-+');
xlabel('比特信噪比');
ylabel('误码率');
title('QPSK调制解调不同信噪比下误码率仿真曲线');
legend('实验曲线','理论曲线');
grid on;







