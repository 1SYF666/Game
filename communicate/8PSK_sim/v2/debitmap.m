function [deoutbit] = debitmap(y)
deoutbit = zeros(1,3*length(y));

for i = 1 : length(y)
    if y(i) == 0
        deoutbit( 1+(i-1)*3:i*3 ) = [1 1 1];
    elseif y(i) == 1
        deoutbit( 1+(i-1)*3:i*3 ) = [0 1 1];
    elseif y(i) == 2
        deoutbit( 1+(i-1)*3:i*3 ) = [0 1 0];
    elseif y(i) == 3
        deoutbit( 1+(i-1)*3:i*3 ) = [0 0 0];
    elseif y(i) == 4
        deoutbit( 1+(i-1)*3:i*3 ) = [0 0 1];
    elseif y(i) == 5
        deoutbit( 1+(i-1)*3:i*3 ) = [1 0 1];
    elseif y(i) == 6
        deoutbit( 1+(i-1)*3:i*3 ) = [1 0 0];
    elseif y(i) == 7
        deoutbit( 1+(i-1)*3:i*3 ) = [1 1 0];
    end
end
end