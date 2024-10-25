% GSM_SET: This script initializes the values needed by the 
% GSMsim package, and must run before the package to work.
%
% SYNTAX: gsm_set
%
% INPUT: None
% OUTPUT: Configuration variables created in memory, these are:
%         Tb    ( = 3.692e-6)
%         BT    ( = 0.3)
%         OSR   ( = 4)
%         SEED  ( = 931316785)
%         INIT_L( = 260)
%
% SUB_FUN: None
%
% WARNINGS: Values can be cleared by other functions, and thus this script 
%           should be rerun in each simulation.
%           The random number generator is set to a standard seed value 
%           within this script. This causes the random numbers generated 
%           by matlab to follow a standard pattern.
%
% AUTHOR:  Arne Norre Ekstrøm / Jan H. Mikkelsen
% EMAIL:   aneks@kom.auc.dk / hmi@kom.auc.dk
%
% $Id: gsm_set.m,v 1.11 1997/09/22 11:38:19 aneks Exp $
%
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%
% GSM 05.05 PARAMETERS
%
Tb = 3.692e-6;
BT = 0.3;
OSR = 4;
%
% INITIALIZE THE RANDOM NUMBER GENERATOR.
% BY USING THE SAME SEED VALUE IN EVERY SIMULATION, WE GET THE SAME 
% SIMULATION DATA, AND THUS SIMULATION RESULTS MAY BE REPRODUCED.
%
SEED = 931316785;
rand('seed',SEED);
%
% THE NUMBER OF BITS GENERATED BY THE DATA GENERATOR. (data_gen)
%
INIT_L = 114;
%
% SETUP THE TRAINING SEQUENCE USED FOR BUILDING BURSTS
TRAINING = [0 0 1 0 0 1 0 1 1 1 0 0 0 0 1 0 0 0 1 0 0 1 0 1 1 1];
%
% CONSTRUCT THE MSK MAPPED TRAINING SEQUENCE USING TRAINING.
T_SEQ = T_SEQ_gen(TRAINING);

%% 
T_SEQC = T_SEQ(6:end-5);
T_SEQE = [zeros(1,5) T_SEQC zeros(1,5)];
figure;stem(abs(xcorr(T_SEQE,T_SEQ)));  title("cross correlation");
[r,lag] = xcorr(T_SEQE,T_SEQ);
figure;stem(lag,abs(r));  title("cross correlation shift");