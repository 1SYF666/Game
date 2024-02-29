% Program 6-3
% distance.m
%
% The calculation of distance between access point and access terminal.
%
% Input arguments
%   bstn : coordinate of access point(x,y,z)
%   mstn : coordinate of access terminals(x,y,z) (mstn is vector or matrix)
%   stp  : scale (if stp is omitted, scl=1.)
%
% Output argument
%   d    : distance
%
% Programmed by M.Okita
% Checked by H.Harada
%

function [d] = distance(bstn, mstn, scl)

if nargin < 3                                                       % stp is omitted
    scl = 1;
end

[v,h] = size(mstn);
d     = sqrt(sum(rot90(((repmat(bstn,v,1)-mstn)*scl).^2)));

%%%%%%%%%%%%%%%%%%%%%% end of file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
