function [y] = desymbolmap(s_derot)
demap = s_derot;
I = real(demap);
Q = imag(demap);
theta = atan2(Q,I);
theta(theta<0) =theta(theta<0)+2*pi;
for i = 1 : 1 : length(I)
    theta_temp = theta(i);
    % 符号判决的范围[kπ/4 - π/8, kπ/4 + π/8)
    if (theta_temp >= 0 && theta_temp <pi/8)
        y(i)=0;
    elseif (theta_temp >= pi/8 && theta_temp < 3*pi/8)%pi/4-4pi/8
        y(i)=1;
    elseif (theta_temp >= 3*pi/8 && theta_temp < 5*pi/8)%4*pi/8-6*pi/8
        y(i)=2;
    elseif (theta_temp >= 5*pi/8 && theta_temp < 7*pi/8)%6pi/8-8pi
        y(i)=3;
    elseif (theta_temp >= 7*pi/8 && theta_temp < 9*pi/8)%
        y(i)=4;
    elseif (theta_temp >= 9*pi/8 && theta_temp < 11*pi/8)%
        y(i)=5;
    elseif (theta_temp >= 11*pi/8 && theta_temp < 13*pi/8)%
        y(i)=6;
    elseif (theta_temp >= 13*pi/8 && theta_temp < 15*pi/8)%
        y(i)=7;
    elseif (theta_temp >= 15*pi/8 )
        y(i)=0;
    end
end
end