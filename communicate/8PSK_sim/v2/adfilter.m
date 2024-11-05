function [CIR] = adfilter(traning,rxiq,w,Mu)
j = sqrt(-1);
% 输入：traning 用于训练的标准序列
% 输入：rxip 用于训练的序列
% 输入：自适应滤波器系数-初始化为全零且为7阶
traninglen = length(traning);
N  = length(w);
len = length(rxiq) - (N-1);
for k = 1 : 3
    for n =  1 : len
        in = traning(n+N-1: -1: n);
        % 标准训练序列码经过自适应滤波器后的复数值
        y = in*w'/N;
        e(len*(k-1)+n) = conj( conj(rxiq(n))-y );
        w = Mu*e(len*(k-1)+n)*in + w;
    end
end
CIR = w;
% figure;plot(abs(e));title("LMS误差输出");
end