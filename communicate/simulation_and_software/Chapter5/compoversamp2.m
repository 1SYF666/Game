% Program 5-9
% compoversamp2.m
%
% Function to sample "sample" time
%
% programmed by H.Harada and M.Okita
%

function [iout,qout] = compoversamp2(iin, qin, sample)

% *************************************************************
% iin     : input Ich sequence
% qin     : input Qch sequence
% iout    : ich output data sequence
% qout    : qch output data sequence
% sample  : Number of oversamples
% *************************************************************

[h,v] = size(iin);

iout = zeros(h,v*sample);
qout = zeros(h,v*sample);

iout(:,1:sample:1+sample*(v-1)) = iin;
qout(:,1:sample:1+sample*(v-1)) = qin;

%******************************** end of file ********************************