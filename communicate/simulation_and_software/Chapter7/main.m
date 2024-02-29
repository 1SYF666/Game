% Program 7-8
%
% main.m
%
% Programmed by A.Kanazawa
% Checked by H.Harada
%

clear 
%%%%%%%%%%%%%%% Status initialization
I = 1;			% The cluster size is determined from I and J. (n = I*I + J*J + I*J)
J = 2;
r = 100;				% the radius of the cell[m]
h = 0; 					% the height of the BS[m]

D = set_D(I,J,r);
station = stationInit(D);
xbs = real(station); 	% The x axis of the BS
ybs = imag(station);	% The y axis of the BS

sigma = 6.5;			% standard deviation of shadowing

alpha = 3.5;			% path loss factor
% margin = 0;			% The parameter for power control

% Characteristics of antenna gain decision for BS
w_HBS = 60;					% [horizontal]: beam width at BS for the target direction [degree]
backg_BS = -100;			% [horizontal]: antenna gain at BS for the opposite direction [dB]
w_VBS = 360;				% [vertical]: beam width at BS [degree]

% Characteristics of antenna gain decision for MS
w_HMS = 360;				% [horizontal]: beam width at MS for the target direction [degree]
backg_MS = -100;			% [horizontal]: antenna gain at MS for the opposite direction [dB]
w_VMS = 360;				% [vertical]:beam width at MS [degree]

if h == 0, 						 % In the case of macro cell situation, 
   w_VBS = 360; w_VMS = 360; 	 % 		the effect of beam tilt becomes less.
end								 %

% Antenna gain calculation of each BS
g_HBS = antgain(w_HBS, backg_BS);
g_VBS = antgain(w_VBS, 0);
g_HMS = antgain(w_HMS, backg_MS);
g_VMS = antgain(w_VMS, 0);

%%%%%%%%%%%%%%% Loop
%-------Initialization of MS positions
N=1000;					% The number of repeat 
for num = 1:N,
	Rx = rand(1,19);	% the random values: [0-1]
	Ry = rand(1,19);	% the random values: [0-1]
	X = r*Rx;			
	Y = Ry.* sqrt ( r ^2 - X.^2 );	

	tx = 2*((rand(1,19)>0.5) -0.5);	% the random values: -1 or 1
	ty = 2*((rand(1,19)>0.5) -0.5);	% the random values: -1 or 1
	x= X.* tx;	% The x axis of the MS when we regard the position of each BS as (0,0)
	y= Y.* ty;	% The y axis of the MS when we regard the position of each BS as (0,0)

	x2 = x+xbs.';	% The x axis of the MS when we regard the position of central BS as (0,0)
	y2 = y+ybs.'; % The y axis of the MS when we regard the position of central BS as (0,0)

	z(1,:) = x + i * y;		% The complex expression of MS when we regard the position of each BS as (0,0)
	z(2,:) = x2+ i * y2;	% The complex expression of MS when we regard the position of central BS as (0,0)

	d(1,:) = abs(z(1,:));	%	The distance between BS_i and MS_i in horizontal axis
	d(2,:) = abs(z(2,:));	%	The distance between central BS and MS_i in horizontal axis
	d2 = sqrt(d.^2 + h^2); 	%	The distance 

	phai(1,:) = angle(z(1,:));	%	The angle difference between BS_i and MS_i [rad]
	phai(2,:) = angle(z(2,:));	%	The angle difference between central BS and MS_i [rad]
	deg = phai*180/pi;			% the conversion of radian to degree
   
   if h ==0, degH = 90*ones(1,19); 
      else
         phaiH = atan(d(2,:)/h); % the elevation angle between central BS and MS_i
         degH = phaiH*180/pi; 			% the conversion of radian to degree
      end

%-------shadowing----------
	for m = 1:19 	
		g(m) = 10*log10(shadow(sigma));
	end
% ----- propagation loss -----
	Loss(1,:) = 10 * log10(d2(1,:).^alpha);		% The propagation loss from MS_i to BS_i [dB]
	Loss(2,:) = 10 * log10(d2(2,:).^alpha);		% The propagation loss from MS_i to BS_0 [dB]
	Loss_max = 10 * log10(r.^alpha);	% The propagation loss from the cell boundary to BS [dB]
   
% Free space loss   
%    wl = 0.1;
%   Loss(1,:) = 10 * log10((4*pi*d2(1,:)/wl).^2);		% The propagation loss from MS_i to BS_i [dB]
%	Loss(2,:) = 10 * log10((4*pi*d2(2,:)/wl).^2);		% The propagation loss from MS_i to BS_0 [dB]
%	Loss_max = 10 * log10((4*pi*r/wl).^2);	% The propagation loss from the cell boundary to BS [dB]

%--------Transmission power level of each MS [dB]------------

	Ptm_0= Loss_max*ones(1,19);			% no power control
 %  Ptm_0= Loss(1,:) + margin;			% power control (with margin [dB])
 
 %--------- Calculation of antenna gain for the target direction
 
	deg_B = deg(2,1)-deg(2,:); % the angle difference between the MS_0 and MS_i from central BS
	deg_M = deg(1,:)-deg(2,:);% the angle difference between the BS_0 and BS_i from MS_i
   
    degHBS = mod(round(deg_B),360);	
    degHMS = mod(round(deg_M),360);
    degVBS = round(degH-degH(1));	% the angle difference in vertical direction between MSs and central BS
    degVMS = degVBS;		% the angle difference in vertical direction between MSs and central BS
    
    %-----Calculation of CIR at centered BS  
    %Control
	CIdB_a= Ptm_0(1:19)+g_HBS(degHBS(1:19)+1) + g_VBS(degVBS(1:19)+1) + g_HMS(degHMS(1:19)+1) + g_VMS(degVMS(1:19)+1)- Loss(2,1:19)-g(1:19);	% Received level at central BS (beam forming)
	CIw_a = 10 .^ ( CIdB_a ./ 10 );				% dB Å® W
	isum_a = sum( CIw_a(2:19));
	CIR_a(num) =   CIw_a(1) / isum_a;
	%No Control
	CIdB_o= Ptm_0(1:19)- Loss(2,1:19)-g(1:19);	 % Received level at centered BS (Omni)	
	CIw_o= 10 .^ ( CIdB_o ./ 10 ); 				% dB Å® W
	isum_o = sum( CIw_o(2:19));
	CIR_o(num) =  CIw_o(1) / isum_o;
	   
   %-----Calculation of CIR under various w_HBS
   %ii = 1;
   %for w_HBS2=30:10:180,
   %		g_HBS2 = antgain(w_HBS2, backg_BS);    
   %	CIdB_a2= Ptm_0(1:19)+g_HBS2(degHBS(1:19)+1) + g_VBS(degVBS(1:19)+1) + g_HMS(degHMS(1:19)+1) + g_VMS(degVMS(1:19)+1)- Loss(2,1:19)-g(1:19);	% Received level at central BS (beam)
   %	CIw_a2 = 10 .^ ( CIdB_a2 ./ 10 );				% dB Å® W
   %	ciw_a2 = sum( CIw_a2(2:19));
   %	CIR_a2(num,ii) =   CIw_a2(1) / ciw_a2;
   %   ii = ii+1;   
   %end
	
end
%-----statistics

CA = 10 * log10(sum(CIR_a)/N);
CO = 10 * log10(sum(CIR_o)/N);

%----result
CA-CO									% Improvement

%-----Calculation of CIR under various w_HBS
% CA2= 10 * log10(sum(CIR_a2)/N);
% CA2-CO
% plot(30:10:180,CA2-CO)

%************ End of file ************
