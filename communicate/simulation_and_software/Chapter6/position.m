% Program 6-2
% positon.m
%
% Positioning of the access terminals in the area of the radius r.
%
% Input arguments
%   r     : The radius r that an access point is an origin.
%   n     : The number of access terminals.
%   h     : h=0 -> z=0  h=1 -> z=1`4
%
% Output argument
%   posxy : (x,y,z)
%
% Programmed by M.Okita
% Checked by H.Harada
%

function [posxy] = position(r, n, h)

ms = 4 * r;                                         % calculation of the number of maximum position
ms = ms + 4 * sum(fix(sqrt(r^2-[1:r-1].^2)));

if n > ms
    error('n exceeds the number of position.');
end

posxy = zeros(n,3);                                                 % initialize

for ii=1:n
    while 1
        xx  = round(r*rand) * sign(sin(2*pi*rand));                 % x and y are decided at random
        yy  = round(r*rand) * sign(cos(2*pi*rand));
        if xx^2+yy^2 <= r^2 & (xx~=0 | yy~=0)                       % (xx,yy) is not (0,0) in the area
            if length(find(posxy(:,1)==xx & posxy(:,2)==yy)) == 0   % (xx,yy) are vacant
                break
            end
        end
    end
    posxy(ii,[1 2]) = [xx yy];
    if h == 1
        while 1
            posxy(ii,3) = round(50*rand) / 10;
            if 1 <= posxy(ii,3) & posxy(ii,3) <= 4
                break
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%% end of file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
