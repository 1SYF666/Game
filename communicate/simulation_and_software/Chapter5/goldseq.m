% Program 5-5
% goldseq.m
%
% The generation function of Gold sequence
%
% Programmed by M.Okita and H.Harada
%

function [gout] = goldseq(m1, m2, n)

% ****************************************************************
% m1 : M-sequence 1
% m2 : M-sequence 2
% n  : Number of output sequence(It can be omitted)
% gout : output Gold sequence
% ****************************************************************

if nargin < 3
    n = 1;
end

gout = zeros(n,length(m1));

for ii=1:n
    gout(ii,:) = xor(m1,m2);
    m2         = shift(m2,1,0);
end

%******************************** end of file ********************************