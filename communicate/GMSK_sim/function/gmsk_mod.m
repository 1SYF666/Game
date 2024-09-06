function [I,Q] = gmsk_mod(BURST,Tb,OSR,BT)
    
    % ACCUIRE GMSK FREQUENCY PULSE AND PHASE FUNCTION
    [g,q] = ph_g(Tb,OSR,BT);
    
    % PREPARE VECTOR FOR DATA PROCESSING
    bits = length(BURST);
    f_res = zeros(1 , (bits+2)*OSR);

    % GENERATE RESULTING FREQUENCY PULSE SEQUENCE
    for n = 1 : bits
        f_res( (n-1)*OSR+1 : (n+2)*OSR ) = ... 
           f_res( (n-1)*OSR+1 : (n+2)*OSR ) + BURST(n).*g; 
    end

    % CALCULATE RESULTING PHASE FUNCTION
    theta = pi*cumsum(f_res);

    % PREPARE DATA FOR OUTPUT
    I = cos(theta);
    Q = sin(theta);
    
end