% Program 7-10
%
% stationInit.m
%
% Programmed by A.Kanazawa
% Checked by H.Harada
%

function STATION = stationInit(d)
% The function to determine the position of BS
STATION = zeros(19,1);

for i = 0:5
   STATION(i + 2, 1) = d * cos(i * pi / 3.0) + j * d * sin(i * pi / 3.0);
end
for i = 0:11
   STATION(i + 8, 1) = 2 * d * cos(i * pi / 6.0) + j * 2 * d * sin(i * pi / 6.0);
end
%************ end of file************
