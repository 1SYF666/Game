% Program 5-11
% comb2.m
%
% Function to add white gaussian noise
%
% Programmed by H.Harada and M.Okita
%

function [iout, qout] = comb2(idata, qdata, attn)

%****************** variables *************************
% idata : input Ich data
% qdata : input Qch data
% iout   output Ich data
% qout   output Qch data
% attn : attenuation level caused by Eb/No or C/N
%******************************************************

v = length(idata);
h = length(attn);

iout = zeros(h,v);
qout = zeros(h,v);

for ii=1:h
    iout(ii,:) = idata + randn(1,v) * attn(ii);
    qout(ii,:) = qdata + randn(1,v) * attn(ii);
end

%******************************** end of file ********************************