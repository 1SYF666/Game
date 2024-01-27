function [iout,qout]=func_qpskmod(paradata,para,nd,ml)

    m2=ml./2;
    paradata2=paradata.*2-1;
    count2=0;
    
    for jj=1:nd
    
        isi = zeros(para,1);
        isq = zeros(para,1);
    
        for ii = 1 : m2
            isi = isi + 2.^( m2 - ii ) .* paradata2((1:para),ii+count2);
            isq = isq + 2.^( m2 - ii ) .* paradata2((1:para),m2+ii+count2);
        end
    
        iout((1:para),jj)=isi;
        qout((1:para),jj)=isq;
        count2=count2+ml;
    
    end

end