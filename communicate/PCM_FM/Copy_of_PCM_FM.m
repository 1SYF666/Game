%% *********** PCM_FM simulation ************ %%
%% ***** data:20240822 authoor:ShenYifu ****  %%
%% 参考论文《基于软件无线电的MSD中频接收机研制》
%% 参考论文《大动态多普勒频移下PCM_FM解调算法的研究》

%% 
clc;close all;clear;
%% 参数设置
K = 1e3;             % 单位 KHz
M = 1e6;             % 单位 MHz 
Rb = 16*K;           % 码速率
fs = 16*10*K;        % 采样率
Ts = 1/fs;
time = 0.5;          % 仿真时间
symbolnum = Rb*time; % 码元个数
samplenum = fs*time; % 时间样本
Kf = 0.7;            % 调制指数
KfTs = Kf*Ts;        % 调制常数
fc = 20*K;           % 载波频率
SNR = 20;

%% PCM/FM调制
% PCM编码
pcm_bits = randi([0 1],1,symbolnum);
pcm_symbols = 2 * pcm_bits - 1;   % 将0 --> -1; 1 --> 1

% 成型滤波器
rolloff = 1;                     % 滚降系数
span = 10;                          % 滤波器长度（符号数）
sps = fs / Rb;                      % 每符号采样数
rrc_filter = rcosdesign(rolloff, span, sps, 'sqrt'); % 生成平方根升余弦滤波器

for k = 1 : length(pcm_symbols)
    up_pcm_s(1+sps*(k-1)) = pcm_symbols(k);
    up_pcm_s(2+sps*(k-1):sps*k) = zeros(1,sps-1);
end
rcos_pcm_s = filter(rrc_filter,1,up_pcm_s);

n_temp = length(rcos_pcm_s);
n =  min(n_temp,samplenum);         % 保护，防止报错


% 计算I(nTs)和Q(nTs)
I = zeros(1,n);
Q = zeros(1,n);

for i = 1 : n
    sum_m(i) = sum( rcos_pcm_s(1:i) );

    phitemp(i) = KfTs*sum_m(i);
    if phitemp(i) > pi
        phitemp(i) = phitemp(i) - 2*pi;
    elseif phitemp(i) < -pi
       phitemp(i) = phitemp(i) + 2*pi;
    end

    I(i) = cos( phitemp(i) );
    Q(i) = sin( phitemp(i) );
end

% 生成PCM/FM信号
t = (0 : n-1)/fs;
singal_flag = 1;
switch singal_flag
    case 0
        % 方式一
        pcm_fm_I = cos(2 * pi * fc * t) .* I;
        pcm_fm_Q = sin(2 * pi * fc * t) .* Q;
    case 1
        % 方式二
        pcm_fm_I = cos(2 * pi * fc * t) .* I - sin(2 * pi * fc * t) .* Q;
        pcm_fm_Q = cos(2 * pi * fc * t) .* Q + sin(2 * pi * fc * t) .* I;
end
s = pcm_fm_I + 1i * pcm_fm_Q;    

%% 信道
% 加噪
% SNR = SNR-10*log(sps)/log(10);
% s = awgn(s, SNR, 'measured');


%% 载频估计
estimation_len = min(16384*4,n);   % 保护，防止报错

send_signal = s(1:estimation_len);
nfft = 16384*4*4;
fft_temp = abs(fft(send_signal,nfft));
fft_temp(1) = 0; % 去直流分量 
[maxvalue,maxindex] = max(fft_temp);          % 选择全部

if  maxindex> nfft/2                                 % 后面运行此模块代码发现负频率估计失效，
    % fc 为负值                                      % 故又添加了此处的if判断语句
    fc_est=(maxindex-nfft-1)/nfft*fs;
else
    % fc 为正值
    fc_est=(maxindex-1)/nfft*fs;
end
fprintf("载频估计：%.3f\n",fc_est);
fcdiff = fc_est - fc;
fprintf("载频估计误差：%.3f\n",fcdiff);

% 下变频
send_signal_temp = send_signal.*exp(-1i*2*pi*(fc_est)*(1:length(send_signal))/fs);
send_signal = send_signal_temp;

%% 解调相位信息
signal_I = real(send_signal);
signal_Q = imag(send_signal);
de_phi=zeros(1,length(signal_I));
for n = 2 : length(signal_I)
    de_phi(n-1) = ( signal_I(n-1).*signal_Q(n) - signal_I(n).*signal_Q(n-1) )./...
        (signal_I(n).*signal_I(n)+signal_Q(n).*signal_Q(n));
end
de_phi = de_phi-mean(de_phi);
figure;plot(de_phi);

s11 = send_signal;
Signal_Channel_1=s11;
Simulation_Length_1=length(s11);
%以下为锁相环处理过程
Signal_PLL_1=zeros(1,Simulation_Length_1);
NCO_Phase_1 =zeros(1,Simulation_Length_1);
Discriminator_Out_1=zeros(1,Simulation_Length_1);
Freq_Control_1=zeros(1,Simulation_Length_1);
PLL_Phase_Part_1=zeros(1,Simulation_Length_1);
PLL_Freq_Part_1=zeros(1,Simulation_Length_1);
I_PLL_1=zeros(1,Simulation_Length_1);
Q_PLL_1=zeros(1,Simulation_Length_1);

sigma = 0.707;
fs_nco = fs;

for i = 1 : Simulation_Length_1
    if i<500
        coefficient_temp=0.001;
        BL(i)=coefficient_temp*Rb;
    else
        coefficient_temp=0.001;
        BL(i)=coefficient_temp*Rb;
    end
    Wn=8*sigma*BL(i)/(1+4*sigma^2);     T_nco=1/fs_nco; % T_nco应该是采样周期
    K1(i)=(2*sigma*Wn*T_nco);
    K2(i)=((T_nco*Wn)^2);
end
for i=2:Simulation_Length_1
    Signal_PLL_1(i)=Signal_Channel_1(i)*exp(-1i*(NCO_Phase_1(i-1)));  %下变频?
    I_PLL_1(i)=real(Signal_PLL_1(i));  %读取同相和正交之路的数据
    Q_PLL_1(i)=imag(Signal_PLL_1(i));
    Discriminator_Out_1(i) =atan2(Q_PLL_1(i),I_PLL_1(i));
    PLL_Phase_Part_1(i)=Discriminator_Out_1(i)*K1(i);
    PLL_Freq_Part_1(i)=Discriminator_Out_1(i)*K2(i)+PLL_Freq_Part_1(i-1);
    Freq_Control_1(i)=PLL_Phase_Part_1(i)+PLL_Freq_Part_1(i);
    NCO_Phase_1(i)=NCO_Phase_1(i-1)+Freq_Control_1(i)*2*pi;
end
figure;plot(PLL_Freq_Part_1);title("频率跟踪曲线");
figure;plot(Discriminator_Out_1);title("鉴相输出");


len_temp = length(Discriminator_Out_1);
for i = len_temp:-1:2
    de_phi2(i-1) = Discriminator_Out_1(i)-Discriminator_Out_1(i-1);
end
figure;plot(de_phi2);title("成型之后信息波形");
figure;plot(abs(fft(abs(de_phi2(1:end)))));title("成型之后信息波形频谱");



%% 码速率估计
nfft  = 16384*4;
M =  2;
s_envalop = de_phi2.*conj(de_phi2);
% s_temp = diff(s_envalop);
s_temp = s_envalop;
fft_temp = abs(fft(s_temp,nfft));
fft_temp(1:20) = 0;     % 消除干扰
half_fft_temp = fft_temp(1:nfft/2); 
figure;plot(half_fft_temp);
[maxvalue,maxindex] = max(half_fft_temp);
Rb_est = ( (maxindex-1)*fs/nfft);
fprintf("码速估计：%.3f\n",Rb_est);
Rbdiff = Rb_est - Rb;
fprintf("码速估计误差：%.3f\n",Rbdiff);

%% 降采样
send_signal = de_phi;

sps = 4;
fs_orignal = fs;
fs = sps*Rb_est;
[P,Q] = rat(fs/fs_orignal);
signal_resample = resample(send_signal, P, Q);
send_signal = signal_resample;

%% 码元同步
aI=send_signal(1:end);
bQ=send_signal(1:end);
N=floor(length(aI)/4); %符号数  floor向负无穷取整
Ns=4*N;  %总的采样点数
w=[0.5,zeros(1,N-1)];  %环路滤波器输出寄存器，初值设为0.5
n=[0.9 zeros(1,Ns-1)]; %NCO寄存器，初值设为0.9  可调
n_temp=[n(1),zeros(1,Ns-1)];
u=[0.6,zeros(1,2*N-1)];%NCO输出的定时分数间隔寄存器，初值设为0.6
yI=zeros(1,2*N);       %I路内插后的输出数据
yQ=zeros(1,2*N);       %Q路内插后的输出数据
time_error=zeros(1,N); %Gardner提取的时钟误差寄存器
ik=time_error;
qk=time_error;
i=1;    %用来表示Ts的时间序号,指示n,n_temp,nco,
kk=1;   %用来表示Ti时间序号,指示u,yI,yQ
ms=1;   %用来指示T的时间序号,用来指示a,b以及w
strobe=zeros(1,Ns);
BL1=Rb_est*0.004;                %可调
decimator=1;
sigma = 0.707;
Wn1=8*sigma*BL1/(1+4*sigma^2);    %环路自由震荡角频率
T_nco1=1/(fs)*decimator;   %压控振荡器NCO频率更新周期fs_demo/K_sampdemo
c1=(2*sigma*Wn1*T_nco1)/(K);      %环路滤波器系数c1
c2=((T_nco1*Wn1)^2)/(K);          %环路滤波器系数c2
ns=length(aI)-2;
while(i<ns)
    n_temp(i+1)=n(i)-w(ms);
    
    if(n_temp(i+1)>0)
        n(i+1)=n_temp(i+1);
    else
        n(i+1)=(n_temp(i+1)-ceil(n_temp(i+1))+1);
        %内插滤波器模块
        FI1=0*aI(i+2)-1/2*aI(i+1)+1/2*aI(i)-1/6*aI(i-1);
        FI2=1/6*aI(i+2)+1/2*aI(i+1)-1*aI(i)+1/2*aI(i-1);
        FI3=-1/6*aI(i+2)+1*aI(i+1)-1/2*aI(i)-1/3*aI(i-1);
        FI4=0*aI(i+2)+0*aI(i+1)+1*aI(i)+0*aI(i-1);
        yI(kk)=(((FI1*u(kk)+FI2)*u(kk)+FI3)*u(kk)+FI4);
        
        FQ1=0*bQ(i+2)-1/2*bQ(i+1)+1/2*bQ(i)-1/6*bQ(i-1);
        FQ2=1/6*bQ(i+2)+1/2*bQ(i+1)-1*bQ(i)+1/2*bQ(i-1);
        FQ3=-1/6*bQ(i+2)+1*bQ(i+1)-1/2*bQ(i)-1/3*bQ(i-1);
        FQ4=0*bQ(i+2)+0*bQ(i+1)+1*bQ(i)+0*bQ(i-1);
        yQ(kk)=(((FQ1*u(kk)+FQ2)*u(kk)+FQ3)*u(kk)+FQ4);
        
        strobe(kk)=mod(kk,2);
        %时钟误差提取模块，采用的是Gardner算法
        if(strobe(kk)==0)
            %取出插值数据
            ik(ms)=yI(kk);
            qk(ms)=yQ(kk);
            %每个数据符号计算一次时钟误差
            if(kk>2)
                Ia=(yI(kk)+yI(kk-2))/2;
                Qa=(yQ(kk)+yQ(kk-2))/2;
                time_error(ms)=(yI(kk-1)-Ia)*(yI(kk)-yI(kk-2))+(yQ(kk-1)-Qa)*(yQ(kk)-yQ(kk-2));
            else
                time_error(ms)=(yI(kk-1)*yI(kk)+yQ(kk-1)*yQ(kk));
            end
            %环路滤波器,每个数据符号计算一次 环路滤波器输出
            if(ms>1)
                w(ms+1)=w(ms)+c1*(time_error(ms)-time_error(ms-1))+c2*time_error(ms-1);
            else
                w(ms+1)=w(ms)+c1*time_error(ms)+c2*time_error(ms);
            end
            ms=ms+1;
        end
        kk=kk+1;
        u(kk)=n(i)/w(ms);
    end
    
    i=i+1;
end
I_PLL_D1=ik(1:end);
Q_PLL_D1=qk(1:end);

% figure;plot(u);title("小数时间间隔u,符号数的2倍");
% figure;plot(n);title("NCO寄存器内容n,符号数的4倍");
% figure;plot(w(1:end-1));title("经过环路滤波器得到的定时控制字w，符号数");
% figure;plot(time_error);title("定时误差估计值，符号数");
figure;scatter(I_PLL_D1(1000:end),Q_PLL_D1(1000:end));title("定时环路同步输出星座图");     % 采样率是符号速4倍

%% 载波同步

s11 = I_PLL_D1+1i*Q_PLL_D1;
Signal_Channel_1=s11;
Simulation_Length_1=length(s11);
%以下为锁相环处理过程
Signal_PLL_1=zeros(1,Simulation_Length_1);
NCO_Phase_1 =zeros(1,Simulation_Length_1);
Discriminator_Out_1=zeros(1,Simulation_Length_1);
Freq_Control_1=zeros(1,Simulation_Length_1);
PLL_Phase_Part_1=zeros(1,Simulation_Length_1);
PLL_Freq_Part_1=zeros(1,Simulation_Length_1);
I_PLL_1=zeros(1,Simulation_Length_1);
Q_PLL_1=zeros(1,Simulation_Length_1);

sigma = 0.707;
fs_nco = Rb_est;
coefficient_temp=0.02;                      % Rb=10k
BL=coefficient_temp*Rb_est;            
Wn=8*sigma*BL/(1+4*sigma^2);     T_nco=1/fs_nco; % T_nco应该是采样周期
K1(1:Simulation_Length_1)=(2*sigma*Wn*T_nco);
K2(1:Simulation_Length_1)=((T_nco*Wn)^2);

for i=2:Simulation_Length_1
    Signal_PLL_1(i)=Signal_Channel_1(i)*exp(-1i*(NCO_Phase_1(i-1)));  %下变频?
    I_PLL_1(i)=real(Signal_PLL_1(i));  %读取同相和正交之路的数据
    Q_PLL_1(i)=imag(Signal_PLL_1(i));
    Discriminator_Out_1(i) =sign(I_PLL_1(i))*Q_PLL_1(i) - sign(Q_PLL_1(i))*I_PLL_1(i) ;
    PLL_Phase_Part_1(i)=Discriminator_Out_1(i)*K1(i);
    PLL_Freq_Part_1(i)=Discriminator_Out_1(i)*K2(i)+PLL_Freq_Part_1(i-1);
    Freq_Control_1(i)=PLL_Phase_Part_1(i)+PLL_Freq_Part_1(i);
    NCO_Phase_1(i)=NCO_Phase_1(i-1)+Freq_Control_1(i)*2*pi;
end
figure;plot(PLL_Freq_Part_1*fs_nco);title("频率跟踪曲线");
figure;scatter(I_PLL_1(1000:end),Q_PLL_1(1000:end));title("载波同步输出星座图"); 

deinput_I = I_PLL_D1(1:end);
%% 判决
deinput_I1 = sign(deinput_I);
deinput_I2 = -sign(deinput_I);   
%% 误码率比对
input = deinput_I1;
database = pcm_symbols(1:length(input));
% figure;plot(input);hold on;plot(database);
[error_rate,totalbit] = errorbit_compute(input,database);
errorcmputer(1,1:2) = [error_rate totalbit]; 
fprintf("deinput_I1一次误码率为：%.6f   ,总比特数为：%d\n",error_rate,totalbit);

clear input database error_rate totalbit;
input = deinput_I2;
database = pcm_symbols;
% figure;plot(input);hold on;plot(database);
[error_rate,totalbit] = errorbit_compute(input,database);
errorcmputer(2,1:2) = [error_rate totalbit]; 
fprintf("deinput_I2一次误码率为：%.6f   ,总比特数为：%d\n",error_rate,totalbit);

[minvalue,minindex] = min(errorcmputer(1,:));
error_rate = errorcmputer(minindex,1);
totalbit = errorcmputer(minindex,2);
fprintf("一次误码率最终为：%.6f   ,总比特数为：%d\n",error_rate,totalbit);






