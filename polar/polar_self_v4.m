%%%%%%%%%%%%%%%%%       极化码编码和译码仿真程序       %%%%%%%%%%%%%%%%%        
%%%%%%%%%%%%%%         polar_en-de_sim_verion4.m        %%%%%%%%%%%%%%
%%%%%%            date:2024-01-20      author:ShenYifu         %%%%%%%

%%%%%%%%%%%%%% 程序说明
% 不管如何调整N、K以及码率，都发现v3版本的代码运行输出误码率始终为0，这显然与理论相违背，
% 感觉是使用了awgn函数添加高斯白噪声导致的，使用的这个函数导致比预设的信噪比高很多，
% 还有就是解调模块中可能存在提高信号信噪比地方，没有发现
% 目前还没找到具体原因以及解决方法，为了课设的完成，于是有了v4版本的代码
% 此版本较v3版本删除了变频发射模块、采样率变换模块、 以及载波同步模块和码元同步模块代码
% 此版本较v3版本删除了awgn 函数，使用Eb/N0(比特能量与噪声能量之比)去添加高斯白噪声


%% 程序主体
clc;
close all;
clear ;
%% Reliability sequence
Q=[0 1 2 4 8 16 32 3 5 64 9 6 17 10 18 128 12 33 65 20 256 34 24 36 7 129 66 512 11 40 68 130 ...
    19 13 48 14 72 257 21 132 35 258 26 513 80 37 25 22 136 260 264 38 514 96 67 41 144 28 69 42 ...
    516 49 74 272 160 520 288 528 192 544 70 44 131 81 50 73 15 320 133 52 23 134 384 76 137 82 56 27 ...
    97 39 259 84 138 145 261 29 43 98 515 88 140 30 146 71 262 265 161 576 45 100 640 51 148 46 75 266 273 517 104 162 ...
    53 193 152 77 164 768 268 274 518 54 83 57 521 112 135 78 289 194 85 276 522 58 168 139 99 86 60 280 89 290 529 524 ...
    196 141 101 147 176 142 530 321 31 200 90 545 292 322 532 263 149 102 105 304 296 163 92 47 267 385 546 324 208 386 150 153 ...
    165 106 55 328 536 577 548 113 154 79 269 108 578 224 166 519 552 195 270 641 523 275 580 291 59 169 560 114 277 156 87 197 ...
    116 170 61 531 525 642 281 278 526 177 293 388 91 584 769 198 172 120 201 336 62 282 143 103 178 294 93 644 202 592 323 392 ...
    297 770 107 180 151 209 284 648 94 204 298 400 608 352 325 533 155 210 305 547 300 109 184 534 537 115 167 225 326 306 772 157 ...
    656 329 110 117 212 171 776 330 226 549 538 387 308 216 416 271 279 158 337 550 672 118 332 579 540 389 173 121 553 199 784 179 ...
    228 338 312 704 390 174 554 581 393 283 122 448 353 561 203 63 340 394 527 582 556 181 295 285 232 124 205 182 643 562 286 585 ...
    299 354 211 401 185 396 344 586 645 593 535 240 206 95 327 564 800 402 356 307 301 417 213 568 832 588 186 646 404 227 896 594 ...
    418 302 649 771 360 539 111 331 214 309 188 449 217 408 609 596 551 650 229 159 420 310 541 773 610 657 333 119 600 339 218 368 ...
    652 230 391 313 450 542 334 233 555 774 175 123 658 612 341 777 220 314 424 395 673 583 355 287 183 234 125 557 660 616 342 316 ...
    241 778 563 345 452 397 403 207 674 558 785 432 357 187 236 664 624 587 780 705 126 242 565 398 346 456 358 405 303 569 244 595 ...
    189 566 676 361 706 589 215 786 647 348 419 406 464 680 801 362 590 409 570 788 597 572 219 311 708 598 601 651 421 792 802 611 ...
    602 410 231 688 653 248 369 190 364 654 659 335 480 315 221 370 613 422 425 451 614 543 235 412 343 372 775 317 222 426 453 237 ...
    559 833 804 712 834 661 808 779 617 604 433 720 816 836 347 897 243 662 454 318 675 618 898 781 376 428 665 736 567 840 625 238 ...
    359 457 399 787 591 678 434 677 349 245 458 666 620 363 127 191 782 407 436 626 571 465 681 246 707 350 599 668 790 460 249 682 ...
    573 411 803 789 709 365 440 628 689 374 423 466 793 250 371 481 574 413 603 366 468 655 900 805 615 684 710 429 794 252 373 605 ...
    848 690 713 632 482 806 427 904 414 223 663 692 835 619 472 455 796 809 714 721 837 716 864 810 606 912 722 696 377 435 817 319 ...
    621 812 484 430 838 667 488 239 378 459 622 627 437 380 818 461 496 669 679 724 841 629 351 467 438 737 251 462 442 441 469 247 ...
    683 842 738 899 670 783 849 820 728 928 791 367 901 630 685 844 633 711 253 691 824 902 686 740 850 375 444 470 483 415 485 905 ...
    795 473 634 744 852 960 865 693 797 906 715 807 474 636 694 254 717 575 913 798 811 379 697 431 607 489 866 723 486 908 718 813 ...
    476 856 839 725 698 914 752 868 819 814 439 929 490 623 671 739 916 463 843 381 497 930 821 726 961 872 492 631 729 700 443 741 ...
    845 920 382 822 851 730 498 880 742 445 471 635 932 687 903 825 500 846 745 826 732 446 962 936 475 853 867 637 907 487 695 746 ...
    828 753 854 857 504 799 255 964 909 719 477 915 638 748 944 869 491 699 754 858 478 968 383 910 815 976 870 917 727 493 873 701 ...
    931 756 860 499 731 823 922 874 918 502 933 743 760 881 494 702 921 501 876 847 992 447 733 827 934 882 937 963 747 505 855 924 ...
    734 829 965 938 884 506 749 945 966 755 859 940 830 911 871 639 888 479 946 750 969 508 861 757 970 919 875 862 758 948 977 923 ...
    972 761 877 952 495 703 935 978 883 762 503 925 878 735 993 885 939 994 980 926 764 941 967 886 831 947 507 889 984 751 942 996 ...
    971 890 509 949 973 1000 892 950 863 759 1008 510 979 953 763 974 954 879 981 982 927 995 765 956 887 985 997 986 943 891 998 766 ...
    511 988 1001 951 1002 893 975 894 1009 955 1004 1010 957 983 958 987 1012 999 1016 767 989 1003 990 1005 959 1011 1013 895 1006 1014 1017 1018 ...
    991 1020 1007 1015 1019 1021 1022 1023]+1;

%% (N,K)ploar code paremeters

% ********* 测试信息码长不同的情况下的误码率(K/N = 1/2) flag ==1  *********%
NAE_temp = [32 64 128 256 512 1024;
            5 21 53 117 245 501   ;
            36 91 136 276 561 1035];
% ********* 测试信息码长不同的情况下的误码率  *********%

% ********* 测试码率不同的情况下的误码率(N=1024) flag == 2 *********%
Rate_temp =[3/4 9/16 1/2 7/16 1/4 1/8];
A_temp = [757 565 501 437 245 117];
% ********* 测试码率不同的情况下的误码率  *********%

flag = 1;  % 测试标志位

for kkkkk=1:length(NAE_temp)
    if flag == 1
        N = NAE_temp(1,kkkkk);
        A = NAE_temp(2,kkkkk);
        E = NAE_temp(3,kkkkk);
    elseif flag == 2
        N = 1024;
        A = A_temp(kkkkk);
        E = 1035;
    end
    
    crcL = 11;
    crcg = fliplr([1 1 1 0 0 0 1 0 0 0 0 1]); % CRC polynomial
    K = A + crcL;                             % CRC length = crcL
    n = log2(N);
    
    % units
    second = 1;
    KHz = 1e3;
    MHz = 1e6;
    M= 2 ;                                                % QPSK modulation
    
    Rb = K*KHz;                                           % information bit rate
    Cb = N*KHz;                                           % channel bit rate
    Eb = (E+1)* KHz;
    fs = Eb*16;
    simulation_time = 0.001*second;                       % simulation time---1ms
    simulation_length = M * fs * simulation_time;         % QPSK simlation length
    
    EbNodB = 0:0.25:3;
    IE = length(EbNodB);
    for t = 1 : IE
        
        if flag == 1
            Rate = K/N;
        elseif flag == 2
            Rate = Rate_temp(kkkkk);
        end
        EbNo = 10^(EbNodB(t)/10);
        sigma = sqrt(1/(2*Rate*EbNo));
        
        rmax = 3; %max received value
        maxqr = 31; %max integer received value
        nL = 4; %list size
        %% ploar Encode
        Q1 = Q(Q<=N);   %reliability sequence for N
        
        F = Q1(1:N-K);  %Frozen positions: Q1(1:N-K)
        %Message positions: Q1(N-K+1:end)
        
        %Simulate
        
        Nbiterrs = 0; Nblkerrs = 0; Nblocks = 50;
        for blk = 1:Nblocks
            msg = randi([0 1],1,A); % generate random K-bit message, k is equal to Rb*simulation_time
            
            [quot,rem] = gfdeconv([zeros(1,crcL) fliplr(msg)],crcg);
            msgcrc = [msg fliplr([rem zeros(1,crcL-length(rem))])];
            
            u = zeros(1,N);
            u(Q1(N-K+1:end)) = msgcrc; % assign message bits
            m = 1;                  % number of bits combined
            
            for d = n-1:-1:0
                for i = 1:2*m:N
                    a = u(i:i+m-1);                 % first part
                    b = u(i+m:i+2*m-1);             % second part
                    u(i:i+2*m-1) = [mod(a+b,2) b];  % combining
                end
                m = m * 2;
            end
            
            
            %% Ratematching
            
            P=[0 1 2 4 3 5 6 7 ....
                8 16 9 17 10 18 11 19....
                12 20 13 21 14 22 15 23....
                24 25 26 28 27 29 30 31]+1; % 块交织矩阵，参考ts_138212v150200 5.4.1节
            
            % 子块交织
            L_sub = N / 32;
            J = zeros(32,L_sub);
            Y_temp1=zeros(32,L_sub);
            for j = 1 : 32   % 分块
                J(j,:) = u(1+L_sub*(j-1):L_sub*j);
            end
            
            for jj= 1 : 32   % 交织
                Y_temp1(jj,:) = J(P(jj),:);
            end
            Y_temp2 = Y_temp1';
            Y_temp3 = Y_temp2(:);
            y_sub_inter = Y_temp3';
            
            % 比特选择
            
            if E >= N       % reptiton
                y_bit_chosing = [y_sub_inter y_sub_inter(1:E-N)];
            else
                
            end
            
            % 比特交织 45*46/2=1035
            
            % 等直角三角形 边长 45
            edge_length=findNumberOfTerms(E,1,1);
            % step 1:按行写入
            triangle_matrix = zeros(edge_length, edge_length);
            sum_matrix = 0;
            sum_matrix_delay = 0;
            
            for row = 1 : edge_length
                if row == 1
                    matrix_temp(1) = edge_length-row+1;
                    
                    triangle_matrix(row, 1 : matrix_temp(1)) = y_bit_chosing(1:matrix_temp(1));
                    
                    sum_matrix = sum_matrix + matrix_temp(1);
                else
                    matrix_temp(row) = edge_length-row+1;
                    
                    sum_matrix_delay = sum_matrix_delay + matrix_temp(row-1);
                    sum_matrix = sum_matrix + matrix_temp(row);
                    
                    triangle_matrix(row, 1 : matrix_temp(row)) = y_bit_chosing(1+sum_matrix_delay: sum_matrix);
                end
            end
            
            % step 2:按列读出
            
            sum_matrix2 = 0;
            sum_matrix_delay2 = 0;
            for col = 1 : edge_length
                if col == 1
                    matrix_temp2(col) = edge_length-col+1;
                    
                    sum_matrix2 = sum_matrix2 + matrix_temp2(col);
                    
                    y_bit_interleaving(1:sum_matrix2) = triangle_matrix(1:matrix_temp2(col) ,col)';
                else
                    matrix_temp2(col) = edge_length-col+1;
                    
                    sum_matrix_delay2 = sum_matrix_delay2 + matrix_temp2(col-1);
                    sum_matrix2 = sum_matrix2 + matrix_temp2(col);
                    
                    y_bit_interleaving(sum_matrix_delay2+1 : sum_matrix2) = triangle_matrix(1:matrix_temp2(col) ,col)';
                end
            end
            
            %% Modulate
            
            cword = y_bit_interleaving;
            if 0==mod(E,2)
                csword1 = cword ;                     % 1035+1=1036
            else
                csword1 = [cword 0];                     % 1035+1=1036
            end
            
            s_conversion = 1 - 2 * csword1;          % QPSK bit to symbol conversion
            
            kk = 1;
            for k = 1 : length(s_conversion)
                if 0 == mod(k,2)
                    s_imag(kk) = s_conversion(k);
                    kk = kk+1;
                else
                    s_real(kk) = s_conversion(k);
                end
            end
            
            
            %% AWGN Channel
            tra_real = s_real + sigma * randn(1,length( s_real )); % AWGN channel I
            tra_imag = s_imag + sigma * randn(1,length( s_imag )); % AWGN channel I
            tra = tra_real + 1i * tra_imag;
            tra = awgn(tra, EbNodB(t), 'measured');
            %     figure;plot(abs(fft(tra)));
            
%             % 该信噪比加噪方式有问题！
              % 因为运行这段加噪函数，误码率全是0，显然不对。
              % 目前不知道该如何使用AWGN函数如何正确加噪
%             snr(t) =EbNodB(t)+10*log10(2)-10 * log10(1) ;
%             ch3 = awgn(s_real + 1i*s_imag,snr(t),'measured');
%             tra_real = real(ch3);
%             tra_imag = imag(ch3);
%             tra = tra_real + 1i * tra_imag;
            %% Demodulate
            
            temp1 = [tra_real;tra_imag];
            temp2 = temp1(:);
            output = temp2';
            
            %     figure;plot(output);hold on;plot(s_conversion);title("对比");
            
            %% Deratematching
            
            if 0==mod(E,2)
                de_output=output;   % 1036-1 = 1035
            else
                de_output=output(1:end-1);   % 1036-1 = 1035
            end
            
            % 解比特交织模块
            
            % step 1: 按列写入
            % 思想：仍跟上述交织模块一样按行写入，然后对结果取个转置即为按列写入
            de_triangle_matrix = zeros(edge_length, edge_length);
            sum_matrix = 0;
            sum_matrix_delay = 0;
            
            for row = 1 : edge_length
                if row == 1
                    matrix_temp(1) = edge_length-row+1;
                    
                    de_triangle_matrix(row, 1 : matrix_temp(1)) = de_output(1:matrix_temp(1));
                    
                    sum_matrix = sum_matrix + matrix_temp(1);
                else
                    matrix_temp(row) = edge_length-row+1;
                    
                    sum_matrix_delay = sum_matrix_delay + matrix_temp(row-1);
                    sum_matrix = sum_matrix + matrix_temp(row);
                    
                    de_triangle_matrix(row, 1 : matrix_temp(row)) = de_output(1+sum_matrix_delay: sum_matrix);
                end
            end
            
            de_triangle_matrix1 = de_triangle_matrix';
            
            % step 2: 按行读出
            sum_matrix2 = 0;
            sum_matrix_delay2 = 0;
            for row = 1 : edge_length
                if row == 1
                    matrix_temp2(row) = edge_length-row+1;
                    
                    sum_matrix2 = sum_matrix2 + matrix_temp2(row);
                    
                    de_y_bit_interleaving(1:sum_matrix2) = de_triangle_matrix1(row, 1:matrix_temp2(row) )';
                else
                    matrix_temp2(row) = edge_length-row+1;
                    
                    sum_matrix_delay2 = sum_matrix_delay2 + matrix_temp2(row-1);
                    sum_matrix2 = sum_matrix2 + matrix_temp2(row);
                    
                    de_y_bit_interleaving(sum_matrix_delay2+1 : sum_matrix2) = de_triangle_matrix1(row , 1:matrix_temp2(row))';
                end
            end
            
            
            % 解比特选择
            
            if E >= N       % reptiton
                de_y_bit_chosing = de_y_bit_interleaving(1:N);
            else
            end
            
            % 解子块交织
            de_J = zeros(32,L_sub);
            de_Y_temp1=zeros(32,L_sub);
            for j = 1 : 32   % 分块
                de_J(j,:) = de_y_bit_chosing(1+L_sub*(j-1):L_sub*j);
            end
            
            for jj= 1 : 32   % 交织
                de_Y_temp1(P(jj),:) = de_J(jj,:);
            end
            
            de_Y_temp2 = de_Y_temp1';
            de_Y_temp3 = de_Y_temp2(:);
            de_y_sub_inter = de_Y_temp3';
            
            %% Ploar Decode-SCL decoder
            r=de_y_sub_inter;
            satx = @(x,th) min(max(x,-th),th); %saturate FP value
            f = @(a,b) (1-2*(a<0)).*(1-2*(b<0)).*min(abs(a),abs(b)); %minsum
            g = @(a,b,c) b+(1-2*c).*a; %g function
            
            %quantization
            r = satx(r,rmax);
            rq = round(r/rmax*maxqr);
            
            LLR = zeros(nL,n+1,N); %beliefs in nL decoders
            ucap = zeros(nL,n+1,N); %decisions in nL decoders
            PML = Inf*ones(nL,1); %Path metrics
            PML(1) = 0;
            ns = zeros(1,2*N-1); %node state vector
            
            LLR(:,1,:) = repmat(rq,nL,1,1); %belief of root
            DML = zeros(nL,N);
            PMLL = zeros(nL,N);
            
            
            node = 0; depth = 0; %start at root
            done = 0; %decoder has finished or not
            
            while (done == 0) %traverse till all bits are decoded
                %leaf or not
                if depth == n
                    DM = squeeze(LLR(:,n+1,node+1)); %decision metrics
                    DML(:,node+1) = DM;
                    PMLL(:,node+1) = PML;
                    if any(F==(node+1)) %is node frozen
                        ucap(:,n+1,node+1) = 0; %set all decisions to 0
                        PML = PML + abs(DM).*(DM < 0); %if DM is negative, add |DM|
                    else
                        dec = DM < 0; %decisions as per DM
                        PM2 = [PML; PML+abs(DM)];
                        [PML, pos] = mink(PM2,nL); %In PM2(:), first nL are as per DM
                        %next nL are opposite of DM
                        pos1 = pos > nL; %surviving with opposite of DM: 1, if pos is above nL
                        pos(pos1) = pos(pos1) - nL; %adjust index
                        dec = dec(pos); %decision of survivors
                        dec(pos1) = 1 - dec(pos1); %flip for opposite of DM
                        LLR = LLR(pos,:,:); %rearrange the decoder states
                        ucap = ucap(pos,:,:);
                        ucap(:,n+1,node+1) = dec;
                    end
                    if node == (N-1)
                        done = 1;
                    else
                        node = floor(node/2); depth = depth - 1;
                    end
                else
                    %nonleaf
                    npos = (2^depth-1) + node + 1; %position of node in node state vector
                    if ns(npos) == 0 %step L and go to left child
                        %disp('L')
                        %disp([node depth])
                        temp = 2^(n-depth);
                        Ln = squeeze(LLR(:,depth+1,temp*node+1:temp*(node+1))); %incoming beliefs
                        a = Ln(:,1:temp/2); b = Ln(:,temp/2+1:end); %split beliefs into 2
                        node = node *2; depth = depth + 1; %next node: left child
                        temp = temp / 2; %incoming belief length for left child
                        LLR(:,depth+1,temp*node+1:temp*(node+1)) = f(a,b); %minsum and storage
                        ns(npos) = 1;
                    else
                        if ns(npos) == 1 %step R and go to right child
                            %disp('R')
                            %disp([node depth])
                            temp = 2^(n-depth);
                            Ln = squeeze(LLR(:,depth+1,temp*node+1:temp*(node+1))); %incoming beliefs
                            a = Ln(:,1:temp/2); b = Ln(:,temp/2+1:end); %split beliefs into 2
                            lnode = 2*node; ldepth = depth + 1; %left child
                            ltemp = temp/2;
                            ucapn = squeeze(ucap(:,ldepth+1,ltemp*lnode+1:ltemp*(lnode+1))); %incoming decisions from left child
                            node = node *2 + 1; depth = depth + 1; %next node: right child
                            temp = temp / 2; %incoming belief length for right child
                            LLR(:,depth+1,temp*node+1:temp*(node+1)) = g(a,b,ucapn); %g and storage
                            ns(npos) = 2;
                        else %step U and go to parent
                            temp = 2^(n-depth);
                            lnode = 2*node; rnode = 2*node + 1; cdepth = depth + 1; %left and right child
                            ctemp = temp/2;
                            ucapl = squeeze(ucap(:,cdepth+1,ctemp*lnode+1:ctemp*(lnode+1))); %incoming decisions from left child
                            ucapr = squeeze(ucap(:,cdepth+1,ctemp*rnode+1:ctemp*(rnode+1))); %incoming decisions from right child
                            ucap(:,depth+1,temp*node+1:temp*(node+1)) = [mod(ucapl+ucapr,2) ucapr]; %combine
                            node = floor(node/2); depth = depth - 1;
                        end
                    end
                end
            end
            
            % check CRC
            
            msg_capl = squeeze(ucap(:,n+1,Q1(N-K+1:end))); %get candidate messages
            
            cout = 1; %candidate codeword to be outputted, initially set to best PM
            
            for c1 = 1:nL
                [q1,r1] = gfdeconv(fliplr(msg_capl(c1,:)),crcg);
                if isequal(r1,0) %check if CRC passes
                    cout = c1;
                    break
                end
            end
            msg_cap = msg_capl(cout,1:A);
            
            %     figure; plot(msg_cap*1.2);hold on; plot(msg);title("decode");
            
            %Counting errors
            
            Nerrs = sum(msg ~= msg_cap);
            
            if Nerrs > 0
                Nbiterrs = Nbiterrs + Nerrs;    % 总误比特数
                Nblkerrs = Nblkerrs + 1;        % 总误块数
            end
            
        end % for blk=1:Nblocks
        Nbiterrs1(kkkkk,t) = Nbiterrs;
        Nblkerrs1(kkkkk,t) = Nblkerrs;
        BER_sim(kkkkk,t) = Nbiterrs/K/Nblocks;
        FER_sim(kkkkk,t) = Nblkerrs/Nblocks;
        disp([EbNodB(t)    FER_sim(kkkkk,t)     BER_sim(kkkkk,t)     Nblkerrs1(kkkkk,t)    Nbiterrs1(kkkkk,t)    Nblocks]);
        
    end% for t=1:IE
    
end %for kkkkk = 1:length(NAE_temp)
%% result 

% save BER_sim.mat BER_sim;
% save FER_sim.mat FER_sim;

figure;
for ttt=1:length(NAE_temp)
    
    semilogy(EbNodB,BER_sim(ttt,:),'-o');grid on;
%     plot(EbNodB,BER_sim,'-ko');grid on;
    hold on;
end
%  5 21 53 117 245 501  
legend('A=5','A=21','A=53','A=117','A=245','A=501');
title('信息码长固定前提下的BLER performance')
xlabel('Eb/No');
ylabel('BER')

figure;
for ttt=1:length(NAE_temp)
    
%     semilogy(EbNodB,BER_sim(ttt,:),'-*');grid on;
    plot(EbNodB,BER_sim(ttt,:),'-o');grid on;
    hold on;
end
%  5 21 53 117 245 501  
legend('A=5','A=21','A=53','A=117','A=245','A=501');
title('信息码长固定前提下的BLER performance')
xlabel('Eb/No');
ylabel('BER')


