
function [iout, qout] = func_comb2(idata, qdata, attn)
    v = length(idata);
    h = length(attn); 
    iout = zeros(h,v);
    qout = zeros(h,v);
  
    for ii=1:h
        iout(ii,:) = idata + randn(1,v) * attn(ii);
        qout(ii,:) = qdata + randn(1,v) * attn(ii);
    
    end
end