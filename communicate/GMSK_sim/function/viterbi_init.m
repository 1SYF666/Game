function  [ SYMBOLS , PREVIOUS , NEXT , START , STOPS ] = viterbi_init(Lh)
    SYMBOLS = make_symbols(Lh);
    PREVIOUS = make_previous(SYMBOLS);
    NEXT = make_next(SYMBOLS);
    START = make_start(Lh,SYMBOLS);
    STOPS = make_stops(Lh,SYMBOLS);
end