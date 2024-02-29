% Program 3-24
% qamdemod.m
%
% Function to decode 16QAM modulation
%
% programmed by R.Funada and H.Harada
%

function [demodata]=qamdemod(idata,qdata,para,nd,ml)

%****************** variables *************************
% idata :input Ich data
% qdata :input Qch data
% demodata: demodulated data (para-by-nd matrix)
% para   : Number of paralell channels
% nd : Number of data
% ml : Number of modulation levels
% (QPSK ->2  16QAM -> 4)
% *****************************************************

k=sqrt(10);
idata=idata.*k;
qdata=qdata.*k;
demodata=zeros(para,ml*nd);

m2=ml/2;       
count2=0; 

for ii = 1:nd
      
   	a=1;
    b=1;
   	i_lngth=0;
    q_lngth=0;
      
    for jj= 1:m2
        
       if jj ~= 1           
         
          	if demodata((1:para),jj-1+count2)==1
               	a=-a;               
           	end
      
           	if demodata((1:para),m2+jj-1+count2)==1
               	b=-b;
           	end

            i_lngth=i_lngth+i_plrty.*2.^(m2-jj+1);
            q_lngth=q_lngth+q_plrty.*2.^(m2-jj+1);
        end
         
        if idata((1:para),ii) >= i_lngth
           demodata((1:para),jj+count2)=a>=0;
           i_plrty=1;
        else
       	   demodata((1:para),jj+count2)=a<=0;
           i_plrty=-1;
        end
         
        if qdata((1:para),ii) >= q_lngth
           demodata((1:para),m2+jj+count2)=b>=0;
           q_plrty=1;  
        else
 		   demodata((1:para),m2+jj+count2)=b<=0;
           q_plrty=-1;
        end
            
    end  % for jj= 1:m2
      
    count2=count2+ml;
             
 end  % for ii = 1:nd          

%******************** end of file ***************************
