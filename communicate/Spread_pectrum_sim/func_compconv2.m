function [iout, qout] = func_compconv2(idata, qdata, filter)



iout = conv2(idata,filter);

qout = conv2(qdata,filter);

