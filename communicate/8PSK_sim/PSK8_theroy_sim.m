%% ************* 8PSK simulation ************* %%
%% ***** data:20240929 authoor:ShenYifu ****  %%
%% 参考资料《EPDT空中接口物理层和数据链路层》中物理层8PSK调制
%% 参考资料《GMSK、8PSK调制算法研究及ASIC实现》_肖妍妍
%% 参考资料《GSM/EDGE 与 8PSK调制信号性能比较》_罗宏杰
%%
clc;clear;
close all;
j = sqrt(-1);
%% 基本参数
% Rb = 50e3;
Rb = 1625*1e3/6;
sps = 8;
fs = sps * Rb;
Ts = 1 / fs;
Tb = 1 / Rb;
EbN0 = 30;
DEBUG = 0;
%% 8PSK调制

% 符号映射
base_bit1 = load('C:\Users\PC\Desktop\postgraduate\others\东方通信\8psk_dongfang\psk8_signal\50K.txt');
base_bit = [];
for i = 1 : 1
    base_bit = [base_bit base_bit1];
end
len = length(base_bit);
base_symbol = [];
k = 1;
for i = 1:3:len
    % 将每三个二进制元素转换为字符串
    binary_str = strcat(num2str(base_bit(i)), num2str(base_bit(i+1)), num2str(base_bit(i+2)));
    % 直接进行映射
    switch binary_str
        case '111'
            base_symbol(k) = 0;
        case '011'
            base_symbol(k) = 1;
        case '010'
            base_symbol(k) = 2;
        case '000'
            base_symbol(k) = 3;
        case '001'
            base_symbol(k) = 4;
        case '101'
            base_symbol(k) = 5;
        case '100'
            base_symbol(k) = 6;
        case '110'
            base_symbol(k) = 7;
        otherwise
            warning('未找到映射对应关系：%s', binary_str);
    end
    k=k+1;
end

% IQ调相
for k = 1: length(base_symbol)
    si(k) = exp(j*pi/4*base_symbol(k));
end

if DEBUG
    figure;scatter(real(si),imag(si));title("IQ调相星座图");
    figure;subplot(3,1,1);plot(real(si));title("IQ调相实部图");
    subplot(3,1,2);plot(imag(si));title("IQ调相虚部图");
    subplot(3,1,3);plot(fftshift( abs(fft(si,65536)) ));title("IQ调相信号频谱图");
    figure;plot(si);title("IQ调相信号矢量图");
end

% 旋转
for k = 1: length(si)
    s(k) = si(k).*exp(j*3*pi/8*k);
end

if DEBUG
    figure;scatter(real(s),imag(s));title("旋转之后星座图");
    figure;subplot(3,1,1);plot(real(s));title("旋转之后信号实部图");
    subplot(3,1,2);plot(imag(s));title("旋转之后信号虚部图");
    subplot(3,1,3);plot(fftshift( abs(fft(s,65536)) ));title("旋转之后信号频谱图");
    figure;plot(s);title("旋转之后信号矢量图");
end

if DEBUG
    phi = atan2(imag(s), real(s));  % 计算信号的相位
    phi_unwrapped = unwrap(phi);  % 解包相位
    figure;plot(phi_unwrapped);  % 绘制解包后的相位
    title('Unwrapped Phase of 8PSK Signal');
end

%% 成型滤波
s_real = real(s);
s_imge = imag(s);

rolloff_factor = 0.5;       % 滚降因子
rcos_fir = rcosdesign(rolloff_factor,2*sps,sps); % 默认是根升余弦滤波器,'sqrt'
% 插值
for k=1:length(s_real)
    up_sps_ds_real(1+sps*(k-1)) = s_real(k);
    up_sps_ds_real(2+sps*(k-1):sps*k) = zeros(1,sps-1);
    up_sps_ds_imag(1+sps*(k-1)) = s_imge(k);
    up_sps_ds_imag(2+sps*(k-1):sps*k) = zeros(1,sps-1);
end

if 0
    % 滚降滤波
    rcos_ds_real = filter(rcos_fir,1,up_sps_ds_real);
    rcos_ds_imag = filter(rcos_fir,1,up_sps_ds_imag);
    s_rcos = rcos_ds_real + j*rcos_ds_imag;
else
    C_0 = pulsefilter(Tb,Ts);
    for i = 1 : length(s_real)*sps
        y_temp = 0;
        for  k = 1 : length(s_real)
            index = i-k*(sps)+2.5*sps;
            if index < 1||index>length(C_0)
                continue;
            end
            c0temp = C_0(index);
            y_temp = y_temp + s(k)*c0temp;
        end
        s_rcos(i) = y_temp;
    end
    % rcos_ds_real = filter(C_0,1,up_sps_ds_real);
    % rcos_ds_imag = filter(C_0,1,up_sps_ds_imag);
    % s_rcos = rcos_ds_real + j*rcos_ds_imag;
end
% 复现论文《EDGE调制解调的ASIC设计与实现》_庞海朋 3.2.1节，没有实现
% for i = 1:10
%     if i == 1
%         figure;plot(abs(s_rcos((i-1)*sps+1:i*sps)));
%     else
%         hold on;plot(abs(s_rcos((i-1)*sps+1:i*sps)));
%     end
% end

if DEBUG
    figure;scatter(real(s_rcos),imag(s_rcos));title("成型之后星座图");
    figure;subplot(3,1,1);plot(real(s_rcos));title("成型之后信号实部图");
    subplot(3,1,2);plot(imag(s_rcos));title("成型之后信号虚部图")
    subplot(3,1,3);plot(fftshift(abs(fft(s_rcos,65536))));title("成型之后信号频谱图");
    figure;plot(s_rcos);title("成型之后信号矢量图");
end

%% 同步数据
synciq1 =  si(50+4+208+1 : 50+4+208+24);
synciq2 =  si(50+4+208+24+208+1 : 50+4+208+24+208+24);
synciq = [synciq1 zeros(1,208) synciq2];

Gp_start = s(1:50);
Tb_start = s(50+1:50+4);
sync1 =  s(50+4+208+1 : 50+4+208+24);
sync2 =  s(50+4+208+24+208+1 : 50+4+208+24+208+24);
Tb_end = s(50+4+208+24+208+24+208+1:50+4+208+24+208+24+208+4);
Gp_end = s(50+4+208+24+208+24+208+4+1:50+4+208+24+208+24+208+4+20);
sync = [sync1 zeros(1,208) sync2];

if DEBUG
    figure;subplot(2,1,1);stem(real(sync1));title("两段同步字对比图");
    subplot(2,1,2);stem(real(sync2));
end


%% 信道
send = repmat(s_rcos,1,10);   % 多帧处理
figure;subplot(2,1,1);plot(real(send));title("多帧信号实部图");
subplot(2,1,2);plot(imag(send));title("多帧信号虚部图");
noise = 1;
if noise
    % awgn信道
    Ebn0(1) = EbN0(1)-log(sps)/log(10)*10;
    send_signal = awgn(send,Ebn0(1),'measured');
    figure;subplot(2,1,1);plot(real(send_signal));title("多帧信号加噪后实部图");
    subplot(2,1,2);plot(imag(send_signal));title("多帧信号加噪后虚部图");
else
    send_signal = send;
    figure;subplot(2,1,1);plot(real(send_signal));title("多帧信号不加噪后实部图");
    subplot(2,1,2);plot(imag(send_signal));title("多帧信号不加噪后虚部图");
end


%% 8PSK解调
receive = send_signal;
% rcos_fir = [0 0 -0.003 0.138 -1.136 2.731 -1.136 0.138 -0.003 0 0];
%% 匹配滤波

if 0
    if 1
        
        % receive_real = filter(rcos_fir,1,real(receive));
        % receive_imag = filter(rcos_fir,1,imag(receive));
        % receive_rcos = receive_real + j*receive_imag;
        H_0 = conj(fliplr(C_0));
        receive_rcos = filter(H_0,1,receive);
        % receive_rcos = receive;
    else
        H_0 = matchedpulsefilter(Tb,Ts);
        receive_rcos = conv(receive,H_0,'same');
    end

    figure;scatter(real(receive_rcos),imag(receive_rcos));title("匹配滤波之后星座图");
    figure;plot(receive_rcos);title("匹配滤波之后信号矢量图");
    figure;subplot(3,1,1);plot(real(receive_rcos));title("多帧信号匹配滤波后实部图");
    subplot(3,1,2);plot(imag(receive_rcos));title("多帧信号匹配滤波后虚部图");
    subplot(3,1,3);plot(abs(fft(receive_rcos,65536)));title("多帧信号匹配滤波后频谱图");
else
    receive_rcos = receive;
end

%% 粗同步
synclen = length(sync);
realsignal = real(receive_rcos);
synci = real(sync);
for k = 1 : length(realsignal)-synclen*sps
    oneSync = realsignal(k:sps:k+synclen*sps-1);
    cor(k) = abs(oneSync*synci');
end
figure;plot(cor);title("粗同步滑动窗示意图");

% 搜索峰值
step_threshold = 20;
search_len = 25;
[sortvalue,sortindex] = sort(cor);
% 选择最值
relay_index1 = sortindex(end-search_len:end);
relay_index2(1) =  relay_index1(end);
kk = 1;
for k = length(relay_index1)-1 : -1 : 1
    if ~sum( abs(relay_index1(k)-relay_index2)<step_threshold )
        kk = kk + 1;
        relay_index2(kk) = relay_index1(k);
    else
        continue;
    end
end
[sort_value,sort_index] = sort(relay_index2);

% 确定帧头帧尾
signallen =  length(realsignal);
locarray = sort_value;
totalframelen = 750;
headdistanclen = 50+4+208;  % 根据EPDT协议而定

headframe = [];
tailframe = [];
for k = 1 : length(locarray)
    headframetemp = locarray(k) - headdistanclen*sps;
    tailframetemp = locarray(k)+(totalframelen - headdistanclen)*sps;
    if headframetemp<20 || tailframetemp> signallen-20
        fprintf("this burst is not complete!\n");
        continue;
    end
    headframe = [headframe headframetemp];
    tailframe = [tailframe tailframetemp];
end

%% 分帧处理
posA = [];
maxPosA = [];
posArraryA = [];
framestart = 208+4+50; % 根据8PSK帧结构而定
for i = 1 : 1
    framesignal = receive_rcos(headframe(i):tailframe(i));

    %% 符号同步
    maxC = 0; pos=0; maxR=0;
    meanA = mean(abs(framesignal));
    maxC = zeros(1,sps);
    posArray = zeros(1,sps);
    for ddcIdx=1:sps   % 1:18
        a = xcorr(framesignal(ddcIdx:sps:end),sync);  % 仅需滑动1~3个样点，主要是计算相位值maxC
        % figure;plot(abs(a));title("同步自相关示意图",ddcIdx);
        [maxV,p]=max(abs(a));
        maxR = maxV;
        pos = (p-length(framesignal(ddcIdx:sps:end))-framestart)*sps+ddcIdx;
        maxC(ddcIdx) = a(p);
        posArray(ddcIdx) = pos;

    end
    % 找最大峰值ddc位置
    [~,maxPos] = max(abs(maxC));
    maxPosA = [maxPosA,maxPos]; % 修改,记录maxPosA的值
    posArraryA = [posArraryA,posArray];
    pos = posArray(maxPos);
    posA = [posA,pos];  % 修改,记录posA的值
    if pos<1
        continue;  % 保护、防止程序崩溃
    end
    
    %% 相关补偿
    s_synchronization = framesignal(pos:sps:end)*maxC(maxPos)';
    % s_synchronization = framesignal(pos:sps:end);
    figure;subplot(3,1,1);plot(real(framesignal));title("精同步前输入信号实部图");
    subplot(3,1,2);plot(real(framesignal(pos:sps:end)));title("精同步后补偿前实部图");
    subplot(3,1,3);plot(real(s_synchronization));title("精同步后补偿后实部图");

    %% 解旋
    rotsignal = s_synchronization;
    if framestart == 208+4+50
        k = 1 : 750;
        ppp = exp(-1i*3*pi/8*k);
        for k = 1 : length(ppp)
            s_derot(k) = rotsignal(k).*ppp(k);
        end
    end
    figure;subplot(3,1,1);plot(real(rotsignal));title("解旋前信号实部图");
    subplot(3,1,2);plot(real(s_derot));title("解旋后信号实部图");
    subplot(3,1,3);plot(imag(s_derot));title("解旋后信号虚部图");
    figure;scatter(real(s_derot),imag(s_derot));title("解旋后信号星座图");
    
    %% 相关补偿
    a1 = xcorr(s_derot,synciq);  % 仅需滑动1~3个样点，主要是计算相位值maxC
    figure;plot(abs(a1));title("相关示意图图")
    [maxV1,p1]=max(abs(a1));
    maxC1 = a1(p1);
    s_compensation = s_derot.*maxC1';
    figure;subplot(3,1,1);plot(real(s_derot));title("补偿前输入信号实部图");
    subplot(3,1,2);plot(real(s_compensation));title("补偿后信号实部图");
    subplot(3,1,3);plot(imag(s_compensation));title("补偿后信号虚部图");

    %% 解映射
    demap = s_compensation;
    I = real(demap);
    Q = imag(demap);
    theta = atan2(Q,I);
    theta(theta<0) =theta(theta<0)+2*pi;
    for i = 1 : 1 : length(I)
        theta_temp = theta(i);
        % 符号判决的范围[kπ/4 - π/8, kπ/4 + π/8)
        if (theta_temp >= 0 && theta_temp <pi/8)
            y(i)=0;
        elseif (theta_temp >= pi/8 && theta_temp < 3*pi/8)%pi/4-4pi/8
            y(i)=1;
        elseif (theta_temp >= 3*pi/8 && theta_temp < 5*pi/8)%4*pi/8-6*pi/8
            y(i)=2;
        elseif (theta_temp >= 5*pi/8 && theta_temp < 7*pi/8)%6pi/8-8pi
            y(i)=3;
        elseif (theta_temp >= 7*pi/8 && theta_temp < 9*pi/8)%
            y(i)=4;
        elseif (theta_temp >= 9*pi/8 && theta_temp < 11*pi/8)%
            y(i)=5;
        elseif (theta_temp >= 11*pi/8 && theta_temp < 13*pi/8)%
            y(i)=6;
        elseif (theta_temp >= 13*pi/8 && theta_temp < 15*pi/8)%
            y(i)=7;
        elseif (theta_temp >= 15*pi/8 )
            y(i)=0;
        end
    end
    c_symbol_N = y;

    errorsymbol = sum(c_symbol_N~=base_symbol); 
    fprintf("误符号率为：%.6f\n",errorsymbol/length(c_symbol_N));
    figure;stem(c_symbol_N(1:end));hold on;stem(base_symbol(1:end));title("解调输出符号对比图");
    % figure;plot(y);hold on ;plot(0.95*base_symbol);title("解调输出符号对比示意图");

    %% 误码率
    deoutbit = zeros(1,3*length(y));
    for i = 1 : length(y)
        if y(i) == 0
            deoutbit( 1+(i-1)*3:i*3 ) = [1 1 1];  
        elseif y(i) == 1
            deoutbit( 1+(i-1)*3:i*3 ) = [0 1 1];
        elseif y(i) == 2
            deoutbit( 1+(i-1)*3:i*3 ) = [0 1 0];
        elseif y(i) == 3
            deoutbit( 1+(i-1)*3:i*3 ) = [0 0 0];
        elseif y(i) == 4
            deoutbit( 1+(i-1)*3:i*3 ) = [0 0 1];
        elseif y(i) == 5
            deoutbit( 1+(i-1)*3:i*3 ) = [1 0 1];
        elseif y(i) == 6
            deoutbit( 1+(i-1)*3:i*3 ) = [1 0 0];
        elseif y(i) == 7
            deoutbit( 1+(i-1)*3:i*3 ) = [1 1 0];
        end
    end
    errorbit = sum(deoutbit~=base_bit1); 
    fprintf("误比特率为：%.6f\n",errorbit/length(base_bit1));
    figure;stem(deoutbit(1:end));hold on;stem(base_bit1(1:end));title("解调输出比特对比图");

end

cross_correlation = xcorr(base_symbol,c_symbol_N);
figure;plot(abs(cross_correlation));title("cross correlation");
nfft = 4096;
fft1 = fft(base_symbol,nfft);
fft2 = fft(c_symbol_N,nfft);
fft3 = abs(fft(fft2.*conj(fft1),nfft));
figure;plot(fft3);title("自相关效果图");