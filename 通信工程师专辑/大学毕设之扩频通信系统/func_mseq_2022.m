%%%%%%%********       函数模块程序       ********%%%%%%%
%%%%%%%         File: func_mseq_2022.m         %%%%%%%
%%%%%%%%%     data:2022-04-28      author:算法工匠  %%%

function [mout] = func_mseq_2022(stg,taps,inidata)
%%%%% 程序说明
%%% 利用级联移位寄存器生成stg阶m序列

%%% 参数定义
% stg : Number of stages
% taps: Position of register feedback
% inidata： Initial sequence in register
% n      :  Number of output sequence(it can be omitted )
% mout   :  output M sequence
% *******************************************
% An example
% stg = 3;
% taps = [1,3];
% inidata =[1 ,1 ,1];  %初相 即寄存器的初始值
% n = 2

% m序列生成器的结构如下：
% ------------+--------------
%|      |               |
%-->|1|-->|2|-->|3|-->比特输出
% 生成多项式：1 + x + x^3
% 
% 程序版本： R2022b

%% 函数主体
mout = zeros(1,2^stg-1);
fpos = zeros(stg,1);

%fpos(taps) = 1;
%寄存器状态载入 taps = [1,3];fpos(taps) = [1,0,1] % 存在bug

for i = 1:length(taps)
    fpos(taps(i)) = 1;
end

for ii = 1:2^stg -1
    mout(ii) = inidata(stg);
    % storage of the output data
    num = mod(inidata*fpos,2);
    % calculation of the feedback data
    inidata(2:stg) = inidata(1:stg-1);

    % one shifts the register
    inidata(1) = num;
    % return feedback data


end











end