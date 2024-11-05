function [headframe,tailframe] =coarse_synchronisation(receive_rcos,sync,sps)
DEBUG = 1;
synclen = length(sync);
realsignal = real(receive_rcos);
synci = real(sync);
for k = 1 : length(realsignal)-synclen*sps
    oneSync = realsignal(k:sps:k+synclen*sps-1);
    cor(k) = abs(oneSync*synci');
end

if DEBUG
    figure;plot(cor);title("粗同步滑动窗示意图");
end

% 搜索峰值
step_threshold = 20;
search_len = 25;
[sortvalue,sortindex] = sort(cor);
% 选择最值
relay_index1 = sortindex(end-search_len:end);
relay_index2(1) =  relay_index1(end);
kk = 1;
for k = length(relay_index1)-1 : -1 : 1
    if ~sum( abs(relay_index1(k)-relay_index2)<step_threshold )
        kk = kk + 1;
        relay_index2(kk) = relay_index1(k);
    else
        continue;
    end
end
[sort_value,sort_index] = sort(relay_index2);

% 确定帧头帧尾
signallen =  length(realsignal);
locarray = sort_value;
totalframelen = 750;
headdistanclen = 50+4+208;  % 根据EPDT协议而定

headframe = [];
tailframe = [];
for k = 1 : length(locarray)
    headframetemp = locarray(k) - (headdistanclen)*sps;
    tailframetemp = locarray(k)+(totalframelen - headdistanclen)*sps;
    if headframetemp< 1 || tailframetemp> signallen
        fprintf("this burst is not complete!\n");
        continue;
    end
    headframe = [headframe headframetemp];
    tailframe = [tailframe tailframetemp];
end
end