function [ SYMBOLS ] = make_symbols(Lh)
j = sqrt(-1);
% MAKE_SYMBOLS:
%   This function returns a table containing the mapping
%   from state numbers to symbols. The table is contained
%   in a matrix, and the layout is:
%
%   |  Symbols for state 1  |
%   |  Symbols for state 2  |
%   |  Symbols for state M  |
%
%   Where M is the total number of states, and can be calculated
%   as: 2^(Lh-1), Lh is the length of the estimated impulse
%   response, as found in the mf-routine. In the symbols for
%   a statenumber the order is as:
%
%   I(a-1) I(a-2) I(a-3) .... I(a-Lh)
%
%   Each of the symbols belong to {1, -1 , j, -j}.
%
% SYNTAX:
%   [SYMBOLS] = make_symbols(Lh)
%
% INPUT:
%   Lh:         Length of the estimated impulse response.
%
% OUTPUT:       SYMBOLS: The table of symbols corresponding to the state-numbers, as described above.
%
% SUB_FUNC:     None
% WARNINGS:     None
% TEST(S):      Compared result against expected values.
%
% AUTHOR:       Jan R. Mikkelsen / Arne Norre Ekstram
% EMAIL:        hmik@kom.auc.dk / anek@kom.auc.dk
%
% Std: make_symbols.v_1.c 1997/09/22 11:38:57 aneks Exp $
%
% THIS CODE CANNOT HANDLE Lh=1 or Lh>4.

if Lh==1
    error('GMSK-in-Error: Lh is constrained to be in the interval [1:4].');
elseif Lh > 4
    error('GMSK-in-Error: Lh is constrained to be in the interval [1:4].');
end

% make initiating symbols
SYMBOLS = [ 1, j, -1, -j];

for i = 1 : Lh - 1
    SYMBOLS = [ [SYMBOLS(:,1)*j , SYMBOLS] ; [ SYMBOLS(:,1)*(-j) , SYMBOLS ] ];
end

% ALGORITHM.
%
if isreal(SYMBOLS(1,1))
    SYMBOLS = flipud(SYMBOLS);
end

end