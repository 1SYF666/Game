% Program 6-4
% theorys.m
%
% The calculation of the theory value of the throughput
%
% Input arguments
%   no	: protocol number   1 : Pure ALOHA
%                           2 : Slotted ALOHA
%                           3 : np-CSMA
%                           4 : Slotted np-ISMA
%   g   : offered traffic (scalar or vector)
%   a   : normalized propagation delay
%
% Output argument
%   ts  : the theory value of the throughput (scalar or vector)
%
% Programmed by M.Okita
% Checked by H.Harada
%

function [ts] = theorys(no,g,a)

switch no
case 1                                              % Pure ALOHA
    ts = g .* exp(-2*g);
case 2                                              % Slotted ALOHA
    ts = g .* exp(-g);
case 3                                              % Non-Persistent Carrier Sense Multiple Access
    ts = g .* exp(-a*g) ./ (g*(1+2*a)+exp(-a*g));
case 4                                              % Slotted Non-Persistent ISMA
    ts = a * g .* exp(-a*g) ./ (1+a-exp(-a*g));
end

%%%%%%%%%%%%%%%%%%%%%% end of file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
