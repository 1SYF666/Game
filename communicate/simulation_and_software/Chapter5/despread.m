% Program 5-8
% despread.m
%
% Data despread function
%
% Programmed by M.Okita and H.Harada
%

function [iout, qout] = despread(idata, qdata, code1)

% ****************************************************************
%   idata   : ich data sequcence
%   qdata   : qch data sequcence
%   iout    : ich output data sequence
%   qout    : qch output data sequence
%   code1    : spread code sequence
% ****************************************************************

switch nargin
case { 0 , 1 }
    error('lack of input argument');
case 2
    code1 = qdata;
    qdata = idata;
end

[hn,vn] = size(idata);
[hc,vc] = size(code1);

vn      = fix(vn/vc);

iout    = zeros(hc,vn);
qout    = zeros(hc,vn);

for ii=1:hc
    iout(ii,:) = rot90(flipud(rot90(reshape(idata(ii,:),vc,vn)))*rot90(code1(ii,:),3));
    qout(ii,:) = rot90(flipud(rot90(reshape(qdata(ii,:),vc,vn)))*rot90(code1(ii,:),3));
end

%******************************** end of file ********************************
