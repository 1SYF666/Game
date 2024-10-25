%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ܣ���1bit���������ͬ������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [head,corM,flag] = EPDT_coarseSync_v2(dataIn,sync,OSR)
    head = 0;
    flag = 0;
    dif1 = imag(dataIn(1:end-OSR).*conj(dataIn(OSR+1:end)));  % ��datain�е�ÿ�����������18Ԫ�ؽ��й�����˲�ȡ�鲿
    %dif2 = real(dataIn(1:end-18).*conj(dataIn(19:end)));  % �� 
    tmp = 0;
    pos = 0;
    syncPos = [];
    corM = [];
    ii = 0;
    while ii<(length(dif1)-length(sync)*OSR) 
    % while ii<(length(dif1)-248*16) %248*16 ��ֹԽ�� 248*16  1bit������ 64672
        ii = ii+1;
        % oneSync = sign(dif1(ii:OSR:ii+16*OSR-1));
        oneSync = sign(dif1(ii:OSR:ii+length(sync)*OSR-1));
        cor = oneSync*sync';  
        if abs(cor) >= length( sync(sync~=0) ) - 11
            flag = 1;
            tmp = cor;
            pos = ii;
        end
        if flag>0 && abs(cor)>abs(tmp) && ii-pos<=OSR
            tmp = cor;
            pos = ii;
        end                                    
        if ii-pos>OSR && flag>0
            syncPos = [syncPos pos];
            corM = [corM tmp];
            flag = 0;
            cor = 0;
            tmp = 0;
            % ii = ii+(750-25-3)*OSR;
            ii = ii+(400)*OSR;       % ����sync����֡�ṹλ���޸�
        end

    end  
    head = syncPos;
end
% function [head,corM,flag] = EPDT_coarseSync_400(dataIn,sync,OSR)
%     head = 0;
%     flag = 0;
%     dif1 = imag(dataIn(1:end-OSR).*conj(dataIn(OSR+1:end)));  % ��datain�е�ÿ�����������18Ԫ�ؽ��й�����˲�ȡ�鲿
%     %dif2 = real(dataIn(1:end-18).*conj(dataIn(19:end)));  % �� 
%     tmp = 0;
%     pos = 0;
%     syncPos = [];
%     corM = [];
%     ii = 0;
%     while ii<(length(dif1)-100*OSR) %248*16 ��ֹԽ�� 248*16  1bit������ 64672
%     % while ii<(length(dif1)-248*16) %248*16 ��ֹԽ�� 248*16  1bit������ 64672
%         ii = ii+1;
%         oneSync = sign(dif1(ii:OSR:ii+16*OSR-1));  %��ȡ����Ϊ16������ÿ��OSR������ȡһ����Ȼ������źŴ���
%         cor(ii) = oneSync*sync';  
%     end  
%     figure;plot(abs(cor));
% end

