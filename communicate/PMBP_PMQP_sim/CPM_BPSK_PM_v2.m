%% ********* CPM_BPSK_PM simulation ********* %%
%% ***** data:20240715 authoor:ShenYifu ****  %%
%% 参考论文《复合调制信号盲分析技术研究》
%% 

% 仿真发现，复合信号生成采样率是副载波的4倍以上较好

%%
clc;clear;
close all;
%% 参数设置
K = 1e3;           % 单位 KHz
M = 1e6;           % 单位 MHz 
Rb = 64*K;         % 码速率
fc = 1*K;        % 主载频
fcsub = 384*K;      % 副载频
fs = 5 * fcsub;        % 采样率
time = 5;        % 仿真时间
symbolnum = Rb*time; % 码元个数
SNR = 30;

%% CPM_BPSK_PM调制
% PCM编码
pcm_bits = randi([0 1],1,symbolnum);
pcm_symbols = 2 * pcm_bits - 1;   % 将0 --> -1; 1 --> 1

% 成型滤波器
% rolloff = 0.35;                     % 滚降系数
rolloff = 1;                     % 滚降系数
span = 10;                          % 滤波器长度（符号数）
sps = fs / Rb; % 每符号采样数
rrc_filter = rcosdesign(rolloff, span, sps, 'sqrt'); % 生成平方根升余弦滤波器

for k = 1 : length(pcm_symbols)
    up_pcm_s(1+sps*(k-1)) = pcm_symbols(k);
    up_pcm_s(2+sps*(k-1):sps*k) = zeros(1,sps-1);
end
rcos_pcm_s = filter(rrc_filter,1,up_pcm_s);

% BPSK 调制
N = length(rcos_pcm_s);
t = (1 : N)/fs;
s_BPSK = rcos_pcm_s .* exp(1i*2 * pi * fcsub * t);
% PM 调制
Kp = 0.8;
s_PCM_BPSK_PM = cos(2 * pi * fc * t + Kp * real(s_BPSK));
s_PCM_BPSK_PM1 = sin(2 * pi * fc * t + Kp * real(s_BPSK));

%% 生成方式选择
% 方式一
send_signal = s_PCM_BPSK_PM + 1i * s_PCM_BPSK_PM1;

% figure;
% plot(t, real(send_signal));title('PCM-BPSK-PM信号');xlabel('时间 (s)');ylabel('幅度');

%% 信道
% 加噪
send_signal = awgn(send_signal, SNR, 'measured');

%% ********* PM解调 ***********
%% PM解调对应采样率要大于较大载波的两倍才可以
% 主载频估计
nfft = 16384*4;
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
fcdiff = fc_est - fc;
fprintf("主载频估计误差：%.3f\n",fcdiff);

% 带宽估计-送锁相环
fft_temp1 = fft_temp;
if maxindex> nfft/2     
    if (maxindex+200)<nfft
        fft_temp1(maxindex-200:maxindex+200) = 0;
    else
        fft_temp1(maxindex-200:end) = 0;
    end 
else
    if (maxindex-200)>0
        fft_temp1(maxindex-200:maxindex+200) = 0;
    else
        fft_temp1(1:maxindex+200) = 0;
    end
end

if maxindex> nfft/2  
    fft_temp1(1:nfft/2) = 0;
    [maxvalue1,maxindex1] = max(fft_temp1);     
else
    fft_temp1(nfft/2:end) = 0;
    [maxvalue1,maxindex1] = max(fft_temp1);     
end    
band = abs(maxindex1-maxindex)*fs/nfft;
fprintf("带宽估计：%.3f\n",band);

%% 主载波下变频方式

%% 方式一 主载波比较小时，不采用
% send_signalI = real(send_signal).* cos(-2*pi*fc_est*(1:length(send_signal))/fs);
% send_signalQ = imag(send_signal).* sin(-2*pi*fc_est*(1:length(send_signal))/fs);
% send_signal = send_signalI + 1i*send_signalQ;
% 
% % 滤波高频分量
% hai=3.3;                    %海明窗窗过度带宽系数
% wp=0.1*pi;                 %通带截止频率        1.7MHz(0.2 0.4)
% ws=0.2*pi;                 %阻带起始频率
% wdlta=ws-wp;
% N_lp=ceil(2*pi*hai/wdlta);     %求滤波器阶数N_lp
% Wc=(wp+ws)/2;
% b=fir1(N_lp-1,Wc/pi,hamming(N_lp));
% yi=filter(b,1,real(send_signal));
% yq=filter(b,1,imag(send_signal));
% send_signal=yi+1i*yq;

%% 方式二 主载波比较小时，不采用
% send_signal_temp = send_signal.*exp(-1i*2*pi*fc_est*(1:length(send_signal))/fs);
% send_signal = send_signal_temp;

%% 求相角

% ********* 测试使用 *********
% 从全盲估计的话，
% 主载波和副载波应该都是先估计得到，进而确定带宽。
% band_pm_bp = 2*(fcsub - fc);
band_pm_bp = 2*band;
% ****************************

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
coefficient_temp=0.4;                      % Rb=10k
BL=coefficient_temp*band_pm_bp;              % 参数要根据复合信号的带宽确定
Wn=8*sigma*BL/(1+4*sigma^2);     T_nco=1/fs_nco; % T_nco应该是采样周期
K1(1:Simulation_Length_1)=(2*sigma*Wn*T_nco)/(K);      
K2(1:Simulation_Length_1)=((T_nco*Wn)^2)/(K);

for i=2:Simulation_Length_1
    Signal_PLL_1(i)=Signal_Channel_1(i)*exp(-1i*(NCO_Phase_1(i-1)));  %下变频?
    I_PLL_1(i)=real(Signal_PLL_1(i));  %读取同相和正交之路的数据
    Q_PLL_1(i)=imag(Signal_PLL_1(i));
    
    Discriminator_Out_1(i) =(atan2( Q_PLL_1(i),I_PLL_1(i)));
    
    PLL_Phase_Part_1(i)=Discriminator_Out_1(i)*K1(i);
    PLL_Freq_Part_1(i)=Discriminator_Out_1(i)*K2(i)+PLL_Freq_Part_1(i-1);
    Freq_Control_1(i)=PLL_Phase_Part_1(i)+PLL_Freq_Part_1(i);
    NCO_Phase_1(i)=NCO_Phase_1(i-1)+Freq_Control_1(i)*2*pi;
end
figure;plot(PLL_Freq_Part_1*fs);title("频率跟踪曲线");
% figure;plot(PLL_Phase_Part_1); title("鉴相器输出") ;  
figure;plot(abs(fft(PLL_Phase_Part_1,fs)));title("鉴相器输出fft");      
PLL_Phase_hilbert = hilbert(PLL_Phase_Part_1);

%% ******** BPSK解调 ********
cpm_bpsk = PLL_Phase_hilbert;
% nfft 长度取决于fc_est和fs,即满足 fc_est*M*fs/nfft < (nfft/2),才能估计出载频
% 简单得说：估计得参数要小于fs/2
% 凡是利用谱线估计，可能都要注意这个关系。
% 副载波估计
M =  2 ;                        % 二倍频
s_temp = cpm_bpsk.^M;
nfft = 16384*4;             
fft_temp = abs(fft(s_temp,nfft));
fft_temp(1:10) = 0;
half_fft_temp = fft_temp(1:nfft/2);
[maxvalue,maxindex] = max(half_fft_temp);

fcsub_est = ( (maxindex-1)*fs/nfft )/M;
fcsubdiff = fcsub_est - fcsub;
fprintf("副载频估计误差：%.3f\n",fcsubdiff);

%% 副载波下变频方式选择
send_signal = cpm_bpsk;  % 输入
% % 方式一  
% % note：方式一要调制滤波器参数，以保证把高频分量滤除
% figure;plot(real(send_signal));title("副载波下变频前");
% send_signalI = real(send_signal).* cos(-2*pi*fcsub_est*(1:length(send_signal))/fs);
% send_signalQ = imag(send_signal).* (sin(-2*pi*fcsub_est*(1:length(send_signal))/fs));
% send_signal = send_signalI + 1i*send_signalQ;
% 
% % 滤波高频分量
% hai=3.3;                    %海明窗窗过度带宽系数
% wp=0.20*pi;                 %通带截止频率        1.7MHz(0.2 0.4)
% ws=0.30*pi;                 %阻带起始频率
% wdlta=ws-wp;
% N_lp=ceil(2*pi*hai/wdlta);     %求滤波器阶数N_lp
% Wc=(wp+ws)/2;
% b=fir1(N_lp-1,Wc/pi,hamming(N_lp));
% yi=filter(b,1,real(send_signal));
% yq=filter(b,1,imag(send_signal));
% send_signal=yi+1i*yq;

% 方式二
% 方式二不用滤波器滤出分量
send_signal_temp = send_signal.*exp(-1i*2*pi*fcsub_est*(1:length(send_signal))/fs);
send_signal = send_signal_temp;
% figure;plot(real(send_signal));title("副载波下变频后");

%% 码速估计 如果上面滤波效果一般，码速估不出来

cpm_bpsk_down = send_signal;
M = 2;
s_envalop = cpm_bpsk_down.*conj(cpm_bpsk_down);
s_temp = diff(s_envalop);

nfft = 16384*4*4;
fft_temp = abs(fft(s_temp,nfft));
fft_temp(1) = 0;                        % 去除直流分量
half_fft_temp = fft_temp(1:nfft/2);
[maxvalue,maxindex] = max(half_fft_temp);

Rb_est = ( (maxindex-1)*fs/nfft);
Rbdiff = Rb_est - Rb;
fprintf("码速估计误差：%.3f\n",Rbdiff);

%% 测试使用 重采样 为符号速的4倍
% 重采样代码1
% Rb_est = 64e3; 
% sps = 4;
% fs_orignal = fs;
% fs = ceil(sps * Rb_est); % resample 函数第二个参数输入要为整数
% signal_resample = resample(send_signal,fs,fs_orignal);
% send_signal = signal_resample;

% 重采样代码2
s_orignal = send_signal;
fs_orignal = fs;
sps = 4;
fs_now = sps * Rb_est;
[P,Q] = rat(fs_now/fs_orignal);
signal_now = resample(s_orignal, P, Q);
send_signal = signal_now;


%% BPSK载波同步
s3  = send_signal(1:end)/max(abs(send_signal)); % 输入

sum_number=length(s3);
Signal_Channel=zeros(1,sum_number);
Signal_PLL_D=zeros(1,sum_number);
NCO_Phase =zeros(1,sum_number);
Discriminator_Out=zeros(1,sum_number);Freq_Control=zeros(1,sum_number);
PLL_Phase_Part=zeros(1,sum_number);PLL_Freq_Part=zeros(1,sum_number);

Ko=1;Kd=1;K=Ko*Kd;
sigma=0.707;
symbol_rate=Rb_est;              % 进锁相环时的采样点速率
for i = 1:length(s3)
    if i<5000
        coefficient_temp=0.002;
        BL(i)=coefficient_temp*symbol_rate;
        Wn(i)=8*sigma*BL(i)/(1+4*sigma^2);     T_nco=1/fs; % T_nco应该是采样周期
        C11(i)=(2*sigma*Wn(i)*T_nco)/(K);      C22(i)=((T_nco*Wn(i))^2)/(K);
        
    else
        coefficient_temp=0.002;
        BL(i)=coefficient_temp*symbol_rate;
        Wn(i)=8*sigma*BL(i)/(1+4*sigma^2);     T_nco=1/fs; % T_nco应该是采样周期
        C11(i)=(2*sigma*Wn(i)*T_nco)/(K);      C22(i)=((T_nco*Wn(i))^2)/(K);
    end
end

Vi_PLL=s3;                
Vi_PLL_real=real(Vi_PLL);  Vi_PLL_imag=imag(Vi_PLL);
for i=2:sum_number
    Signal_Channel(i)=Vi_PLL_real(i)+1i*Vi_PLL_imag(i);
    Signal_PLL_D(i)=Signal_Channel(i)*exp(-1i*(mod(NCO_Phase(i-1),2*pi)));
    Vo_PLL_real(i)=real(Signal_PLL_D(i));   % 科斯塔斯环输出
    Vo_PLL_imag(i)=imag(Signal_PLL_D(i));
    %Discriminator_Out(i)=sign(Vo_PLL_real(i))*Vo_PLL_imag(i);
    Discriminator_Out(i)= sign(Vo_PLL_real(i))*Vo_PLL_imag(i) - sign(Vo_PLL_imag(i))*Vo_PLL_real(i);
    PLL_Phase_Part(i)=Discriminator_Out(i)*C11(i);
    PLL_Freq_Part(i)=Discriminator_Out(i)*C22(i)+PLL_Freq_Part(i-1);
    Freq_Control(i)=PLL_Phase_Part(i)+PLL_Freq_Part(i);
    NCO_Phase(i)=NCO_Phase(i-1)+Freq_Control(i)*2*pi;
end
%
figure;plot(PLL_Freq_Part);title("载波同步频率跟踪曲线");
% figure;plot(real(exp(-1i*(mod(NCO_Phase,2*pi)))));title("载波输出曲线");
figure;plot(Vo_PLL_real);title("载波同步输出:real部");
% figure;plot(Vo_PLL_imag);title("载波同步输出:imag部");
% figure;scatter(Vo_PLL_real,Vo_PLL_imag);title("载波同步输出星座图");

%% BPSK码元同步
s_bpsk = Vo_PLL_real + 1i*Vo_PLL_imag;
Vo_PLL_real = real(s_bpsk);
Vo_PLL_imag = imag(s_bpsk);

Vo_PLL_real = Vo_PLL_real; %输入
Vo_PLL_imag = Vo_PLL_imag;

aI=Vo_PLL_real(1:end);
bQ=Vo_PLL_imag(1:end);
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
Rb_est_second = Rb_est;
BL1=Rb_est_second*0.004;                %可调
decimator=1;
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
deinput_I = I_PLL_D1(1:end);
deinput_Q = Q_PLL_D1(1:end);
%% 判决
deinput_I1 = sign(deinput_I);
deinput_I2 = -sign(deinput_I);   
%% 误码率比对
input = deinput_I1;
database = pcm_symbols;
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
fprintf("deinput_I2一次误码率最终为：%.6f   ,总比特数为：%d\n",error_rate,totalbit);

%% 绘图
% send_signal = signal;
% fs = 3.84e6/2;
% len_fft1 = fs;
% % index1 = 0 : round(len_fft1/2-1);
% index1 = 0 : round(len_fft1-1);
% t1 = index1*fs/len_fft1;
% y_fft = fft(send_signal,len_fft1);
% y1 = y_fft(1:len_fft1);
% % y1 = fftshift(y_fft(1:len_fft1));
% y1_dB = 10 * log10(y1);
% figure;plot(t1,y1_dB);grid on;
% xlabel('频率(Hz)');
% ylabel('功率谱(dB)');
% title('功率谱');


