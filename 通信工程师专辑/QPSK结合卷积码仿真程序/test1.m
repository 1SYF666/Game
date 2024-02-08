clc;
close all;
clear;
%%

% 参数设置
N = 10000; % 二进制数据点的数量
Eb_No_dB = 10; % 信噪比（以dB为单位）

% 1. 生成随机二进制数据
data = randi([0 1], N, 1);

% 2. QPSK调制
% 将二进制数据分为两部分，用于QPSK的I和Q两个分支
dataI = data(1:2:end);
dataQ = data(2:2:end);

% 映射到QPSK符号
symbolI = 2*dataI - 1; % 映射到-1和1
symbolQ = 2*dataQ - 1;
symbols = symbolI + 1i*symbolQ; % 构造复数QPSK符号

% 3. 添加高斯白噪声
% 计算符号能量
Es = mean(abs(symbols).^2);
% 计算比特能量
Eb = Es/2;
% 计算噪声方差
N0 = Eb/(10^(Eb_No_dB/10));
noiseVariance = N0/2;
% 生成高斯噪声并加到信号上
noise = sqrt(noiseVariance)*randn(size(symbols)) + 1i*sqrt(noiseVariance)*randn(size(symbols));
receivedSymbols = symbols + noise;

% 4. QPSK解调
receivedI = real(receivedSymbols) > 0;
receivedQ = imag(receivedSymbols) > 0;

% 将I和Q部分的解调数据重新组合成二进制序列
receivedData = zeros(2*numel(receivedI), 1);
receivedData(1:2:end) = receivedI;
receivedData(2:2:end) = receivedQ;

% 5. 计算误码率（BER）
errors = sum(data ~= receivedData);
BER = errors/N;

% 显示结果
fprintf('BER = %f\n', BER);

% 画图
figure;plot(real(symbols));title('原信号实部');
figure;plot(real(receivedSymbols));title('加噪后信号实部');
