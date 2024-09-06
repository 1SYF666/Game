function DIFF_ENC_DATA = diff_enc(BURST)

    L = length(BURST);
    d_hat = zeros(1, L);
    alpha = zeros(1, L);

    data = [1 BURST];

    for n = 1+1 : (L+1)
        d_hat(n-1) = xor( data(n),data(n-1) );
    end

    alpha = 1 - 2.*d_hat ; % 1 -> -1; 0 -> 1

    DIFF_ENC_DATA = alpha;
end