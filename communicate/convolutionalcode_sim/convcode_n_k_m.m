%% ************ convoltion code sim *************%%
%% ****** date: 20241111    author:shenyifu *****%% 
%% 参考CSDN博客：MATLAB （n,k,m）卷积码原理及仿真代码-小小低头哥
clear;clc;
close all;
%% 示例(3,2,[2 2])卷积码
M = [1 1 0 0 1 0 1 1];
%G1{1} = [1 1 1;0 0 1;1 0 0];
%G1{2} = [0 1 0;1 0 1;1 1 1];
G1{1} = [1 0;0 1;1 1];   
G1{2} = [0 1;1 1;1 1];
%{
    从G1来看有一个寄存器+当前输入
%}
C2 = conv_k_encode(M,G1);

%%





