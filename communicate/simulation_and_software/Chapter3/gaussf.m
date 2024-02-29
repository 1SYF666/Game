% Program 3-13
% gaussf.m
%
% Function to form Gaussaian filter
%
% programmed by H.Harada


function [xh] = gaussf(B,irfn,ipoint,sr,ncc)

%**************************************************************** 
%	irfn		: Number of symbols to use filtering
%	ipoint		: Number of samples in one symbol
%	sr		: symbol rate
% 	B		:  filter coeficiense
%	ncc;		: 1 -- transmitting filter  0 -- receiving filter
%**************************************************************** 

point = ipoint;

tr = sr ;  
n = ipoint .* irfn;
mid = ( n ./ 2 ) + 1;
fo=B/sqrt(2*log(2));

for i = 1 : n 

  icon = i - mid;
  ym = icon;

 xt=1/2*(erf(-sqrt(2/log(2))*pi*B*(ym/ipoint-1/2)/tr)+erf(sqrt(2/log(2))*pi*B*(ym/ipoint+1/2)/tr));
      
    
    
  if ncc == 0	                        % in the case of receiver
     xh( i ) = xt ;
  elseif ncc == 1                       % in the case of transmitter
     xh( i ) = xt;
  else
    error('ncc error');
  end   
  end  

%******************** end of file ***************************