%% ************* GMSK simulation ************* %%
%% ***** data:20240905 authoor:ShenYifu ****  %%
%% 参考资料《GSMsim - A MATLAB Implementation of a GSM Simulation Platform》
%% 参考资料

%% 
clc;clear; 
close all;
addpath function\;

%% 参数设置
K = 1e3;             % 单位 KHz
M = 1e6;             % 单位 MHz 
Rb = 2*K;           % 码速率
Tb = 1/Rb;
fs = 8*K;          % 采样率
fc = 2*K;           % 载波频率
Ts = 1/fs;
time = 0.5;            % 仿真时间
symbolnum = Rb*time; % 码元个数
samplenum = fs*time; % 时间样本
sps = fs/Rb;

OSR = sps;
BT = 0.3;

%% GMSK 调制
t = 0: Ts :time-Ts;
% data = randi([0, 1], 1, symbolnum);

load data.mat;
% data = ones(1,symbolnum);
data_base = -2*data + 1; 

burst = diff_enc(data);

[I,Q] = gmsk_mod(burst,Tb,OSR,BT);

s_I = I(1:length(t)) .* cos(2*pi*fc*t); % In-phase (同相)分量
s_Q = Q(1:length(t)) .* sin(2*pi*fc*t); % Quadrature (正交)分量
msk_signal =  (s_I + 1i * s_Q);

%% GMSK信号信号差分数字解调
receiver = msk_signal;
s_re = real(receiver);
s_im = imag(receiver);
s_orignal = s_re - s_im; 

I_dem = s_orignal.* cos(2*pi*fc*t);
Q_dem = s_orignal.* sin(2*pi*fc*t);

% 低通滤波
% y_filter = lowpass(y, fc, fs);       % 低通滤波器 
hai = 3.3;                             %海明窗窗过度带宽系数
wp = 0.26*pi;                          %通带截止频率 wp < fc/(2*fs)     
ws = 0.3*pi;                           %阻带起始频率 ws > fc/(2*fs)
wdlta = ws-wp;
N_lp = ceil(2*pi*hai/wdlta);           %求滤波器阶数N_lp
Wc = (wp+ws)/2;
b = fir1(N_lp-1,Wc/pi,hamming(N_lp));
s_re_filter = filter(b,1,I_dem);
s_im_filter = filter(b,1,Q_dem);

% ***** 未抽取 *****
s_re_filter1 = s_re_filter(length(b)/2+3:end);
s_im_filter1 = s_im_filter(length(b)/2+3:end);
% 延迟相乘
minlength = min(length(s_re_filter1),length(s_im_filter1));
for i = 1 : minlength-1
    Y1(i) = s_re_filter1(i)*s_im_filter1(i+1)-s_im_filter1(i)*s_re_filter1(i+1);
end
ak = burst;
for i = 1 : length(ak)
    base_data(1+sps*(i-1)) = ak(i);
    base_data(2+sps*(i-1):sps*i) = ak(i);
end
figure; plot(Y1); hold on; plot(-0.023*base_data);title("差分检测输出波形与差分编码后数据对比图-未抽取");

% ***** 已抽取 *****
s_re_filter = s_re_filter(length(b)/2+3:sps:end);
s_im_filter = s_im_filter(length(b)/2+3:sps:end);
% 延迟相乘
minlength = min(length(s_re_filter),length(s_im_filter));
for i = 1 : minlength-1
    Y(i) = s_re_filter(i)*s_im_filter(i+1)-s_im_filter(i)*s_re_filter(i+1);
end
figure;plot(Y);hold on; plot(-0.2*burst);title("差分数字解调输出波形与差分编码后数据对比-已抽取");
