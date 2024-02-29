% Program 3-23
% qammod.m
%
% This function is used for Gray coding of 16QAM modulation  
%
% programmed by R.Funada and H.Harada
%

function [iout,qout]=qammod(paradata,para,nd,ml)

%****************** variables *************************
% paradata : input data (para-by-nd matrix)
% iout :output Ich data
% qout :output Qch data
% para   : Number of paralell channels
% nd : Number of data
% ml : Number of modulation levels
% (QPSK ->2  16QAM -> 4)
% *****************************************************

% The constellation power

k=sqrt(10);
iv=[-3 -1 3 1];
               
m2=ml/2;       
count2=0; 
   
for ii=1 : nd 
     
    isi = zeros(para,1);
    isq = zeros(para,1);

    for jj=1 : ml
         
         if jj <= m2
            isi = isi +2.^( m2- jj ).*paradata((1:para),count2+jj); 
			else 
            isq = isq +2.^( ml- jj ).*paradata((1:para),count2+jj); 
         end
    end
      
    iout((1:para),ii) = iv(isi+1)./k;
    qout((1:para),ii) =iv(isq+1)./k;        
       
    count2=count2+ml;
     
end

%******************** end of file ***************************

      
 
