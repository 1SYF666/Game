%% ************ convoltion code sim *************%%
%% ****** date: 20241111    author:shenyifu *****%% 
%% 参考CSDN博客：MATLAB （n,k,m）卷积码原理及仿真代码-小小低头哥
clear;clc;
close all;
%% (2,1,3)或者(2,1,2)卷积码
%{
    (2,1,3)卷积码中3表示：当前输入+两个寄存器
    (2,1,2)卷积码中2表示：两个寄存器
    (2,1,3)和(2,1,2)应该是表示相同卷积码
%}
G = [1,0,1;1,1,1];          %生成多项式对应八进制(5,7),(1, 0, 1 <--> uk, uk-1, uk-2)
M = [1 1 1 0 1 0 0 0 1 0 1 1 0 0 0];      %信息
C = conv_encode(M,G);

%% viterbi译码(硬判决)
%{
    参考CSDN博客-The Big Tom
    (2,1,2)通常接收端会在一帧的信息比特发完末尾加入0 0，这样接收端的译码器就会回归00状态
%}
%% 初始化
decode_input = C(5:end) ;  
[n,N]= size(G);
k = 1;
number_of_states = 2^(N-1);  % 状态数 S0(00) S1(01) S2(10) S3(11) 
%{
    number_of_states =  2^(k*(N-i)); 该计算公式对吗
%}
% 输入矩阵
input = inf(number_of_states);
% 状态转移矩阵
nextstate = zeros(number_of_states,2^k);
% 输出矩阵
output = zeros(number_of_states,2^k);
%%%% 对各个状态进行运算，得到输入矩阵、状态转移矩阵与输出矩阵 %%%%
for s = 0:number_of_states-1    
    %对前一时刻状态到下一时刻状态之间的各条支路进行运算
    for t = 0:2^k-1         
        % next_state_function函数产生移存器跳转到的下一状态及当前时刻编码器内容
        [next_state,memory_contents] = next_state_function(s,t,N,k);
        % 从上至下表示当前状态s0,s1,s2……
        % 从左至右表示下一状态s0,s1,s2……
        % 内容为经由支路编号
        input(s+1,next_state+1) = t;                %输入矩阵
        % 各条支路编码输出
        branch_output = num2str( rem(memory_contents*G',2) ); 
        
        % 从上至下表示当前状态s0,s1,s2……
        % 从左至右为经由支路编号0,1,2……
        % 内容为下一时刻状态s
        nextstate(s+1,t+1) = next_state;            %状态转移矩阵
        % 从上至下表示当前状态s0,s1,s2……
        % 从左至右表示经由支路编号0,1,2……
        % 内容为相应分支输出编码
        output(s+1,t+1) = bin2dec(branch_output);	%输出矩阵
    end
end

% 状态度量矩阵
% 第一列为当前时刻各状态的路径度量
% 第二列为下一时刻各状态的路径度量（即更新后的状态度量）
state_metric = zeros(number_of_states,2);
% 网格深度
depth_of_trellis = length(decode_input)/n;
decode_input_matrix = reshape(decode_input,n,depth_of_trellis);          
% 幸存状态矩阵
% survivor_state = zeros(number_of_states,depth_of_trellis+1);
survivor_state = inf(number_of_states,depth_of_trellis+1);
% 各个状态的初始路径度量
for i =1:N-1
    % 网格图从全零状态出发，直到所有状态都有路径到达
    for s = 0:2^(i-1)-1    %********************************待修改***************************
        %对前一时刻状态到下一时刻状态之间的各条分支进行运算
        for t = 0:2^k-1  % 每种状态输入为t 
            % 分支度量
            branch_metric = 0;
            % 将各分支的编码输出以二进制形式表示
            bin_output = dec2bin(output(s+1,t+1),n);
            for j = 1:n
                % 分支度量的计算
                branch_metric = branch_metric + metric_hard(decode_input_matrix(j,i),str2num(bin_output(j)));
            end
            % 各个状态路径度量值的更新
            % 下一时刻路径度量=当前时刻路径度量+分支度量
            state_metric(nextstate(s+1,t+1)+1,2) = state_metric(s+1,1) + branch_metric;
            % 幸存路径的存储
            % 一维坐标表示下一时刻状态
            % 二维坐标表示该状态在网格图中的列位置
            % 内容为当前时刻状态
            survivor_state(nextstate(s+1,t+1)+1,i+1) = s;
        end
    end
    % 对所有状态完成一次路径度量值计算后
    % 状态度量矩阵第一列（当前状态路径度量）
    % 与第二列（下一状态路径度量）对换
    % 方便下一时刻继续迭代更新
    state_metric = state_metric(:,2:-1:1);
end


% 各个状态的路径度量更新
for i = N:depth_of_trellis-(N-1)
    % 记录某一状态的路径度量是否更新过
    flag = zeros(1,number_of_states);
    for s = 0:number_of_states-1
       for t = 0:2^k-1
           branch_metric = 0;
           bin_output = dec2bin(output(s+1,t+1),n);
           for j = 1:n
              branch_metric = branch_metric + metric_hard(decode_input_matrix(j,i),str2num(bin_output(j)));
           end
           % 若某状态的路径度量未被更新
           % 或一次更新后的路径度量大于本次更新的路径度量
           % 则进行各状态路径度量值的更新
           if((state_metric(nextstate(s+1,t+1)+1,2)>state_metric(s+1,1)+branch_metric) || flag(nextstate(s+1,t+1)+1) == 0)
               state_metric(nextstate(s+1,t+1)+1,2) = state_metric(s+1,1)+ branch_metric;
               survivor_state(nextstate(s+1,t+1)+1,i+1) = s;
               % 一次更新后flag置为1
               flag(nextstate(s+1,t+1)+1) = 1;
           end
       end 
    end
    state_metric = state_metric(:,2:-1:1);
end

% 结尾译码：网格图回归全零状态
for i = depth_of_trellis-(N-1)+1:depth_of_trellis
flag = zeros(1,number_of_states);
%上一比特存留的状态数
    last_stop_states = number_of_states/(2^((i-depth_of_trellis+N-2)*k));   
    % 网格图上的各条路径最后都要回到同一个全零状态
    for s = 0:last_stop_states-1
        branch_metric = 0;
        bin_output = dec2bin(output(s+1,1),n);
        for j = 1:n
           branch_metric = branch_metric+ metric_hard(decode_input_matrix(j,i),str2num(bin_output(j)));
        end
        if((state_metric(nextstate(s+1,1)+1,2) > state_metric(s+1,1)+branch_metric) || flag(nextstate(s+1,1)+1) == 0)
            state_metric(nextstate(s+1,1)+1,2) = state_metric(s+1,1)+ branch_metric;
            survivor_state(nextstate(s+1,1)+1,i+1) = s;
            flag(nextstate(s+1,1)+1) = 1;
        end
    end
    state_metric = state_metric(:,2:-1:1);
end

%%%%%% 根据幸存状态矩阵开始逐步向前回溯，得到译码输出 %%%%%%%
sequence = zeros(1,depth_of_trellis+1);
% 逐步向前回溯
for i = 1:depth_of_trellis
   sequence(1,depth_of_trellis+1-i) = survivor_state(sequence(1,depth_of_trellis+2-i)+1,depth_of_trellis+2-i);
end

% 译码输出
decode_output_matrix = zeros(k,depth_of_trellis-N);
for i = 1:depth_of_trellis-N
    % 由输入矩阵得到经由支路编号
    dec_decode_output = input(sequence(1,i)+1,sequence(1,i+1)+1);
    % 将支路编号转为二进制码元，即为相应的译码输出
    bin_decode_output = dec2bin(dec_decode_output,k);     
    bin_decode_output = double(bin_decode_output) - '0';  % 将字符串转变为double数组
    % 将每一分支的译码输出存入译码输出矩阵中
    decode_output_matrix(:,i) = bin_decode_output(k:-1:1)';
end

% 重新排列译码输出序列
decode_output = reshape(decode_output_matrix,1,k*(depth_of_trellis-N));


















