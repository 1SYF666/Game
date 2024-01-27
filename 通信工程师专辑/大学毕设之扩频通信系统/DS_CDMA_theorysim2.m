%%%%%%%%%%         DS_CDMA系统基带信号理论仿真文件         %%%%%%%%%%
%%%%%%%%%%%%        File: DS_CDMA_theorysim2.m        %%%%%%%%%%%%%
%%%%%       date: 2018_12_11                anthor:仿真工匠    %%%%%

%%% 程序说明
%%% 本程序进行DS_CDMA系统基带信号理论仿真，进行多用户下的误码率性能测试
%%% 调制方式采用QPSK，扩频码采用m序列

%%%                  仿真环境
% 软件版本：R2015b

%----------------           程序主体        ----------------%
symbolm_rate = 256000.0;                            % 符号率
bit_rate = symbolm_rate * 2;                        % bit_rate
num_symbol = 100;                                   % 符号数
ebn0 = 10;
% Eb/No 设置不同的信噪比得到不同的误码率
%% 滤波器设置 
irfn = 12;                          % 滤波器阶数
IPOINT = 4;                         % 单个符号内的采样点数
alfs = 0.5;                         % 滚降因子
[xh1] = func_hrollfcoef(irfn,IPOINT,symbolm_rate,alfs,1);
% 发射机平方根滚降滤波器
[xh2] = func_hrollfcoef(irfn,IPOINT,symbolm_rate,alfs,0);
% 接收机平方根滚降滤波器

%% Spreading code initialization
num_users = 10 ;                    % 系统用户数  设置值为1-16 
stage = 5;                          % number of stages
ptap1 = [1 5];                      % position of taps for lst
ptap2 = [2 5];                      % position of taps for 2num_symbol 
regi1 = [1 1 1 1 1];                % initial value of register for 1st
regi2 = [1 1 1 1 1];                % initial value of register for 2st
%% Generation of the spreading code
code = func_mseq(stage,ptap1,regi1,num_users);          % 生成M序列
code = code*2 - 1;                                      % 双极性变换
clen = length(code);

%% Start Calculation
nloop = 100;                                            % simulation number of times
noe = 0;
nod = 0;

for ii = 1:nloop
    %%% 发射机
    source_data = randi([0 1],num_users,num_symbol*2);
    [ich,qch] = func_qpskmod(source_data,num_users,num_symbol,2);
    % QPSK modulation 
    [ich1,qch1] = func_spread(ich,qch,code);            % spreading    
    [ich2,qch2] = func_compoversamp2(ich1,qch1,IPOINT); % over sampling
    [ich3,qch3] = func_compconv2(ich2,qch2,xh1);        % filter

    % 单个用户信号的频谱展示 测试误码率时需注释
%     figure(1);
%     plot(abs(fft(ich3(1,:))));
%     title('单个用户信号的频谱展示');
%     figure(2);
%     plot(10*log10(abs(fft(ich3(1,:)))));
%     title('单个用户信号的功率谱展示');

    if num_users == 1
        ich4 = ich3;
        qch4 = qch3;
    else
        ich4 = sum(ich3);
        qch4 = sum(qch3);

    end

    %%% 信道
    spow = sum(rot90(ich3.^2 + qch3.^2)) / num_symbol;
    attenuation = sqrt(0.5 * spow * symbolm_rate/bit_rate*10^(-ebn0/10));
    [ich5,qch5] = func_comb2(ich4,qch4,attenuation);
    % add White Gaussian Noise (AWGN)
    
    %%% 接收机
    [ich6,qch6] = func_compconv2(ich5,qch5,xh2);        % filter

    samp1 = irfn * IPOINT + 1;
    ich7 = ich6(:,samp1 : IPOINT:IPOINT*num_symbol*clen+samp1 -1);
    qch7 = qch6(:,samp1 : IPOINT:IPOINT*num_symbol*clen+samp1 -1);

    [ich8,qch8] = func_despread(ich7,qch7,code);         % 解扩
    demod_data = func_qpskdemod(ich8,qch8,num_users,num_symbol,2);
    % QPSK demodulation

    %%% Bit Error Rate (BER)
    noe2 = sum(sum(abs(source_data-demod_data)));
    nod2 = num_users * num_symbol*2;
    noe = noe +noe2;
    nod = nod +nod2;

    fprintf('%d\t%e\n',ii,noe2/nod2);
end
%% 误码率文件
ber = noe / nod;
fprintf('%s\t %s\t\t %s\t\t %s\n','ebn0','noe','nod','ber');
fprintf('%d\t%d\t%d\t%e\n',ebn0,noe,nod,ber);
% fip = fopen('DSCDMA_BER.dat','a');
% fprintf(fid,'%d\t%e\t%f\t%f\t\n',ebn0,noe/nod,noe,nod);
% fclose(fid);







