%% ************* MSK simulation ************* %%
%% ***** data:20240901 authoor:ShenYifu ****  %%
%% 参考论文《MSK信号的调制与解调_赵雪》
%% 参考论文

%% MSK信号:用公式法生成

%% 
clc;clear;
close all;
%% 参数设置
K = 1e3;             % 单位 KHz
M = 1e6;             % 单位 MHz 
Rb = 1*K;           % 码速率
Tb = 1/Rb;
fs = 16*K;          % 采样率
fc = 2*K;           % 载波频率
Ts = 1/fs;
time = 1;            % 仿真时间
symbolnum = Rb*time; % 码元个数
samplenum = fs*time; % 时间样本
sps = fs/Rb;
%%
% time
t = 0: Ts :time-Ts;

% Generate random binary data
% data = randi([0, 1], 1, symbolnum);
load data.mat;

% Convert binary data to bipolar NRZ (±1)
ak = 2*data - 1;

% dd = zeros(1,samplenum);
% for i = 1 : length(ak)
%     dd(1+sps*(i-1)) = ak(i);
%     dd(2+sps*(i-1):sps*i) = zeros(1,sps-1);
% end
% gt = ones(1,sps);
% b = conv(dd,gt);

for i = 1 : length(ak)
    b_data(1+sps*(i-1)) = ak(i);
    b_data(2+sps*(i-1):sps*i) = ak(i);
end

% Calculate x_n
for i =  1 : symbolnum
    if i == 1
        x_n(i) = 0;
    else
        x_n(i) = x_n(i-1) + pi/2 * (i-1) * (ak(i-1)-ak(i));
    end
    dx_n( (i-1)*sps+1 : i*sps ) = x_n(i);
end

% Pre-allocate phase and MSK signal
theta = zeros(1, samplenum);
theta = (pi/(2*Tb)) .*t .* b_data + dx_n;
s_MSK_I = cos(2*pi*fc*t + theta);
s_MSK_Q = sin(2*pi*fc*t + theta);
msk_signal = s_MSK_I + 1i * s_MSK_Q; 

%% 信道

% msk_signal_noise=awgn(msk_signal,SNR,'measured');
% figure;plot(real(msk_signal)); hold on; plot(real(msk_signal_noise)); % 加噪前后实部对比图

%% 解调
%% 差分检测法
receiver = msk_signal;
s_re = real(receiver);
s_im = imag(receiver);
s_orignal = s_re;               % 此步骤必须，不然与论文公式对不上
s_delay = circshift(s_orignal,-sps) ;  % 延迟一个Tb

% 通过Hilbert变换实现移相pi/2
hilbert_signal = hilbert(s_delay);     % 计算Hilbert变换
s_delay_shifted = imag(hilbert_signal);% 提取虚部，即移相pi/2后的信号
y = s_orignal .* s_delay_shifted;

% 低通滤波
% y_filter = lowpass(y, fc, fs);       % 低通滤波器 
hai = 3.3;                             %海明窗窗过度带宽系数
wp = 0.26*pi;                          %通带截止频率 wp < fc/(2*fs)     
ws = 0.3*pi;                           %阻带起始频率 ws > fc/(2*fs)
wdlta = ws-wp;
N_lp = ceil(2*pi*hai/wdlta);           %求滤波器阶数N_lp
Wc = (wp+ws)/2;
b = fir1(N_lp-1,Wc/pi,hamming(N_lp));
y_filter = filter(b,1,y);
figure; plot(y_filter);  title("低通滤波后的波形");

figure; plot(y_filter(length(b)/2-7:end)); hold on; plot(0.45*b_data);title("差分检测输出波形与底码对比图");


%% 鉴频器
for i = 2:length(s_MSK_I)
    Pdot(i-1) = s_MSK_I(i-1)*s_MSK_I(i) + s_MSK_Q(i-1)*s_MSK_Q(i);
    Pcross(i-1) = s_MSK_I(i-1)*s_MSK_Q(i) - s_MSK_Q(i-1)*s_MSK_I(i);
end
theta_w = atan2(Pcross,Pdot);
theta_w = theta_w - mean(theta_w);
figure; plot(theta_w); hold on; plot(0.09*b_data);title("鉴频器输出波形与底码对比");


%% 信号频移载波相干解调 
receiver = msk_signal;
s_re = real(receiver);
s_im = imag(receiver);
s_orignal = s_re; 
squared_signal = s_orignal.^2;
% 二分频 (二分频可以通过低通滤波实现)
[b1,a1] = butter(5, 0.3);              % 设计一个5阶低通滤波器，截止频率为0.5倍的归一化频率
half_freq_signal = filter(b1, a1, squared_signal);

% 移相操作
hilbert_signal = hilbert(half_freq_signal); % Hilbert变换获取90度移相信号
shifted_signal = real(hilbert_signal);      % 提取实部，得到移相后的载波信号

% 画 shifted_signal 的频谱图,计算出fc1 和 fc2，谱线位置要除以2，因为是信号平方
% 论文中两个支路频率：fc1 = fc + 1/(4*Tb); fc2 = fc - 1/(4*Tb)

fc1 = 1750;
fc2 = fc1 + 1/(2*Tb);

s_re_out = s_re.*cos(2 * pi * fc1 * t);
s_im_out = s_re.*cos(2 * pi * fc2 * t);

s_re_out1 = s_re_out(1:end);
s_im_out1 = s_im_out(1:end);
% 积分
for i = 1 : floor( length(s_re_out1)/sps )
    s_sum_re( i ) = abs ( sum( s_re_out1( (i-1) * sps + 1 : i * sps ) ) );
    s_sum_im( i ) = abs ( sum( s_im_out( (i-1) * sps + 1 : i * sps ) ) );
    
    % 判决
    if s_sum_re( i ) > s_sum_im( i )
        de_s_out (i) = -1;
    else
        de_s_out (i) = 1;
    end
end
figure; plot(de_s_out); hold on; plot(0.9*ak); title("相干解调输出后波形与底码对比");
