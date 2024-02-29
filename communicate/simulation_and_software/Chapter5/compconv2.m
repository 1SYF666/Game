% Program 5-10
% compconv2.m
%
% Function to perform convolution between signal and filter
%
% Programmed by H.Harada and M.Okita
%

function [iout, qout] = compconv2(idata, qdata, filter)

% ****************************************************************
%   idata   : ich data sequcence
%   qdata   : qch data sequcence
%   iout    : ich output data sequence
%   qout    : qch output data sequence
%   filter  : filter tap coefficience
% ****************************************************************

iout = conv2(idata,filter);
qout = conv2(qdata,filter);

%******************************** end of file ********************************