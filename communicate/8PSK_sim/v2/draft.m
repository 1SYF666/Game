%% 起始点检测
nfft = 65536;
fft1 = fft(s(1:end),nfft);
fft2 = fft(sync,nfft);
fft3 = abs(fft(fft2.*conj(fft1),nfft));
figure;plot(fft3);title("自相关效果图");

r = s(812:end);
k = 1:750;
ppp = exp(-1i*3*pi/8*k);
pppsps = repmat(ppp,4,1);
pppsps1 = pppsps(:).';
freamlen = 750;
for k = 1: floor(length(r) / length(ppp))
    s(1+freamlen*(k-1):freamlen*k) = r(1+freamlen*(k-1):freamlen*k).*ppp;
end
figure;plot(real(s));

%%
% for k = 1: length(r)
%     r(k) = r(k).*exp(-j*3*pi/8*k);
% end
%
% figure;scatter(real(r),imag(r));title("解旋之后星座图");
% figure;plot(real(r));title("解旋之后信号实部图");

if 0
    derots = receive_rcos;
    % s^ = si.*exp(j*i*3*pi/8) 16为一周期
    steprot = 16;
    for k = 1 : steprot
        phasecompensate(k) = exp(-1i*3*pi/8*k);
    end
    phacompsps = repmat(phasecompensate,sps,1);
    phacompsps = phacompsps(:).';
    phacompspstemp = phacompsps;

    derotdata = [];
    % 分帧解旋处理
    for k = 1 : length(headframe)
        slicebuf = derots(headframe(k):tailframe(k));
        bufLen =0;
        if mod(length(slicebuf),length(phacompsps)) ~= 0
            bufLen = length(phacompsps) - mod( length(slicebuf),length(phacompsps) );
        end

        slicebuf = [slicebuf zeros(1,bufLen)]; % 补零

        for j=0:length(phacompsps)/2-1
            if j ~= 0
                phacompsps = circshift(phacompsps,-1);
            end
            slicebufrot =[];
            for ddx = 1 : length(phacompsps) : length(slicebuf)
                tmp = slicebuf( ddx : ddx + steprot*sps-1) .* phacompsps;
                slicebufrot = [slicebufrot tmp];
            end
            % slicebufrot1(j+1) = sum(real(slicebufrot).^2)-sum(imag(slicebufrot).^2);
            slicebufrot1(j+1) = sum(real(slicebufrot).^2);
        end

        figure;stem(slicebufrot1); title("解旋同步示意图");
        [~,maxindex] = max(slicebufrot1);
        phacompspstemp = circshift(phacompspstemp,-1*(maxindex-1));

        slicebufrot =[];
        for ddx = 1 : length(phacompspstemp) : length(slicebuf)
            tmp = slicebuf( ddx : ddx + steprot*sps-1) .* phacompspstemp;
            slicebufrot = [slicebufrot tmp];
        end

        figure;subplot(2,1,1);plot(real(slicebuf));title("解旋前后对比图");
        subplot(2,1,2);plot(real(slicebufrot));
        derotdata = [derotdata slicebufrot];  % 解旋之后每帧重新拼接
    end
end

%% 符号同步
% s = derotdata;
s = receive_rcos;
aI=real(s);
bQ=imag(s);
N=floor(length(aI)/4); %符号数  floor向负无穷取整
Ns=4*N;  %总的采样点数
w=[0.5,zeros(1,N-1)];  %环路滤波器输出寄存器，初值设为0.5
n=[1 zeros(1,Ns-1)]; %NCO寄存器，初值设为0.9
n_temp=[n(1),zeros(1,Ns-1)];
u=[0.6,zeros(1,2*N-1)];%NCO输出的定时分数间隔寄存器，初值设为0.6
yI=zeros(1,2*N);       %I路内插后的输出数据
yQ=zeros(1,2*N);       %Q路内插后的输出数据
time_error=zeros(1,N); %Gardner提取的时钟误差寄存器
ik=time_error;
qk=time_error;
sigma=0.707;                    %环路阻尼系数
decimator=1;
Ko=1;                           %压控振荡器增益
Kd=1;                           %鉴相器增益
K=Ko*Kd;
i=1;    %用来表示Ts的时间序号,指示n,n_temp,nco,
kk=1;   %用来表示Ti时间序号,指示u,yI,yQ
ms=1;   %用来指示T的时间序号,用来指示a,b以及w
strobe=zeros(1,Ns);
BL1=Rb*0.00001;%0.0096
Wn1=8*sigma*BL1/(1+4*sigma^2);
T_nco1=1/(fs)*decimator;
c1=(2*sigma*Wn1*T_nco1)/(K);      % c1
c2=((T_nco1*Wn1)^2)/(K);          % c2
ns=length(aI)-2;
while(i<ns)
    n_temp(i+1)=n(i)-w(ms);
    if(n_temp(i+1)>0)
        n(i+1)=n_temp(i+1);
    else
        n(i+1)=(n_temp(i+1)-ceil(n_temp(i+1))+1);
        %内插滤波器模块
        FI1(kk)=1/6*aI(i+2)-1/2*aI(i+1)+1/2*aI(i)-1/6*aI(i-1);
        FI2(kk)=0*aI(i+2)+1/2*aI(i+1)-1*aI(i)+1/2*aI(i-1);
        FI3(kk)=-1/6*aI(i+2)+1*aI(i+1)-1/2*aI(i)-1/3*aI(i-1);
        FI4(kk)=0*aI(i+2)+0*aI(i+1)+1*aI(i)+0*aI(i-1);
        yI(kk)=(((FI1(kk)*u(kk)+FI2(kk))*u(kk)+FI3(kk))*u(kk)+FI4(kk));

        FQ1(kk)=1/6*bQ(i+2)-1/2*bQ(i+1)+1/2*bQ(i)-1/6*bQ(i-1);
        FQ2(kk)=0*bQ(i+2)+1/2*bQ(i+1)-1*bQ(i)+1/2*bQ(i-1);
        FQ3(kk)=-1/6*bQ(i+2)+1*bQ(i+1)-1/2*bQ(i)-1/3*bQ(i-1);
        FQ4(kk)=0*bQ(i+2)+0*bQ(i+1)+1*bQ(i)+0*bQ(i-1);
        yQ(kk)=(((FQ1(kk)*u(kk)+FQ2(kk))*u(kk)+FQ3(kk))*u(kk)+FQ4(kk));

        strobe(kk)=mod(kk,2);
        %时钟误差提取模块，采用的是Gardner算法
        if(strobe(kk)==0)
            %取出插值数据
            ik(ms)=yI(kk);
            qk(ms)=yQ(kk);
            %每个数据符号计算一次时钟误差
            if(kk>2)
                Ia(kk)=(yI(kk)+yI(kk-2))/2;
                Qa(kk)=(yQ(kk)+yQ(kk-2))/2;
                time_error(ms)=(yI(kk-1)-Ia(kk))*(yI(kk)-yI(kk-2))+(yQ(kk-1)-Qa(kk))*(yQ(kk)-yQ(kk-2));
            else
                time_error(ms)=(yI(kk-1)*yI(kk)+yQ(kk-1)*yQ(kk));
            end
            %环路滤波器,每个数据符号计算一次环路滤波器输出
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


figure;subplot(2,1,1);plot(I_PLL_D1(1:end));title('定时同步输出实部图');
subplot(2,1,2);plot(Q_PLL_D1(1:end));title('定时同步输出虚部图');
figure;plot(w(1:end-1));title("定时误差效果图");
figure;scatter(I_PLL_D1, Q_PLL_D1);title('符号同步星座图');
Symbols_synchronous_output = I_PLL_D1+1i*Q_PLL_D1;

%% 载波同步
s = Symbols_synchronous_output;
Kt=sqrt(2)-1;
Sample_Length=length(s);
Signal_PLL=zeros(1,Sample_Length);
Signal_PLL_D=zeros(1,Sample_Length);
NCO_Phase = zeros(1,Sample_Length);
Discriminator_Out=zeros(1,Sample_Length);
Freq_Control=zeros(1,Sample_Length);
PLL_Phase_Part=zeros(1,Sample_Length);
PLL_Freq_Part=zeros(1,Sample_Length);
Ko=1;                           %压控振荡器增益
Kd=1;                           %鉴相器增益
K=Ko*Kd;
sigma = 0.707;
decimator = 1;
for i=1:1:length(s)
    BL(i)=0.009*Rb;   % bl>0.1 && bl<0.3
    Wn(i)=8*sigma*BL(i)/(1+4*sigma^2);    %环路自由震荡角频率
    T_nco=1/(Rb)*decimator;             %压控振荡器NCO频率更新周期
    K1(i)=(2*sigma*Wn(i)*T_nco)/(K);      %环路滤波器系数K1
    K2(i)=((T_nco*Wn(i))^2)/(K);          %环路滤波器系数K2
end

I_PLL_D=zeros(1,Sample_Length);
Q_PLL_D=zeros(1,Sample_Length);

for i=2:Sample_Length
    %鉴相器(处理的是相位信息,因此需要将NCO输出转换为相位信息)
    Signal_PLL(i)=s(i)*exp(-1i*(mod(NCO_Phase(i-1),2*pi)));     % 得到相位调整后的信号，NCO_Phase(i-1)是相位，mod(NCO_Phase(i-1),2*pi)把范围控制在[0,2*pi]
    Signal_PLL_D(i)=Signal_PLL(i);
    I_PLL_D(i)=real(Signal_PLL_D(i));
    Q_PLL_D(i)=imag(Signal_PLL_D(i));
    %四象限反正切鉴别，得到鉴相器的输出，并传入环路滤波器
    % if abs(I_PLL_D(i)) > abs(Q_PLL_D(i))
    %     Discriminator_Out(i)= Q_PLL_D(i) * sign(I_PLL_D(i)) - Kt * I_PLL_D(i) * sign(Q_PLL_D(i));
    % else
    %     Discriminator_Out(i)= Kt * Q_PLL_D(i) * sign(I_PLL_D(i)) - I_PLL_D(i) * sign(Q_PLL_D(i));
    % end
    Discriminator_Out(i)=sign(real(Signal_PLL(i).^2))*imag(Signal_PLL(i).^2)-sign(imag(Signal_PLL(i).^2))*real(Signal_PLL(i).^2);

    %环路滤波器(窄带低通滤波器)，Discriminator_Out是一个高频信号，但VCO需要低频信号
    PLL_Phase_Part(i)=Discriminator_Out(i)*K1(i);
    PLL_Freq_Part(i)=Discriminator_Out(i)*K2(i)+PLL_Freq_Part(i-1);
    Freq_Control(i)=PLL_Phase_Part(i)+PLL_Freq_Part(i);
    %环路滤波器(窄带低通滤波器)，Freq_Control带有相位差信息

    % 进入压控振荡器进行相位和频率的调整
    NCO_Phase(i)=NCO_Phase(i-1)+Freq_Control(i)*2*pi;   % 相位=2*pi*频率f，频率是相位随时间的变化率
end
% fc_jg=fc_cg+mean(PLL_Freq_Part(end/2:end)*fs);
figure;plot(PLL_Freq_Part*fs/4);title('PLL跟踪频率');
figure;subplot(2,1,1);plot(I_PLL_D1(1:end));title('载波同步输出实部图');
subplot(2,1,2);plot(Q_PLL_D1(1:end));title('载波同步输出虚部图');
figure;scatter(I_PLL_D(1000:end-50), Q_PLL_D(1000:end-50));title('载波同步星座图');
Carrier_synchronous_output = I_PLL_D + 1i*Q_PLL_D;


%% 载波同步
% 时间：20241021
s = s_derot;
parameterinitial;

for i=1:1:length(s)
    BL(i)=0.000009*Rb;   % bl>0.1 && bl<0.3
    Wn(i)=8*sigma*BL(i)/(1+4*sigma^2);    %环路自由震荡角频率
    T_nco=1/(Rb)*decimator;             %压控振荡器NCO频率更新周期
    K1(i)=(2*sigma*Wn(i)*T_nco)/(K);      %环路滤波器系数K1
    K2(i)=((T_nco*Wn(i))^2)/(K);          %环路滤波器系数K2
end

for i=2:Sample_Length
    Signal_PLL(i)=s(i)*exp(-1i*(mod(NCO_Phase(i-1),2*pi)));
    I_PLL_D(i)=real(Signal_PLL(i));
    Q_PLL_D(i)=imag(Signal_PLL(i));
    % if abs(I_PLL_D(i)) > abs(Q_PLL_D(i))
    %     Discriminator_Out(i)= Q_PLL_D(i) * sign(I_PLL_D(i)) - Kt * I_PLL_D(i) * sign(Q_PLL_D(i));
    % else
    %     Discriminator_Out(i)= Kt * Q_PLL_D(i) * sign(I_PLL_D(i)) - I_PLL_D(i) * sign(Q_PLL_D(i));
    % end
    Discriminator_Out(i)=sign(real(Signal_PLL(i).^2))*imag(Signal_PLL(i).^2)-sign(imag(Signal_PLL(i).^2))*real(Signal_PLL(i).^2);

    %环路滤波器(窄带低通滤波器)，Discriminator_Out是一个高频信号，但VCO需要低频信号
    PLL_Phase_Part(i)=Discriminator_Out(i)*K1(i);
    PLL_Freq_Part(i)=Discriminator_Out(i)*K2(i)+PLL_Freq_Part(i-1);
    Freq_Control(i)=PLL_Phase_Part(i)+PLL_Freq_Part(i);
    NCO_Phase(i)=NCO_Phase(i-1)+Freq_Control(i)*2*pi;
end
figure;plot(PLL_Freq_Part*Rb);title('PLL跟踪频率');
figure;subplot(2,1,1);plot(I_PLL_D(1:end));title('载波同步输出实部图');
subplot(2,1,2);plot(Q_PLL_D(1:end));title('载波同步输出虚部图');
figure;scatter(I_PLL_D(1:end-50), Q_PLL_D(1:end-50));title('载波同步星座图');
Carrier_synchronous_output = I_PLL_D + 1i*Q_PLL_D;


%% 信道估计
lensync1 = length(sync1);
guard = 5;                              % 保护间隔
start_sub = (framestart-guard) * sps;   % 根据帧格式决定
end_sub=(framestart + lensync1 + guard ) * sps;
r_sub = framesignal(start_sub:end_sub);
T_sync = conj(sync1);

chan_est = zeros(1,length(r_sub)-sps*lensync1);
for i = 1 : length(chan_est)
    chan_est(i) = r_sub(i : sps : i + (lensync1-1)*sps )*T_sync.';
end
chan_est = chan_est./lensync1;

L = 2;                % 根据abs(chan_est)设定，暂时还没找到依据
WL = sps*(L+1);
search = abs(chan_est).^2;
for i = 1 : (length(search)-(WL-1))
    power_est(i) = sum( search(i : i + WL - 1) );
end

[peak, sync_w] = max(power_est);
h_est = chan_est(sync_w:sync_w+WL+5);

if 1
    figure;plot(abs(chan_est));
    title('The absolute value of the correlation');
    figure;plot(power_est);title('The window powers');
    figure;plot(abs(h_est));
    title('Absolute value of extracted impulse response');
end

    if 1
        s_synchronization = framesignal(pos:sps:end)*maxC(maxPos)';
    else
        burst_start = pos;
        m = length(h_est)-1;
        guardmf = (guard+1)*sps;
        r_extended = [zeros(1,guardmf) framesignal zeros(1,m) zeros(1,guardmf)];
        for n = 1 : 750
            aa = guardmf + burst_start + (n-1)*sps;
            bb = guardmf + burst_start + (n-1)*sps + m;
            Y(n) = r_extended(aa:bb) * h_est';    % 接收信号信号h_est的共轭
        end
        s_synchronization = Y;

    end


    %% 信道估计
chanelsignal = s_derot;
lensync1 = length(synciq1);
guard = 5;                              % 保护间隔
start_sub = (framestart-guard) ;   % 根据帧格式决定
end_sub=(framestart + lensync1 + guard ) ;
r_sub = chanelsignal(start_sub:end_sub);
T_sync = conj(synciq1);

chan_est = zeros(1,length(r_sub)-lensync1);
for i = 1 : length(chan_est)
    chan_est(i) = r_sub(i : i + (lensync1-1) )*T_sync.';
end
chan_est = chan_est./lensync1;

L = 2;                % 根据abs(chan_est)设定，暂时还没找到依据
WL = (L+1);
search = abs(chan_est).^2;
for i = 1 : (length(search)-(WL-1))
    power_est(i) = sum( search(i : i + WL - 1) );
end

[peak, sync_w] = max(power_est);
h_est = chan_est(sync_w:sync_w+WL);

if 1
    figure;plot(abs(chan_est));
    title('The absolute value of the correlation');
    figure;plot(power_est);title('The window powers');
    figure;plot(abs(h_est));
    title('Absolute value of extracted impulse response');
end

    %%
    % mu = 0.01; % 步长
    % L = 6; % 滤波器长度
    % w = zeros(L+1, 1); % 初始化滤波器权重
    % input_signal = s_derot(50+4+208+1 : 50+4+208+24); % 输入信号
    % desired_output = synciq1;% 期望输出信号
    % N = length(input_signal); % 输入信号长度
    % % 自适应滤波器算法
    % for n = L+1:N
    %     % 滤波器输出 y(n)
    %     y(n) = w' * input_signal(n:-1:n-L);
    %     % 计算误差
    %     e = desired_output(n) - y(n);
    %     % 更新权重
    %     w = w + mu * e * input_signal(n:-1:n-L)';
    % end
    % 
    % % 绘制误差信号
    % figure; plot(e);
    % xlabel('时间样本');
    % ylabel('误差');
    % title('LMS 自适应滤波误差');


    %% 相关补偿
    a1 = xcorr(s_derot,synciq);  % 仅需滑动1~3个样点，主要是计算相位值maxC
    % figure;plot(abs(a1));title("相关示意图图")
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

    % 复现论文《EDGE调制解调的ASIC设计与实现》_庞海朋 3.2.1节，没有实现
% for i = 1:10
%     if i == 1
%         figure;plot(abs(s_rcos((i-1)*sps+1:i*sps)));
%     else
%         hold on;plot(abs(s_rcos((i-1)*sps+1:i*sps)));
%     end
% end


cross_correlation = xcorr(base_bit1,deoutbit);
figure;plot(abs(cross_correlation));title("cross correlation");
nfft = 4096;
fft1 = fft(base_bit1,nfft);
fft2 = fft(deoutbit,nfft);
fft3 = abs(fft(fft2.*conj(fft1),nfft));
figure;plot(fft3);title("自相关效果图");