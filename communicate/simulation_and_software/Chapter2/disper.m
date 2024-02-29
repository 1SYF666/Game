% Program 2-2
% disper.m
%
% calculate dispersion and standard deviation
%
% Programmed by H.Harada
%

function  [sigma2, sigma]=disper(indata)

%****************** variables *************************
%  indata  : Input data 
%  sigma2  : dispersion
%  signa   : standard deviation
%******************************************************

% calculate average value
mvalue= sum(indata)/length(indata);

% calculate square average
sqmean= sum(indata.^2)/length(indata);

% calculate dispersion
sigma2=sqmean-mvalue^2;

% calculate standard deviation
sigma=sqrt(sigma2);

% ************************end of file***********************************
