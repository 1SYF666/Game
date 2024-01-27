%%%%%%%********       函数测试程序       ********%%%%%%%
%%%%%%%         File: test_func_mseq.m         %%%%%%%
%%%%%%%%%     data:2022-04-28      author:算法工匠  %%%

%%%%% 程序说明
% 观察函数function_funct_mseq_2022的运行结果
% 观察函数function_funct_mseq_2015的运行结果
% 观察生成的m序列的相关特性
% 程序版本：R2022b

%*****************          程序主体          *****************%
%% function_funct_mseq_2015
%  m序列初始状态

stg = 8;
taps = [1 8];
inidata = [1 0 1 1 1 1 0 1]; % 初始相位
m_sequence = func_mseq_2015(stg,taps,inidata);

% m_sequence 取值为0 和 1
xcorr_mseq = xcorr(2*m_sequence-1);

%% compare function_funct_mseq 
%  m序列初始状态
stg = 9;
taps = [1 3 9];
inidata = [1 0 1 1 0 1 1 0 1]; % 初始相位
m_sequence1 = func_mseq_2015(stg,taps,inidata);
m_sequence2 = func_mseq_2022(stg,taps,inidata);

% m_sequence 取值为0 和 1
xcorr_mseq1 = xcorr(2*m_sequence1-1);
xcorr_mseq2 = xcorr(2*m_sequence2-1);

figure(1);
plot(xcorr_mseq);
title('自相关值');

figure(2);
plot(xcorr_mseq1);
title('自相关值');

figure(3);
plot(xcorr_mseq2);
title('自相关值');



