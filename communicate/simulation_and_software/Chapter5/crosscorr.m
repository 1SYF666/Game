% Program 5-2
% crosscorr.m
%
% Crosscorrelation function of a sequence
%
% Programmed by M.Okita and H.Harada
%

function [out] = crosscorr(indata1, indata2, tn)

% *************************************************************
% indata1 : input sequence1
% indata2 : input sequence2
% tn      : number of period
% out     : crosscorrelation data
% *************************************************************

if nargin < 3
    tn = 1;
end

ln  = length(indata1);
out = zeros(1,ln*tn);

for ii=0:ln*tn-1
    out(ii+1) = sum(indata1.*shift(indata2,ii,0));
end

%******************************** end of file ********************************
