% Program 3-17
% oversamp2.m
%
% Function to sample "sample" time
%
% programmed by H.Harada
%

function [out] = oversamp2( iin, ntot , sample) 

% *************************************************************
% iin     : input sequence
% ntot   : Number of burst symbol
% sample : Number of oversample
% *************************************************************

for k=1:sample
	out(k:sample:k+sample*(ntot-1))=iin;
end

%******************** end of file ***************************