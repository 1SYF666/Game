%% ************* GMSK simulation v2 ************* %%
%% ***** data:20241003 authoor:ShenYifu ****  %%
%% 参考资料《GSMsim - A MATLAB Implementation of a GSM Simulation Platform》
%% 参考资料《GSM接收机均衡算法研究与DSP实现》-田雨
%%
%%
close all;
clc;clear;
%% 基本信息
Rb = 25e3;                       %%码速
fc = 500;                        %%载频
SNR = 6;                         %%信噪比
OSR = 16;
fs = OSR * Rb;                    %%采样率
Ts = 1 / fs;                      %%采样周期
Tb = 1/Rb;
BT = 0.3;
%% 数据帧结构

% 底码数据 来源东方通信
load("data.mat"); 
% 输入底码差分译码后数据
Differential_decoding = code2;
diff_decode(1) = Differential_decoding(1);
for n = 2:length(Differential_decoding) 
    diff_decode(n) = xor(Differential_decoding(n), diff_decode(n-1));
end
% 信息比特
diff_decode_info = diff_decode(26:end-13);

TSC1 = diff_decode(25+3+1 : 25+3+1+ 16-1);            
TSC2 = diff_decode(25+3+16+99+1 : 25+3+16+99+1+ 16-1);            
SYNC1 = diff_decode(25+3+16+99+16+99+1 : 25+3+16+99+16+99+1+ 16-1); 
SYNC2 = diff_decode(25+3+16+99+16+99+16+99+1 : 25+3+16+99+16+99+16+99+1+ 16-1); 
SYNC3 = diff_decode(25+3+16+99+16+99+16+99+16+99+1 : 25+3+16+99+16+99+16+99+16+99+1+ 16-1);
TSC3 = TSC1;            
TSC4 = TSC2; 

% 粗同步和精同步数据
% 粗同步数据
syncD = [SYNC1 SYNC2 SYNC3];
syncEncode = [1-syncD(1) mod(syncD(1:end-1)+syncD(2:end),2)];    % 差分编码
% syncEncode = syncD;    
syncPolarDif1 = 1-2*syncEncode;
syncPolarDif = [syncPolarDif1(1:16) zeros(1,99) syncPolarDif1(17:32) zeros(1,99) syncPolarDif1(33:48)];

% 精同步数据
syncDE_relay = 1-2*[SYNC1 SYNC2 SYNC3];
syncDE =[syncDE_relay(1:16) zeros(1,99) syncDE_relay(17:32) zeros(1,99) syncDE_relay(33:48)];

%% GMSK调制
base_symbol = [diff_decode diff_decode diff_decode diff_decode];
code = 1-2*base_symbol;
[data] =GMSK_Mod(code,OSR,Tb,BT);
data = data(OSR*3+1:end-OSR);

%% 信道

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
figure;subplot(2,1,1);plot(real(data));title("过C0滤波器前信号实部效果图");
subplot(2,1,2);plot(real(receive));title("过C0滤波器后信号实部效果图");
%% 二次方谱估计频偏
N =65536;
fftsignal =abs(fft(data.^2,N));
[maxnum,loc]= max(fftsignal);
fcest =((loc-1)*fs/N-Rb/2)/2;
figure;plot(fs.*(0:N-1)/N,fftsignal);title("GMSK信号的平方谱");

%% 粗同步搜索  
r0n = data;
dif1 = imag(r0n(1:end-OSR).*conj(r0n(OSR+1:end))); 
synclen = length(syncPolarDif);
for k = 1 : length(dif1)-synclen*OSR
    oneSync = dif1(k:OSR:k+synclen*OSR-1);
    cor(k) = abs(oneSync*syncPolarDif');
end
figure;plot(cor);title("滑动窗示意图");

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
    figure;subplot(2,1,1);plot(real(r0n));title("原始信号实部图");
    subplot(2,1,2);plot(real(r0n_buf));title(sprintf("粗同步后实部图\n启始点位置%d 结束点位置%d",start_loc,end_loc) );
    F0 = fcest;
    %% 去频偏
    r0n_coarseFOcomp = zeros(size(r0n_buf));
    t = 1:length(r0n_buf);
    r0n_coarseFOcomp = r0n_buf.*exp(-1j*2*pi*F0.*t/fs);
    r0n_buf = r0n_coarseFOcomp;

    %% 解旋
    % 用解旋后的数据，按BPSK调制符号的平方算法来计算频偏
    % roSbase = [-1j,-1,1j,1];
    % roSbase = circshift(roSbase,-3);
    roSbase = [-1j,1,1j,-1];
    roS = repmat(roSbase,OSR,1);
    roS = roS(:).';
    r0n_deRot = [];
    bufLen = OSR-mod(length(r0n_buf),OSR);
    r0n_buf = [r0n_buf zeros(1,bufLen)];
    r0n_16k_beforeRot = reshape(r0n_buf,OSR,[]);
    
    % for ddcIdx=1:OSR
    %     % deRot
    %     r0n_16k_deRot(ddcIdx,:) = r0n_16k_beforeRot(ddcIdx,:).*roSbase(mod(ddcIdx+(0:size(r0n_16k_beforeRot,2)-1),4)+1);
    % end
    % r0n_16k_deRot_mi2 = r0n_16k_deRot.^2; %用于精估频偏
    % 
    for startPos=1:1:OSR
        r0n_deRot = [];
        for dataIdx=startPos:4*OSR:length(r0n_buf)-4*OSR+1 % -71
            tmp = r0n_buf(dataIdx:dataIdx+4*OSR-1).*roS;
            r0n_deRot = [r0n_deRot tmp];
        end
        % mi2 = r0n_deRot.^2; %用于同步
    end
    
    %
    figure;subplot(2,1,1);plot(real(r0n_buf));title("解旋前后对比图");
    subplot(2,1,2);plot(real(r0n_deRot));

    diff_decode_sps = repmat(diff_decode_info,OSR,1);
    diff_decode_sps = diff_decode_sps(:).';
    figure;plot(-1+2*diff_decode_sps(10:end));hold on;plot(real(r0n_deRot(81:end)));title("解旋信号实部与底码对比图");

    %% 解旋v2
    cor = [];
    r0n_deRot = r0n_deRot;
    synclen = length(syncDE);
    for k = 1 : length(r0n_deRot)-synclen*OSR
        oneSync = r0n_deRot(k:OSR:k+synclen*OSR-1);
        cor(k) = abs(oneSync*syncDE');
    end
    figure;plot(cor);title("滑动窗示意图");



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
    figure;subplot(3,1,1);plot(real(r0n_deRot_FOcomp));title("精同步前输入信号实部图");
    subplot(3,1,2);plot(real(r0n_deRot_FOcomp(pos:OSR:end)));title("精同步后补偿前实部图");
    subplot(3,1,3);plot(real(r0n_16k));title("精同步后补偿后实部图");

    soft = (real(r0n_16k(1:712))); % 根据帧结构调整
    out1 = (soft.'>0)*2-1;
    errlen = length(diff_decode_info);
    biterr(headIdx) = sum(abs((out1(1:errlen).'<0)-diff_decode_info)); % biterr(headIdx)
    fprintf('errorbitnum = %d,fer =%f\n',biterr(headIdx),biterr(headIdx)/errlen);

end
fprintf('totalber = %f\n',sum(biterr/errlen)/headIdx);
