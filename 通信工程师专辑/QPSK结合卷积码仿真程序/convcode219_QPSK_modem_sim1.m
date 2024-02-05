clear ;
close all;

fprintf('EbNo BER\n');

% 设置信噪比参数
for EbNo = 3:0.5:5
    % 不同信噪比得到不同的误码性能
    number_of_frame = 1;          % 仿真的帧数
    noe = 0;                        % 错误比特数
    nod = 0;                        % 仿真的数据长度

    %% 信号源
    for frm_loop = 1:number_of_frame
        frm_length = 1000;
        frm_data = randi(2,1,frm_length) - 1;
        % 生成多项式 【561，753】
        GenPoly = [1 0 1 1 1 0 0 0 1;1 1 1 1 0 1 0 1 1];
        % 之前217的多项式是117，133
        % GenPoly = [1 0 0 1 1 1 1; 1 0 1 1 0 1 1];             % 生成多项式
        [G_colomn,constraint_len] = size(GenPoly);              % 约束长度
        trellis = poly2trellis(constraint_len,[561,753]);       % 网格图
        k = 1;

%         GenPoly = [1 1 1 1 0 0 1 ; 1 0 1 1 0 1 1];             % 生成多项式
%         trellis = poly2trellis(constraint_len,[171,133]);       % 网格图
%         (n,k,M) = (2,1,7)的卷积编码生成多项式

    %% 卷积编码

    data1 = convenc(frm_data,trellis);   % 0 1 形式

    %% QPSK 调制
    
    for iii = 1:length(data1)/2           % ??????????????
        if data1(iii) == 0 && data1(iii+1) == 0
            I_data2(iii) = -1;
            Q_data2(iii) = -1;
        elseif data1(iii) == 0 && data1(iii+1) == 1
            I_data2(iii) = -1;
            Q_data2(iii) = 1;
        elseif data1(iii) == 1 && data1(iii+1) == 0
            I_data2(iii) = 1;
            Q_data2(iii) = -1;
        else 
            I_data2(iii) = 1;
            Q_data2(iii) = 1;
        end
    end


    %% AWGN信道
    % 计算信号功率，根据EbNo加噪
    s_pow = sum(I_data2.^2 + Q_data2.^2)/length(I_data2);
    attn = 0.5 * s_pow * 10^(-EbNo/10);
    attn = sqrt(attn);
    I_noise = randn(1,length(I_data2)).* attn;
    Q_noise = randn(1,length(Q_data2)).* attn;
    % 信号加噪
    I_data3 = I_data2 +I_noise;
    Q_data3 = Q_data2 +Q_noise;

    %% QPSK 解调
    I_data4 = I_data3 > 0;                  % 硬判决 , I_data4 为 logic 数组
    Q_data4 = Q_data3 > 0;

    %%% 硬判决 
    tblen = 32;
    I_data5 = vitdec(I_data4,trellis,tblen,'cont','hard');











    










































    end







end


