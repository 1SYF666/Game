% Program 3-3
% hrollfcoef.m
%
% Generate coefficients of Nyquist filter
%
% programmed by H.Harada
%

function [xh] = hrollfcoef(irfn,ipoint,sr,alfs,ncc)

%****************** variables *************************
% irfn	 : Number of symbols to use filtering
% ipoint : Number of samples in one symbol
% sr     : symbol rate
% alfs   : rolloff coeficiense
% ncc    : 1 -- transmitting filter  0 -- receiving filter
% *****************************************************

xi=zeros(1,irfn*ipoint+1);
xq=zeros(1,irfn*ipoint+1);

point = ipoint;
tr = sr ;  
tstp = 1.0 ./ tr ./ ipoint;
n = ipoint .* irfn;
mid = ( n ./ 2 ) + 1;
sub1 = 4.0 .* alfs .* tr;		% 4*alpha*R_s

for i = 1 : n 

  icon = i - mid;
  ym = icon;

  if icon == 0.0 
    xt = (1.0-alfs+4.0.*alfs./pi).* tr;  % h(0) 
  else 
    sub2 =16.0.*alfs.*alfs.*ym.*ym./ipoint./ipoint; 
    if sub2 ~= 1.0 
      x1=sin(pi*(1.0-alfs)/ipoint*ym)./pi./(1.0-sub2)./ym./tstp;
      x2=cos(pi*(1.0+alfs)/ipoint*ym)./pi.*sub1./(1.0-sub2);
      xt = x1 + x2;  % h(t) plot((1:length(xh)),xh)
    else % (4alphaRst)^2 = 1plot((1:length(xh)),xh)
      xt = alfs.*tr.*((1.0-2.0/pi).*cos(pi/4.0/alfs)+(1.0+2.0./pi).*sin(pi/4.0/alfs))./sqrt(2.0);
    end  %  if sub2 ~= 1.0 
  end	%  if icon == 0.0 

  if ncc == 0	                        % in the case of receiver
    xh( i ) = xt ./ ipoint ./ tr;	% normalization
  elseif ncc == 1 % in the case of transmitter
    xh( i ) = xt ./ tr;          % normalization
  else
    error('ncc error');
  end    %  if ncc == 0	

end  % for i = 1 : n 

%******************** end of file ***************************
