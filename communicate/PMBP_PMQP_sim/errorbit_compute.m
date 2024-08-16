%% 一次误码率计算
%% “注意是一次，适用于matlab仿真计算误码率”
function [error_rate_final,totalbit] = errorbit_compute(input,database)
jt=input;
jd=database;
max_td=10;                    % 最大延迟
slip_L=200;                    % 相关长度
correlation=zeros(1,max_td);
for i = 1:1:max_td
    correlation(i) = abs(sum(jt(i:i-1+slip_L).*jd(1:slip_L)));
end
correlation_loc=find(correlation==max(correlation));
% figure;plot(input(correlation_loc:end));hold on;plot(0.95*database);title("input&database compare");
% figure;plot(input);hold on;plot(0.95*database(correlation_loc:end)); title("input&database compare");

% fprintf("延迟了     %d点\n",correlation_loc);

% 解调码元长度与基带码元可能和长度不一样，
% 无非是最后一段多几个点或者少几个点，这样利用plot画图出现问题
% 故在下面加个条件语句
if length(input)<length(database)
    compare_length=length(input)-100;
else
    compare_length=length(database)-100;
end

start_symbol=1000;                          % 开始匹配位置
totalbit=compare_length-start_symbol+1;  % 一次比较总比特数

% 解决起始点检测位置与实际位置相差若干步的问题
max_delay=correlation_loc;                          % 估计最大延迟
error_count=zeros(1,max_delay+1);
error_rate=zeros(1,max_delay+1);
for i=0:1:max_delay
    delay=correlation_loc-i;
    for j=start_symbol:compare_length
        if input(j) ~= database(j-delay)
            error_count(i+1)=error_count(i+1)+1;   % matlab语法中数组从1开始
        end
    end
    error_rate(i+1)=error_count(i+1)/totalbit;
end

error_min_index=find(error_rate==min(error_rate)); % 找最小值
if size(error_min_index,2)>1
    error_min_index1 = error_min_index(1); 
else
    error_min_index1 = error_min_index;
end
error_rate_final=error_rate(error_min_index1);      % 一次比较误码率
end