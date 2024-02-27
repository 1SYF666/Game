function [mout] = func_mseq(stg, taps, inidata, n)

    if nargin < 4
        n = 1;
    end

    mout = zeros(n,2^stg-1);
    
    fpos = zeros(stg,1);
    
    fpos(taps) = 1;
    
    for ii=1:2^stg-1
    
        mout(1,ii) = inidata(stg);                      % storage of the output data
    
        num        = mod(inidata*fpos,2);               % calculation of the feedback data
    
    
    
        inidata(2:stg) = inidata(1:stg-1);              % one shifts the register
    
        inidata(1)     = num;                           % return feedback data
    
    end
    
    if n > 1
        for ii=2:n
            mout(ii,:) = func_shift(mout(ii-1,:),1,0);
        end
    end

end
