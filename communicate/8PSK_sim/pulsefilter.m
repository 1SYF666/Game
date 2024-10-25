%% ************* 8PSK Pulse shaping simulation ************* %%
%% ************ data:20241016 authoor:ShenYifu ************  %%
%% 参考资料《GMSK、8PSK调制算法研究及ASIC实现》_肖妍妍
%% 参考资料《GSM/EDGE 与 8PSK调制信号性能比较》_罗宏杰
%% 参考资料《GSM 05.04 version 8.1.2 Release 1999》_ETSI EN 300 959 V8.1.2 (2001-02)
function [c_0_t] = pulsefilter(T,Ts)
t =  0:Ts:5*T;
log2_val = log(2); % log(2)常数
% 定义 Q(x) 函数
Q_func = @(x) 0.5 * erfc(x / sqrt(2));
% 定义g(t) (论文公式2-26)
g_t = @(t) ( ( Q_func( 2*pi*0.3*(t-5*T/2)/(T*log2_val) ) - Q_func( 2*pi*0.3*(t-3*T/2)/(T*log2_val) ) )*(1/(2*T)) );
% 定义S(t) (论文公式2-25)
S1 = @(t) (sin(pi*integral(g_t, 0, t)));
S2 = @(t) (sin(pi/2 - pi*integral(g_t, 0, t - 4*T)));

% 定义成型滤波器c_0(t) (论文公式2-24)
c_0_t = zeros(size(t));
for i = 1:length(t)
    if t(i) >= 0 && t(i) <= T
        c_0_t(i) = S1(t(i))*S1(t(i)+T)*S1(t(i)+2*T)*S1(t(i)+3*T);
    elseif t(i) >T && t(i) <= 2*T
        c_0_t(i) = S1(t(i))*S1(t(i)+T)*S1(t(i)+2*T)*S2(t(i)+3*T);
    elseif t(i) >2*T && t(i) <= 3*T
        c_0_t(i) = S1(t(i))*S1(t(i)+T)*S2(t(i)+2*T)*S2(t(i)+3*T);
    elseif t(i) >3*T && t(i) <= 4*T
        c_0_t(i) = S1(t(i))*S2(t(i)+T)*S2(t(i)+2*T)*S2(t(i)+3*T);
    elseif t(i) >4*T && t(i) <= 5*T
        c_0_t(i) = S2(t(i))*S2(t(i)+T)*S2(t(i)+2*T)*S2(t(i)+3*T);
    else
        c_0_t(i) = 0;
    end
end
% % 绘制成型滤波器c_0(t)
% figure;
% plot(t, c_0_t);
% title('Pulse Shaping Filter c_0(t)');
% xlabel('Time');
% ylabel('Amplitude');
% grid on;

end

