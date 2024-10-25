%% ************* GMSK simulation v2 ************* %%
%% ***** data:20241003 authoor:ShenYifu ****  %%
%% 参考资料《GSMsim - A MATLAB Implementation of a GSM Simulation Platform》
%% 参考资料《GSM接收机均衡算法研究与DSP实现》-田雨
%%
%%
close all;
clc;clear;
j = sqrt(-1);
%% 基本信息
Rb = 25e3;                       %%码速
fc = 500;                        %%载频
SNR = 1;                         %%信噪比
OSR = 16;
fs = OSR * Rb;                    %%采样率
Ts = 1 / fs;                      %%采样周期
Tb = 1/Rb;
BT = 0.3;
%% 数据帧结构

% 底码数据 来源东方通信
load("data.mat"); 
basedata = code2;
% 信息比特

%
TSC1 = basedata(25+3+1 : 25+3+1+ 16-1);            
TSC2 = basedata(25+3+16+99+1 : 25+3+16+99+1+ 16-1);            
SYNC1 = basedata(25+3+16+99+16+99+1 : 25+3+16+99+16+99+1+ 16-1); 
SYNC2 = basedata(25+3+16+99+16+99+16+99+1 : 25+3+16+99+16+99+16+99+1+ 16-1); 
SYNC3 = basedata(25+3+16+99+16+99+16+99+16+99+1 : 25+3+16+99+16+99+16+99+16+99+1+ 16-1);
TSC3 = TSC1;            
TSC4 = TSC2; 

% 粗同步和精同步数据
% 粗同步数据
syncD = [SYNC1 SYNC2 SYNC3];
syncEncode = syncD;    
syncPolarDif1 = 1-2*syncEncode;
syncPolarDif = [syncPolarDif1(1:16) zeros(1,99) syncPolarDif1(17:32) zeros(1,99) syncPolarDif1(33:48)];

% 精同步数据
% 输入底码差分译码后数据
Differential_decoding = basedata;
diff_decode(1) = Differential_decoding(1);
for n = 2:length(Differential_decoding) 
    diff_decode(n) = xor(Differential_decoding(n), diff_decode(n-1));
end
SYNC1 = diff_decode(25+3+16+99+16+99+1 : 25+3+16+99+16+99+1+ 16-1); 
SYNC2 = diff_decode(25+3+16+99+16+99+16+99+1 : 25+3+16+99+16+99+16+99+1+ 16-1); 
SYNC3 = diff_decode(25+3+16+99+16+99+16+99+16+99+1 : 25+3+16+99+16+99+16+99+16+99+1+ 16-1);
syncDE_relay = 1-2*[SYNC1 SYNC2 SYNC3];
syncDE =[syncDE_relay(1:16) zeros(1,99) syncDE_relay(17:32) zeros(1,99) syncDE_relay(33:48)];

% 信号解旋后对比底码数据
diff_decode_info = diff_decode(21:end-13);
diff_decode_info1 = diff_decode(26:end-13);  

% 有效底码数据
basedata_info = basedata(26:end-13);

%% GMSK调制
base_symbol = [basedata basedata basedata basedata];
code = base_symbol;
[data] =GMSK_Mod(code,OSR,Tb,BT);
data = data(OSR*3+1:end-OSR);

%% 信道
% snr = SNR - 10*log(OSR)/log(10);
data = awgn(data,SNR,"measured");
%% 接收机

%% 匹配滤波
[G,~] = ph_g(Tb,OSR,BT);
G=G(OSR:end-OSR);
q = zeros(size(G));
for idx=1:length(G)
    q(idx) = sum(G(1:idx));
end
q = q/(q(end)-q(1));
T=OSR;
q3 = q;
u = zeros(1,length(q3)*2);
u = [q3 q3(end:-1:1)];
c = sin(0.5*pi-0.5*pi*q)/sin(0.5*pi);
for t=1:5*T-1
    pos = mod(abs(t),5*T)+1;
    if pos<3*T        
        cT = c(pos);
    else
        cT = 0;
    end

    pos = mod(abs(t-T),5*T)+1;
    if pos<3*T        
        c_T = c(pos);
    else
        c_T = 0;
    end

    pos = mod(abs(t-2*T),5*T)+1;
    if pos<3*T        
        c_2T = c(pos);
    else
        c_2T = 0;
    end

    pos = mod(abs(t-3*T),5*T)+1;
    if pos<3*T        
        c_3T = c(pos);
    else
        c_3T = 0;
    end

    pos = mod(abs(t-4*T),5*T)+1;    
    if pos<3*T        
        c_4T = c(pos);
    else
        c_4T = 0;
    end  

    h0(t+1) = c_4T*c_3T*c_2T*c_T;
    h1(t+1) = c_T*c_2T*c_4T*cT;
end

h0 = h0(22:end-20);% 22:end-20
h1 = h1(22:end-38);
receive = conv(data,h0);
% figure;subplot(2,1,1);plot(real(data));title("过C0滤波器前信号实部效果图");
% subplot(2,1,2);plot(real(receive));title("过C0滤波器后信号实部效果图");
%% 二次方谱估计频偏
N =65536;
fftsignal =abs(fft(data.^2,N));
[maxnum,loc]= max(fftsignal(1:N/2));
fcest =((loc-1)*fs/N-Rb/2)/2;
% figure;plot(fs.*(0:N-1)/N,fftsignal);title("GMSK信号的平方谱");

%% 粗同步搜索  
% r0n = data;
r0n = receive;
dif1 = imag(r0n(1:end-OSR).*conj(r0n(OSR+1:end))); 
synclen = length(syncPolarDif);
for k = 1 : length(dif1)-synclen*OSR
    oneSync = dif1(k:OSR:k+synclen*OSR-1);
    cor(k) = abs(oneSync*syncPolarDif');
end
% figure;plot(cor);title("滑动窗示意图");

[headArray,corrArray,flag] = EPDT_coarseSync_v2(r0n,syncPolarDif,OSR);
%% 分帧处理
burstResult = [];
posA = [];
maxPosA = [];
posArraryA = [];
for headIdx=1:length(headArray)
    head = headArray(headIdx);
    distance = 3+(16+99)*2 ;
    frameHead = head - distance*OSR;    % 578根据协议帧结构位置决定
    fprintf('burst = %d, framehead=%d, ',headIdx,frameHead);

    start_loc = frameHead - OSR*5;
    end_loc = frameHead + 712*OSR+OSR*5-1;

    if start_loc < 1
        disp('this burst is not a full  burst!  framehead=%d\n');
        continue;
    end

    r0n_buf = r0n(start_loc : end_loc);
    % figure;subplot(2,1,1);plot(real(r0n));title("原始信号实部图");
    % subplot(2,1,2);plot(real(r0n_buf));title(sprintf("粗同步后实部图\n启始点位置%d 结束点位置%d",start_loc,end_loc) );
    F0 = fcest;
    %% 去频偏
    r0n_coarseFOcomp = zeros(size(r0n_buf));
    t = 1:length(r0n_buf);
    r0n_coarseFOcomp = r0n_buf.*exp(-1j*2*pi*F0.*t/fs);
    r0n_buf = r0n_coarseFOcomp;

    %% 解旋v2
    % 用解旋后的数据，按BPSK调制符号的平方算法来计算频偏
    relay_result = [];
    % 参考论文：《GMSK无线电数字接收机的算法研究》-乔晓峰
    s_dot = r0n_buf(1,1:end);
    de_spin_sequence = [-j,-1,j,1];
    de_spin_sequence_sps = repmat(de_spin_sequence,OSR,1);
    de_spin_sequence_sps = de_spin_sequence_sps(:).';
    seq_len = length(de_spin_sequence_sps);

    % 查找解旋同步位置
    N = 20;                                     % 选取N*4个符号做解旋同步
    s_dot_temp1 = s_dot(1:seq_len*N);
    s_dot_temp = reshape(s_dot_temp1,seq_len,N).';
    for k = 1 : seq_len/2
        relay_result1 = s_dot_temp.* circshift(de_spin_sequence_sps,-k+1);
        relay_result2 = relay_result1.';
        relay_result(k,:) = relay_result2(:).';
    end
    real_temp = real(relay_result).^2;
    real_temp2 = sum(real_temp,2);
    imag_temp = imag(relay_result).^2;
    imag_temp2 = sum(imag_temp,2);
    diff_temp = real_temp2 - imag_temp2;

    % figure;subplot(3,1,1);stem(real_temp2); title("解旋遍历实部平方和");
    % subplot(3,1,2);stem(imag_temp2); title("解旋遍历虚部平方和");
    % subplot(3,1,3);stem(diff_temp); title("解旋遍历实部和虚部平方和之差");
    [value,index] = max(diff_temp);
    
    % 解旋
    de_spin_sequence_sps1 = circshift(de_spin_sequence_sps,-index);
    reali = real(s_dot);
    imagq = imag(s_dot);
    for k = 1 : floor(length(s_dot)/seq_len)
        s_dot1(1+(k-1)*seq_len : k*seq_len) = s_dot(1+(k-1)*seq_len : k*seq_len).*de_spin_sequence_sps1;
    end
    % figure;subplot(2,1,1);plot(real(s_dot));title("解旋前后信号实部图");
    % subplot(2,1,2);plot(real(s_dot1));
    % figure;subplot(2,1,1);plot(imag(s_dot));title("解旋前后信号虚部图");
    % subplot(2,1,2);plot(imag(s_dot1));

    diff_decode_sps = repmat(diff_decode_info,OSR,1);
    diff_decode_sps = diff_decode_sps(:).';
    figure;stem(-1+2*diff_decode_sps);hold on;stem(0.5*real(s_dot1(2:end)));title("解旋信号实部与底码差分译码后数据对比图");
    figure;stem(-1+2*diff_decode_sps);hold on;stem(0.1*imag(s_dot1(3:end)));title("解旋信号虚部与底码差分译码后数据对比图");
    % figure;stem(-1+2*diff_decode_sps);hold on;stem(0.1*reali1(5:end));title("解旋信号实部与底码对比图1");
    % figure;stem(-1+2*diff_decode_sps);hold on;stem(0.1*imagq1(5:end));title("解旋信号虚部与底码对比图1");

    %% 
    cor = [];
    r0n_deRot = s_dot1;
    synclen = length(syncDE);
    for k = 1 : length(r0n_deRot)-synclen*OSR
        oneSync = r0n_deRot(k:OSR:k+synclen*OSR-1);
        cor(k) = abs(oneSync*syncDE');
    end
    % figure;plot(cor);title("滑动窗示意图");
    

    %% 精同步和相关补偿
    r0n_deRot_FOcomp = r0n_deRot;
    maxC = 0; pos=0; maxR=0;
    meanA = mean(abs(r0n_deRot_FOcomp));
    maxC = zeros(1,OSR);
    posArray = zeros(1,OSR);
    for ddcIdx=1:OSR   % 1:18
        a = xcorr(r0n_deRot_FOcomp(ddcIdx:OSR:end),syncDE);  % 仅需滑动1~3个样点，主要是计算相位值maxC
        % figure;plot(abs(a));title("同步自相关示意图",ddcIdx);
        [maxV,p]=max(abs(a));
        maxR = maxV;
        pos = (p-length(r0n_deRot_FOcomp(ddcIdx:OSR:end))-233)*OSR+ddcIdx;
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

    % 相关补偿
    r0n_16k = r0n_deRot_FOcomp(pos:OSR:end)*maxC(maxPos)';
    % figure;subplot(3,1,1);plot(real(r0n_deRot_FOcomp));title("精同步前输入信号实部图");
    % subplot(3,1,2);plot(real(r0n_deRot_FOcomp(pos:OSR:end)));title("精同步后补偿前实部图");
    % subplot(3,1,3);plot(real(r0n_16k));title("精同步后补偿后实部图");

    soft = (real(r0n_16k(1:712))); % 根据帧结构调整

    % 解调输出与GMSK调制前数据的差分译码作对比
    out1 = (soft<0);
    errlen = length(diff_decode_info1);
    biterr(headIdx) = sum(abs(out1(1:errlen)-diff_decode_info1)); % biterr(headIdx)
    % fprintf('errorbitnum = %d,fer =%f\n',biterr(headIdx),biterr(headIdx)/errlen);

    % 解调输出差分编码后与GMSK调制前数据对比
    out2 = soft>0;
    diffout = [1-out2(1) mod(out2(1:end-1)+out2(2:end),2)];
    errlen = length(basedata_info);
    biterr1(headIdx) = sum(abs(diffout(1:errlen)-basedata_info)); % biterr(headIdx)
    fprintf('errorbitnum = %d,fer =%f\n',biterr1(headIdx),biterr1(headIdx)/errlen);

end
fprintf('demodulation result compare with differential encoding result : totalber = %f\n',sum(biterr/errlen)/headIdx);     
fprintf('demodulation result compare with differential decoding result : totalber = %f\n',sum(biterr1/errlen)/headIdx);