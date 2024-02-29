% Program 7-7
% 
% dist.m
%
% This function generates attenuation due to distance	
%
% Programmed by F. Kojima
% Checked by H.Harada
%

function [x] =  dist(a,b,alpha)

% a,b: position of two points
% size(a) = size(b) = (1,2)

x = sqrt((a-b)*(a-b)');
x = power(x, -1.*alpha);

%******* end of file *********
