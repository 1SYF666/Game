function [iout,qout] = func_compoversamp2(iin, qin, sample)
    [h,v] = size(iin);
    
    iout = zeros(h,v*sample);
    qout = zeros(h,v*sample);
    
    iout(:,1:sample:1+sample*(v-1)) = iin;
    qout(:,1:sample:1+sample*(v-1)) = qin;

end

