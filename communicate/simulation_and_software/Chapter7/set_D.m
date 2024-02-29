% Program 7-9
%
% set_D.m
%
% Programed by A.Kanazawa
% Checked by H.Harada
%

function D = set_D(x,y,R)	

% the function to determine the distance between BSs
i_R = sqrt(3) * R;
j_R = i_R / sqrt(2);

D2 = 0+0j;
for k = 1:x
   D2 =  D2 + i_R;
end

for k = 1:y
   D2 = D2 + j_R + j * j_R;
end

D = abs(D2);

%************ end of file ************
