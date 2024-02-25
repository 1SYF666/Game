clear all;
close all;
L = 20000; % number of message words,原始数据长度
G = [1 1 0 1 0 0 0; 0 1 1 0 1 0 0; 1 1 1 0 0 1 0; 1 0 1 0 0 0 1]; % code generator
ebn0 = [0:8]; % db style
ebn0_1 = 10.^(ebn0/10); % linear scale, SNR
for i = 1:length(ebn0_1)
    fprintf('\n');
disp('-------- hamming code simulation starts --------')
fprintf('please wait ');
if mod(i,5) ~= 0 & i ~= length(ebn0_1)
fprintf('... ');
elseif mod(i,5) == 0 | i == length(ebn0_1)
fprintf('...\n');
end
% generate message sequence
m = randsrc(L,4); % produce L message words of 4 bits long,生成信息位
m = 0.5*(m + 1); % convert to binary seq.
% encoding
c = encode(m,7,4,'linear',G); %生成系统码字
 
% channel
c1 = 1 - 2*c; % modulation, BPSK 1 -> -1, 0 -> 1，BPSK调制
ebn0_2 = ebn0_1(i)*4/7; % es/n0 = eb/n0*coding rate
n0 = 1/ebn0_2;
sigma = sqrt(n0/2); % variance
n = sigma*randn(size(c1));%AWGN，加性高斯白噪声（additive white gaussian noise 的缩写）
r = c1 + n; %接收数据，即输出y(t)
 
r = sign(r); % hard-decision——硬判决译码
r = 0.5*(-r + 1); % demodulation, BPSK to binary, 1 -> 0, -1 -> 1，预置解调数据
m1 = decode(r,7,4,'linear',G); % decoding预置解码数据
 
% calculate error rate 误比特率
err = find(m1 ~= m); %提取不相同的码元的个数
p_hamming(i) = length(err)/(L*4); % error rate = number of errors/number of message bits
 
% file name: bpsktheory.m
% description: compute and plot error probability of bpsk in awgn
% algorithm: ber = 0.5*erfc(sqrt(eb/n0) (proakis: digital communications)
fprintf('\n');
disp('------------  bpsk theroy simulation starts ------------')
fprintf('please wait ...');
p_theroy(i) = 0.5*erfc(sqrt(ebn0_1(i)));% 理论误比特率,BPSK理论误比特率计算公式
%tp(i) = qfunc(sqrt(2*ebn0_1(i)));   % 理论误比特率 
 
% file name: bpsksim.m
% description: simulate error probability of bpsk in awgn
fprintf('\n');
disp('------------ bpsk simulation starts ------------')
fprintf('please wait ...');
   %for i = 1:length(ebn0_1)
% transmit
m_bpsk = randsrc(L,1); % generate message sequence.note: it is already bpsk modulated
% channel
esn0 = ebn0_1(i); % es/n0 = eb/n0 because 1 bit/symbol
es = 1;
n0_bpsk = es/esn0;
sigma_bpsk = sqrt(n0_bpsk/2); % var.
n_bpsk = sigma_bpsk*randn(L,1); % generate awgn
r_bpsk = m_bpsk + n_bpsk; % signal comming out of channel
% receive
m1_bpsk = sign(r_bpsk); % hard-decision
% calculate error rate
err_bpsk = find(m1_bpsk ~= m_bpsk);
p_bpsk(i) = length(err_bpsk)/L; % error rate = number of errors/ number of message bits
  if mod(i,3) == 0 & mod(i,15) ~= 0 & i ~= length(ebn0_1)
fprintf(' ...');
elseif mod(i,15) == 0 | i == length(ebn0_1)
fprintf(' ...\n');
  end
end
semilogy(ebn0,p_hamming,'M-X',ebn0,p_theroy,'B-O',ebn0,p_bpsk,'R-D');
grid on;
axis([0 8 0 0.15]) ;
xlabel('\itE\rm_b\itN\rm_0 (dB)');
ylabel('Bit Error Probability');
legend('BPSK+(5,3)汉明码仿真误比特率','BPSK理论误比特率','BPSK仿真误比特率');    % 图例
disp('-------------- simulation complete -------------')