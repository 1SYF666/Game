%% ************* MSK simulation ************* %%
%% ***** data:20240831 authoor:ShenYifu ****  %%
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

%%
% time
t = 0:1/fs:time;

% Generate random binary data
% data = randi([0, 1], 1, symbolnum);
load data.mat;
% Convert binary data to bipolar NRZ (±1)
ak = 2*data - 1;

% Pre-allocate phase and MSK signal
theta = zeros(1, length(t));
s_MSK = zeros(1, length(t));

% Calculate q(t) as per the provided equation
q_t = @(t) (t/(2*Tb)) .* (t >= 0 & t < Tb) + 1/2 .* (t >= Tb);

% Loop to calculate phase and MSK signal
for n = 1:symbolnum
    t_n = (n-1)*Tb <= t & t < n*Tb;
    theta(t_n) = pi/2 * sum(ak(1:n-1)) + pi * ak(n) * q_t(t(t_n) - (n-1)*Tb);
    s_MSK(t_n) = cos(2*pi*fc*t(t_n) + theta(t_n));
end

% Plot the MSK signal
figure;
plot(t, s_MSK);
xlabel('Time (s)');
ylabel('Amplitude');
title('MSK Signal using Formula Method');
grid on;