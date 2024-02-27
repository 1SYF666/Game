function [demodata]= func_qpskdemod(idata,qdata,para,nd,ml)

    demodata=zeros(para,ml*nd);
    demodata((1:para),(1:ml:ml*nd-1))=idata((1:para),(1:nd))>=0;
    demodata((1:para),(2:ml:ml*nd))=qdata((1:para),(1:nd))>=0;
    
end