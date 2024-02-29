% Program 3-13
% msk.m
%
% Simulation program to realize MSK transmission system
%
% Programmed by H.Harada and T.Yamamura
%

%******************** preparation part *************************************

sr=256000.0; % Symbol rate
ml=1;        % ml:Number of modulation levels 
br=sr.*ml;   % Bit rate
nd = 1000;   % Number of symbols that simulates in each loop
ebn0=3;      % Eb/N0
IPOINT=8;    % Number of oversamples

%******************** START CALCULATION *************************************

nloop=100;  % Number of simulation loops

noe = 0;    % Number of error data
nod = 0;    % Number of transmitted data

for iii=1:nloop
    
%*************************** Data generation ********************************  

    data1=rand(1,nd)>0.5;  % rand: built in function

%*************************** MSK Modulation ********************************  
  
    [ich,qch]=qpskmod(data1,1,nd/2,2);
    smooth1=cos(pi/2*[-1+1./4.*[0:IPOINT-1]]); %IPOINT point filtering

    for ii=1:length(ich)
       ich2((ii-1)*IPOINT+1:ii*IPOINT)=(-1)^(ii-1)*smooth1.*ich(ii);
       qch2((ii-1)*IPOINT+1:ii*IPOINT)=(-1)^(ii-1)*smooth1.*qch(ii);
    end

    ich21=[ich2 zeros(1,IPOINT/2)];
    qch21=[zeros(1,IPOINT/2) qch2];
   
%**************************** Attenuation Calculation ***********************

    spow=sum(ich21.*ich21+qch21.*qch21)/nd/2    ;  % sum: built in function
	attn=0.5*spow*sr/br/2*10.^(-ebn0/10);
	attn=sqrt(attn);                             % sqrt: built in function
   
%********************** Fading channel **********************

    %[ifade,qfade]=sefade2(data2,qdata1,itau,dlvl1,th1,n0,itnd1,now1,length(data2),fftlen2,fstp,fd,flat);

%********************* Add White Gaussian Noise (AWGN) **********************
	
    [ich3,qch3]= comb(ich21,qch21,attn);% add white gaussian noise

    syncpoint=1;

	ich5 = ich3(syncpoint+IPOINT/2:IPOINT:length(ich2));
	qch5 = qch3(syncpoint+IPOINT:IPOINT:length(ich2)+IPOINT/2);
   
    ich5(2:2:length(ich5))=-1*ich5(2:2:length(ich5));
    qch5(2:2:length(ich5))=-1*qch5(2:2:length(ich5));

%**************************** MSK Demodulation *****************************

    [demodata]=qpskdemod(ich5,qch5,1,nd/2,2);

%************************** Bit Error Rate (BER) ****************************

    noe2=sum(abs(data1-demodata));  % sum: built in function
	nod2=length(data1);  % length: built in function
	noe=noe+noe2;
	nod=nod+nod2;

	fprintf('%d\t%e\n',iii,noe2/nod2);  % fprintf: built in function

end % for iii=1:nloop    

%********************** Output result ***************************

ber = noe/nod;
fprintf('%d\t%d\t%d\t%e\n',ebn0,noe,nod,noe/nod);  % fprintf: built in function
fid = fopen('BERmsk.dat','a');
fprintf(fid,'%d\t%e\t%f\t%f\t\n',ebn0,noe/nod,noe,nod);  % fprintf: built in function
fclose(fid);

%******************** end of file ***************************