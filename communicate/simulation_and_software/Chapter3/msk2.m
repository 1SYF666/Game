% Program 3-15
% msk2.m
%
% Simulation program to realize MSK transmission system
%
% Programmed by R.Sawai and H.Harada
%

%******************** Preparation part *************************************

sr=256000.0; % Symbol rate
ml=1;        % ml:Number of modulation levels 
br=sr.*ml;   % Bit rate
nd = 1000;   % Number of symbols that simulates in each loop
ebn0=5;      % Eb/N0
IPOINT=8;    % Number of oversamples

%******************** START CALCULATION *************************************

nloop=100;  % Number of simulation loops

noe = 0;    % Number of error data
nod = 0;    % Number of transmitted data

for iii=1:nloop 
    
%*************************** Data generation ******************************** 

    data1=rand(1,nd*ml)>0.5;  % rand: built in function

%*************************** MSK Modulation ********************************  
  
    data11=2*data1-1;
    data2=oversamp2(data11,length(data11),IPOINT);

    th=zeros(1,length(data2)+1);
    ich2=zeros(1,length(data2)+1);
    qch2=zeros(1,length(data2)+1);

    for ii=2:length(data2)+1
  	    th(1,ii)=th(1,ii-1)+pi/2*data2(1,ii-1)./IPOINT;
    end

    ich2=cos(th);
    qch2=sin(th);
    
%**************************** Attenuation Calculation ***********************

    spow=sum(ich2.*ich2+qch2.*qch2)/(nd*IPOINT);  % sum: built in function
    attn=0.5*spow*sr/br*10.^(-ebn0/10);
	attn=sqrt(attn);  % sqrt: built in function
   
   
%********************** Fading channel **********************
    %[ifade,qfade]=sefade2(data2,qdata1,itau,dlvl1,th1,n0,itnd1,now1,length(data2),fftlen2,fstp,fd,flat);


%********************* Add White Gaussian Noise (AWGN) **********************
	[ich3,qch3]= comb(ich2,qch2,attn);% add white gaussian noise

    syncpoint = 1;
    ich5=ich3(syncpoint:IPOINT:length(ich3));
    qch5=qch3(syncpoint:IPOINT:length(qch3));
        
%**************************** MSK Demodulation *****************************
	
    demoddata2(1,1)=-1;

    for k=3:2:nd*ml+1
         demoddata2(1,k)=ich5(1,k)*qch5(1,k-1)*cos(pi*(k))>0;
    end

    for n=2:2:nd*ml+1
         demoddata2(1,n)=ich5(1,n-1)*qch5(1,n)*cos(pi*(n))>0;
    end

    [demodata]=demoddata2(1,2:nd*ml+1);

%************************** Bit Error Rate (BER) ****************************

    noe2=sum(abs(data1-demodata));  % sum: built in function
	nod2=length(data1);  % length: built in function
	noe=noe+noe2;
	nod=nod+nod2;

	fprintf('%d\t%e\n',iii,noe2/nod2);  % fprintf: built in function


end % for iii=1:nloop    

%****************************** Data file ***********************************

ber = noe/nod;
fprintf('%d\t%d\t%d\t%e\n',ebn0,noe,nod,noe/nod);  % fprintf: built in function
fid = fopen('BERmsk2.dat','a');
fprintf(fid,'%d\t%e\t%f\t%f\t\n',ebn0,noe/nod,noe,nod);  % fprintf: built in function
fclose(fid);

%******************** end of file ***************************


