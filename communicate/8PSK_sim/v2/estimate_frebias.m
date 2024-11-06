% 二倍频估计频偏--针对EDGE中8PSK调制
% 事先利用cftool拟合出没有频偏时rb与fft峰值对应索引关系
function [fcest] = estimate_frebias(edge8psk,rb,fs)
M = 2;
nfft = 8192*2;
orignalfftpeak = rb*0.3711+4.5678;  % cftool工具拟合曲线 
squeres = edge8psk.^M;
fftsignal = fft(squeres,nfft);
[~,maxindex] = max(fftsignal);
currentfftpeak = maxindex*fs/nfft;
fcest = (currentfftpeak-orignalfftpeak)/M;
end