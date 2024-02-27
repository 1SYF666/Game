function [iout, qout] = func_spread(idata, qdata, code1)

    switch nargin
        case { 0 , 1 }
            error('lack of input argument');
        case 2
    
            code1 = qdata;
            qdata = idata;
    
    end
    
    [hn,vn] = size(idata);
    [hc,vc] = size(code1);
    

    if hn > hc
        error('lack of spread code sequences');   
    end

    iout = zeros(hn,vn*vc);
    qout = zeros(hn,vn*vc);
    
    
    for ii=1:hn
    
        iout(ii,:) = reshape(rot90(code1(ii,:),3)*idata(ii,:),1,vn*vc);
        qout(ii,:) = reshape(rot90(code1(ii,:),3)*qdata(ii,:),1,vn*vc);
    
    end
end