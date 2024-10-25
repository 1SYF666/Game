%% ************* GMSK simulation v1 ************* %%
%% ***** data:20241003 authoor:ShenYifu ****  %%
%% 参考资料《GSMsim - A MATLAB Implementation of a GSM Simulation Platform》
%% 参考资料《GSM接收机均衡算法研究与DSP实现》-田雨
close all;
clc;clear all;
%% 基本信息
Rb = 50e3;                      
fc = 500;                         
SNR = 6;                        
OSR = 12;
fs = OSR * Rb;                      
Ts = 1 / fs;                     
Tb = 1/Rb;
BT = 0.3;
%% 数据帧结构
if 1
    % gap1 & gap2
    Simulation_Length_gap1 = 25;
    Sample_Length_gap1 = Simulation_Length_gap1 * round(Tb / Ts);
    GP1 = ones(1,Simulation_Length_gap1);

    Simulation_Length_gap2 = 13;
    Sample_Length_gap2 = Simulation_Length_gap2 * round(Tb / Ts);
    GP2 = zeros(1,Simulation_Length_gap2);
    % 基本信息
    Simulation_Length_Tb1 = 3;        %%尾比特区域1（前）
    Simulation_Length_signal = 99;    %%6个有效载荷长度皆为99
    Simulation_Length_sync = 16;      %%3个同步字长度皆为16
    Simulation_Length_TSC = 16;       %%4个训练序列区域皆为16
    Simulation_Length_Tb2 = 3;        %%尾比特区域2（后）
    Simulation_Length_all = Simulation_Length_gap1 + Simulation_Length_Tb1 + Simulation_Length_signal*6 + ...
        Simulation_Length_TSC*4 + Simulation_Length_sync*3 + Simulation_Length_Tb2 + ...
        Simulation_Length_gap2; %% 通用突发长度
    Sample_Length = Simulation_Length_all * round(Tb / Ts);              %%总共采样点数
    AllS = int32(Sample_Length);      %%int32的采样点数
    time = Simulation_Length_all * Tb; %%信号维持时间长度

    % 映射
    Tb1 = zeros(1, Simulation_Length_Tb1);               % Tb区域1
    Tb2 = zeros(1, Simulation_Length_Tb2);               % Tb区域2
    TSC1 = [1 1 1 1  0 1 0 0  0 1 0 0  1 0 1 0];            % TSC第一组，前16位
    TSC2 = [1 1 0 0  0 0 1 1  1 0 0 1  1 0 1 1];            % TSC第二组，后16位
    Payload1 = randi([0,1],1,Simulation_Length_signal);  % 有效载荷1
    Payload2 = randi([0,1],1,Simulation_Length_signal);  % 有效载荷2
    Payload3 = randi([0,1],1,Simulation_Length_signal);  % 有效载荷3
    Payload4 = randi([0,1],1,Simulation_Length_signal);  % 有效载荷4
    Payload5 = randi([0,1],1,Simulation_Length_signal);  % 有效载荷5
    Payload6 = randi([0,1],1,Simulation_Length_signal);  % 有效载荷6
    SYNC1 = [0 1 0 0  1 1 0 1  0 0 1 1  1 1 0 0];           % 同步字1
    SYNC2 = [0 1 0 1  1 0 0 1  1 1 0 0  1 1 0 1];           % 同步字2
    SYNC3 = [0 0 1 1  1 1 0 0  0 1 0 1  1 0 0 1];           % 同步字3
    code2 = [GP1 Tb1 TSC1 Payload1 TSC2 Payload2 SYNC1 Payload3 ...
        SYNC2 Payload4 SYNC3 Payload5 TSC1 Payload6 TSC2 Tb2 GP2] ;
    information_bits =[Tb1 TSC1 Payload1 TSC2 Payload2 SYNC1 Payload3 ...
        SYNC2 Payload4 SYNC3 Payload5 TSC1 Payload6 TSC2 Tb2];
    % 粗同步和精同步数据
    % 粗同步数据
    syncD = TSC1;
    syncE = 1-2*syncD;
    syncEncode = [1-syncD(1) mod(syncD(1:end-1)+syncD(2:end),2)];
    syncPolarDif = 1-2*syncEncode;
    % 精同步数据
    syncDE_relay = 1-2*[SYNC1 SYNC2 SYNC3];
    syncDE =[syncDE_relay(1:16) zeros(1,99) syncDE_relay(17:32) zeros(1,99) syncDE_relay(33:48)];

end
%% GMSK调制
base_symbol = [code2 code2 code2 code2];
code = 1-base_symbol*2;
[data] =GMSK_Mod(code,OSR,Tb,BT);
data = data(OSR*3+1:end-OSR);
% figure;subplot(2,1,1);plot(real(data));title("GMSK调制信号实部图");
% subplot(2,1,2);plot(imag(data));title("GMSK调制信号虚部图");
%% 发射机
t = (0:length(data)-1)*Ts;
data= data.*exp(1i*2*pi*fc*t);
%% 信道
data = awgn(data,SNR,"measured");
%% 接收机
%% 匹配滤波
% load g.mat
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
% receive = conv(data,h0);
receive = data;
%% 二次方谱去载波
N = 65536;
fftsignal =abs(fft(receive.*receive,N));
[maxnum,loc]= max(fftsignal(1:N/2));
fcest =((loc-1)*fs/N-Rb/2)/2;
t = (0:length(receive)-1)*Ts;
receive= receive.*exp(-1i*2*pi*fcest*t);
figure;plot(fs.*(0:N-1)/N,fftsignal); title("GMSK信号平方谱");

%% 粗同步搜索 
r0n = receive;
[headArray,corrArray,flag] = EPDT_coarseSync_v1(r0n,syncPolarDif,OSR);
%% 分包处理
burstResult = [];
posA = [];
maxPosA = [];
posArraryA = [];
for headIdx=1:length(headArray) % 确定包头的位置
    head = headArray(headIdx);
    frameHead = head-3*OSR; % 根据协议包头位于TSC1前3bit
    fprintf('burst = %d, frameHead=%d, ',headIdx,frameHead);
    
    if frameHead < 9
        disp('this burst is not a full  burst!  frameHead=%d\n');
        continue;
    end

    start_loc = frameHead - OSR*5;
    end_loc = frameHead + 712*OSR+OSR*5-1;
    r0n_buf = r0n(start_loc : end_loc);  
    figure;subplot(2,1,1);plot(real(r0n));title("原始信号实部图");
    subplot(2,1,2);plot(real(r0n_buf));title(sprintf("粗同步后实部图\n启始点位置%d 结束点位置%d",start_loc,end_loc) );
    % %% 粗频偏估计
    % [timePos,F0] = cugu(r0n_buf,sync288k(1:18:end),0.7);  % s有改动0.64
    % compancate = F0;
    % % F0=0;
    % 
    % %% 粗频偏补偿
    % r0n_coarseFOcomp = zeros(size(r0n_buf));
    % t = 1:length(r0n_buf);
    % r0n_coarseFOcomp = r0n_buf.*exp(-1j*2*pi*F0.*t/fs);
    % r0n_buf = r0n_coarseFOcomp;  

    %% 解旋
    % 用解旋后的数据，按BPSK调制符号的平方算法来计算频偏
    % roSbase = [-1j,-1,1j,1];
    roSbase = [-1j,1,1j,-1];
    % 因为每个符号有18个采样点，故连续18个数据乘以同一个值，获得旋转后的值
    roS = repmat(roSbase,OSR,1); 
    roS = roS(:).';
    r0n_deRot = [];
    r1n_deRot = [];

    bufLen = OSR-mod(length(r0n_buf),OSR);
    r0n_buf = [r0n_buf zeros(1,bufLen)];
    %%
    r0n_16k_beforeRot = reshape(r0n_buf,OSR,[]);
    for ddcIdx=1:OSR
        r0n_16k_deRot(ddcIdx,:) = r0n_16k_beforeRot(ddcIdx,:).*roSbase(mod(ddcIdx+(0:size(r0n_16k_beforeRot,2)-1),4)+1);
    end
    r0n_16k_deRot_mi2 = r0n_16k_deRot.^2; %用于精估频偏
    %%
    for startPos=1:1:OSR
        r0n_deRot = [];
        %r1n_deRot = [];
        for dataIdx=startPos:4*OSR:length(r0n_buf)-4*OSR+1 % -71
            tmp = r0n_buf(dataIdx:dataIdx+4*OSR-1).*roS;
            r0n_deRot = [r0n_deRot tmp];
        end
        mi2 = r0n_deRot.^2; %用于同步
    end

    figure;subplot(2,1,1);plot(real(r0n_buf));title("解旋前后对比图");
    subplot(2,1,2);plot(real(r0n_deRot));

    %% 精同步和补偿
    r0n_deRot_FOcomp = r0n_deRot;
    figure;subplot(2,1,1);plot(real(r0n_deRot));title("频偏补偿前后对比图");
    subplot(2,1,2);plot(real(r0n_deRot_FOcomp));

    %精同步
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

    % 相关补偿
    r0n_16k = r0n_deRot_FOcomp(pos:OSR:end)*maxC(maxPos)';
    figure;subplot(3,1,1);plot(real(r0n_deRot_FOcomp));title("精同步前输入信号实部图");
    subplot(3,1,2);plot(real(r0n_deRot_FOcomp(pos:OSR:end)));title("精同步后补偿前实部图");
    subplot(3,1,3);plot(real(r0n_16k));title("精同步后补偿前实部图");

    soft = (real(r0n_16k(1:712))); %+ imag(r1n_16k(1:448)); % 用的单路即可
    out1 = (soft.'>0)*2-1;

    biterr(headIdx) = sum(abs((out1(1:712).'<0)-information_bits)); % biterr(headIdx)
    fprintf('errorbitnum = %d,ber =%f\n',biterr(headIdx),biterr(headIdx)/712);
end
disp(biterr);