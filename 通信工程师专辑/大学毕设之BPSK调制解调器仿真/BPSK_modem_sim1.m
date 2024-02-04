%%%%%    BPSK调制解调器误码性能仿真程序   %%%%%%%%%%%
%%%%%%%%%       BPSK_modem_sim1.m       %%%%%%%%%%%
%%%   data:2016-12-23  author:nanjing xiaozhuang %%

%%%%%%%%%%%%%  程序说明
% 完成BPSK 调制解调器的仿真，比较不同信噪比下的误码性能
% 通信体制具体内容如下：
% 调制方式：BPSK     编码方式：无
% 解调方式：相干解调  译码方式：无
% 滚降因子：0.5
% 噪声：加性高斯白噪声
% 中频信号仿真


%%%         仿真环境
% 软件版本：matla Rb2022b
% 有些函数依旧已经不用，但依旧可以使用

%%%          sim系列说明之处
%


clear ;
close all;
clc;
format long;

%%% 程序主体
%% 系统参数
bit_rate = 1000;
symbol_rate = 1000;
fre_sample = 16000;
symbol_sample_rate = 16;        % 一个符号内的采样倍数
fre_carrier = 4000;
%% 信源
% 随机信号
% msg_source = randint(1,1000);
% randi(10,100,1); % 从1开始到10，100行1列
msg_source = [ones(1,20) zeros(1,20) randi([0,1],1,960)];     % 给出标志性的帧头，方便调试
% 通常帧头会采用扩频序列，为了方便调试，可以采用全1和全0

%% 发射机

%%% 编码器
% bchcode   % BCH 编码


%%% 调制器
% 双极性变换
bipolar_msg_source = 2*msg_source-1;      % 相位0-pi

%%% 滤波器
% rcosfit   滚降成型滤波 --- 最佳接收
rcos_msg_source1 = rcosflt(bipolar_msg_source,1000,16000);
rcos_msg_source = rcos_msg_source1';
% Roll-off factor 为0.5

% 频域观察
fft_rcos_msg_source = abs(fft(rcos_msg_source));

figure(1);
plot(rcos_msg_source);
title("时域波形");

figure(2);
plot(fft_rcos_msg_source);
title("频域波形");


aaa = 1;        % 调试断点
%%% 载波发送
time = 1:length(rcos_msg_source);
rcos_msg_source_carrier = rcos_msg_source.*cos(2*pi*fre_carrier.*time/fre_sample);

% 频域观察
fft_rcos_msg_source_carrier = abs(fft(rcos_msg_source_carrier));

% figure(3);plot(rcos_msg_source_carrier);title("时域波形");
 
% figure(4);plot(fft_rcos_msg_source_carrier);title("频域波形");



aaa = 1;        % 调试断点

%% 信道

snr = 10;       % 设置信噪比

%%% 高斯白噪声信道

rcos_msg_source_carrier_noise = awgn(rcos_msg_source_carrier,snr,'measured');

%%% 瑞利信道


%% 接收机

%%% 解调器
% 载波恢复 -- 生成本地载波
rcos_msg_source_noise = ....
rcos_msg_source_carrier_noise.*cos(2*pi*fre_carrier.*time/fre_sample);

% 滤波高频，保留基带信号
LPF_fir128 = fir1(128,0.2);     % 生成低通滤波器
rcos_msg_source_LP = filter(LPF_fir128,1,rcos_msg_source_noise);
% 延迟64个采样点输出
% figure(5);plot(rcos_msg_source_LP);title('时域波形');

% figure(6);plot(abs(fft(rcos_msg_source_LP)));title('频域波形');

% 生成匹配滤波器
rolloff_factor = 0.5;       % 滚降因子
rcos_fir = rcosdesign(rolloff_factor,6,symbol_sample_rate);
% 生成匹配滤波器 a squre root raised cosine FIR filter with rolloff factor

% 滤波
% filter
rcos_msg_source_MF = filter( rcos_fir, 1, rcos_msg_source_LP );

% figure(7);plot(rcos_msg_source_MF,'-*');title('时域波形');
% 
% figure(8);plot(abs(fft(rcos_msg_source_MF)),'-*');title('频域波形');



























