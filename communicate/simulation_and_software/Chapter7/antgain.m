% Program 7-11
% 
% antgain.m
%
% Programmed by A.Kanazawa
% Checked by H.Harada
%

function gain = antgain(width, back)

theta = [0:359];
gain = zeros(1,360);

if width ~= 360, 

    n = log10(sqrt(1/2))./log10(cos(width*pi/360));	% the coefficient n 
    gain(1:89) = 10*log10(cos(theta(1:89)*pi/180).^n);	%[dB] Antenna gain
    gain(272:360) = 10*log10(cos(theta(272:360)*pi/180).^n); %[dB] Antenna gain 

    if back ~= 0,    %definition of antenna gain for horizontal direction[dB]
        gain(90:271) = back;					%[dB]
    end

end

%************ end of file************
