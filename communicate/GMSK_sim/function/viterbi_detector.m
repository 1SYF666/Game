function [ rx_burst ] = viterbi_detector(SYMBOLS.NEXT,PREVIOUS,START,STOPS,Y,Rhh)
    [ M , Lh ] = size(SYMBOLS);
    STEPS = length(Y);

    METRIC = zeros(M,STEPS);
    SURVIVOR = zeros(M,STEPS);

    INCREMENT = make_increment(SYMBOLS,NEXT,Rhh);
    
    PS = START;

    S = NEXT(START,1);
    METRIC(S,1) = real(conj(SYMBOLS(S,1))*Y(1))-INCREMENT(PS,S);
    SURVIVOR(S,1) = START;

    S = NEXT(START,2);
    METRIC(S,1) = real(conj(SYMBOLS(S,1))*Y(1))-INCREMENT(PS,S);
    SURVIVOR(S,1) = START;

    PREVIOUS_STATES = NEXT(START,:);

    COMPLEX = 0;

    for N = 2:Lh
        if COMPLEX
            COMPLEX = 0;
        else
            COMPLEX = 1;
        end
        STATE_CNTR = 0;

        for PS = PREVIOUS_STATES
            STATE_CNTR = STATE_CNTR + 1;
            S = NEXT(PS,1);
            METRIC(S,N) = METRIC(PS,N-1)+real(conj(SYMBOLS(S,1))*Y(N)) - INCREMENT(PS,S);
            SURVIVOR(S,N) = PS;
            USED(STATE_CNTR)=S;
            STATE_CNTR = STATE_CNTR + 1;
            S = NEXT(PS,2);
            METRIC(S,N) = METRIC(PS,N-1) + real(conj(SYMBOLS(S,1))*Y(N)) - INCREMENT(PS,S);
            SURVIVOR(S,N) = PS;
            USED(STATE_CNTR) = S;
        end
        PREVIOUS_STATES = USED;
    end

    PROCESSED = Lh;

    if ~COMPLEX
        COMPLEX = 1;
        PROCESSED = PROCESSED + 1;
        N = PROCESSED;

        for S = 2:2:M
            PS = PREVIOUS(S,1);
            M1 = METRIC(PS,N-1) + real(conj(SYMBOLS(S,1))*Y(N)-INCREMENT(PS,S));
            PS = PREVIOUS(S,2);
            M2 = METRIC(PS,N-1) + real(conj(SYMBOLS(S,1))*Y(N)-INCREMENT(PS,S));
            if M1 > M2
                METRIC(S,N) = M1;
                SURVIVOR(S,N) = PREVIOUS(S,1);
            else
                METRIC(S,N) = M2;
                SURVIVOR(S,N) = PREVIOUS(S,2);
            end
        
        end

    end

    N = PROCESSED + 1;

    while N<= STEPS
        for S = 1 : 2 : M-1
            PS = PREVIOUS(S,1);
            M1 = METRIC(PS,N-1) + real(conj(SYMBOLS(S,1))*Y(N)-INCREMENT(PS,S));
            
            PS = PREVIOUS(S,2);
            M2 = METRIC(PS,N-1) + real(conj(SYMBOLS(S,1))*Y(N)-INCREMENT(PS,S));

            if M1 > M2
                METRIC(S,N) = M1;
                SURVIVOR(S,N) = PREVIOUS(S,1);
            else
                METRIC(S,N) = M2;
                SURVIVOR(S,N) = PREVIOUS(S,2);
            end
        end

        N = N+1;

        for S = 2 : 2 : M
            PS = PREVIOUS(S,1);
            M1 = METRIC(PS,N-1) + real(conj(SYMBOLS(S,1))*Y(N) - INCREMENT(PS,S));

            PS = PREVIOUS(S,2);
            M2 = METRIC(PS,N-1) + real(conj(SYMBOLS(S,1))*Y(N) - INCREMENT(PS,S));

            if M1 > M2
                METRIC(S,N) = M1;
                SURVIVOR(S,N) = PREVIOUS(S,1);
            else
                METRIC(S,N) = M2;
                SURVIVOR(S,N) = PREVIOUS(S,2);
            end
        end

        N = N+1;

    end

    BEST_LEGAL = 0;
    for FINAL = STEPS
        if METRIC(FINAL,STEPS) > BEST_LEGAL
            S = FINAL;
            BEST_LEGAL = METRIC(FINAL,STEPS);
        end
    end

    TEST(STEPS) = SYMBOLS(S,1);

    N = STEPS - 1;

    while N > 0
        S = SURVIVOR(S,N+1);
        IEST(N) = SYMBOLS(S,1);
        N = N - 1;
    end

    rx_burst(1) = IEST(1)/(1i*1*1);

    for n = 2 : STEPS
        rx_burst(n) = IEST(n)/(1i*rx_burst(n-1)*TEST(n-1));
    end

    rx_burst = (rx_burst+1)./2;

end