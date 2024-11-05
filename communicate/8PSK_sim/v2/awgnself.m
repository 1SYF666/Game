function [send_signal] = awgnself(send,noise,EbN0,sps)
if noise
    %　对于EDGE中8PSK，仿真发现误码率千分之一条件：Ebn0(1)>16
    Ebn0(1) = EbN0(1)-log(sps)/log(10)*10;
    send_signal = awgn(send,Ebn0(1),'measured');
else
    send_signal = send;
end
end
