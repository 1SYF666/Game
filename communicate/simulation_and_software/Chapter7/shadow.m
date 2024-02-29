% Program 7-6
%
% shadow.m
%
% This function generates attenuation of shadowing	
%
% Programmed by F. Kojima
% Checked by H.Harada
%

function [x] =  shadow(sigma)

anoz = randn;
db = sigma * anoz;
x = power(10.0, 0.1*db);

%******* end of file *********
