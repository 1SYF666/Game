%% ************* MSK simulation ************* %%
%% ***** data:20240901 authoor:ShenYifu ****  %%
%% 参考论文《MSK信号的调制与解调_赵雪》
%% 参考论文

%% MSK信号:用正交调制法生成

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
A = 1;               % 信号幅度 
SNR =  10;
%% 信号生成
% time
t = 0: Ts :time-Ts;

% Generate random binary data
% data = randi([0, 1], 1, symbolnum);
load data.mat;
data_base = 2*data - 1; 
% 差分编码
b_data = zeros(1, symbolnum);
b_data(1) = data(1);
for i = 2 : symbolnum
    b_data(i) = xor(b_data(i-1), data(i));
end
b_data = 2*b_data - 1; % 将比特序列映射到{-1, 1}

% 生成p(k)和q(k)序列
b_odd = b_data(1:2:end); 
b_even = b_data(2:2:end); 
for i =  1 : length(b_odd)
    pp( (i-1)*2+1 : i*2 ) = b_odd(i);
    qq( (i-1)*2+1 : i*2 ) = b_even(i);
end
% 延迟Tb
pp = circshift(pp,-1);          % 论文中是同向分量提前Tb
% qq = circshift(qq,1);         % 正交分量滞后Tb，后面结果与论文中对不上        

% 采样
for i = 1 : length(qq)
    ppp( (i-1)*sps+1 : i*sps ) = pp(i);
    qqq( (i-1)*sps+1 : i*sps ) = qq(i);
end

I_t = cos(pi*t/(2*Tb)) .* ppp;
Q_t = sin(pi*t/(2*Tb)) .* qqq;

% 生成MSK信号
s_I = I_t .* cos(2*pi*fc*t); % In-phase (同相)分量
s_Q = Q_t .* sin(2*pi*fc*t); % Quadrature (正交)分量
msk_signal = A * (s_I + 1i * s_Q);

%% 信道

% msk_signal_noise=awgn(msk_signal,SNR,'measured');
% figure;plot(real(msk_signal)); hold on; plot(real(msk_signal_noise)); % 加噪前后实部对比图

%% 解调
%% 加预编码的MSK信号的最佳接收
receiver = msk_signal;
s_re = real(receiver);
s_im = imag(receiver);
s_orignal = s_re; 
s_re_out = s_re.*cos(pi*t/(2*Tb)).* cos(2*pi*fc*t);
s_im_out = s_im.*sin(pi*t/(2*Tb)).* sin(2*pi*fc*t);

% Tb时间内含有sps个采样点数据
for i = 1 : floor( length(s_re_out)/(2*sps) )
    s_sum_re( i ) = ( sum( s_re_out( (i-1) * sps*2 + 1 : i * sps*2 ) ) );
    s_sum_im( i ) = ( sum( s_im_out( (i-1) * sps*2 + 1 : i * sps*2 ) ) );
   
    % 判决 -- 论文中判决规则较复杂，暂时没明白
    if s_sum_re( i ) > 0
        de_s_re_out (i) = 1;
    else
        de_s_re_out (i) = -1;
    end

    if s_sum_im( i ) > 0
        de_s_im_out (i) = 1;
    else
        de_s_im_out (i) = -1;
    end
end 
de_s_out1 = [de_s_re_out;de_s_im_out];
de_s_out = de_s_out1(:)';
figure; plot(de_s_out); hold on; plot(0.9*b_data); title("最佳接收输出后波形与底码对比");

%% MSK信号信号差分数字解调
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
s_re_filter1 = s_re_filter(length(b)/2-15:end);
s_im_filter1 = s_im_filter(length(b)/2-15:end);
% 延迟相乘
minlength = min(length(s_re_filter1),length(s_im_filter1));
for i = 1 : minlength-1
    Y1(i) = s_re_filter1(i)*s_im_filter1(i+1)-s_im_filter1(i)*s_re_filter1(i+1);
end
ak = data_base;
for i = 1 : length(ak)
    base_data(1+sps*(i-1)) = ak(i);
    base_data(2+sps*(i-1):sps*i) = ak(i);
end
figure; plot(Y1); hold on; plot(0.023*base_data);title("差分检测输出波形与底码对比图-未抽取");

% ***** 已抽取 *****
s_re_filter = s_re_filter(length(b)/2-15:sps:end);
s_im_filter = s_im_filter(length(b)/2-15:sps:end);
% 延迟相乘
minlength = min(length(s_re_filter),length(s_im_filter));
for i = 1 : minlength-1
    Y(i) = s_re_filter(i)*s_im_filter(i+1)-s_im_filter(i)*s_re_filter(i+1);
end
figure;plot(Y);hold on; plot(0.2*data_base);title("差分数字解调输出波形与底码对比-已抽取");
