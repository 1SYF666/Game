function [G_FUN,Q_FUN] = ph_g(Tb,OSR,BT)
    % SIMULATION SAMPLE FREQUENCY
    Ts = Tb/OSR;
    
    % PREPARING VECTORS FOR DATA PROCESSING
    PTV = -2*Tb : Ts : 2*Tb-Ts;
    RTV = -Tb/2 : Ts : Tb/2-Ts;
    
    % GENERATE GAUSSIAN SHAPED PULSE
    sigma = sqrt( log(2) )/(2*pi*BT);
    gauss = ( 1/(sqrt(2*pi)*sigma*Tb) )*exp( -PTV.^2/(2*sigma^2*Tb^2) );
    
    % GENERATE RECTANGULAR PULSE
    rect = 1/(2*Tb) * ones(size(RTV));
    
    % CALCULATE RESULTING FREQUENCY PULSE
    G_TEMP = conv(gauss,rect);

    % TRUNCATING THE FUNCTION TO 3xTb
    G = G_TEMP(OSR+1:4*OSR);

    % TRUNCATION IMPLIES THAT INTEGRATING THE FREQUENCY PULSE
    % FUNCTION WILL NOT EQUAL 0.5, HENCE THE RE-NORMALIZATION
    G_FUN = ( G-G(1) )./( 2*sum(G-G(1)) );

    % CALCULATE RESULTING PHASE PULSE
    Q_FUN = cumsum(G_FUN);
end