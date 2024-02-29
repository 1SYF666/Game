% Program 2-3
% main.m
%
% calculate mean, dispersion and standard deviation for the vector data
%
% Programmed by H.Harada
%

data=rand(1,20);
mvalue2=mvalue(data);
[sigma2, sigma]= disper(data);
fprintf( 'meanvalue = %f \n',mvalue2);
fprintf( 'dispersion = %f \n', sigma2);
fprintf( 'standard deviation=%f \n',sigma);

% ************************end of file***********************************
