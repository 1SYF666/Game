% Program 7-5
%
% holdtime.m
%
% This function generates holding time	
%
% Programmed by F. Kojima
% Checked by H.Harada
%

function [x] =  holdtime(ht)

para = rand;
while para >= 1
   para = rand;
end
x = ht.*(-log(1-para));

%******* end of file *********
