% 输入：
%       rxip 接收信号
%       CIR自适应滤波器系数
% 输出：
%       index_n 判决输出符号
%       rx_data 判决输出比特
function [rx_data,index_n] = dfeself(CIR, rxiq)
j = sqrt(-1);
rx_data = [];
index_n = zeros(1, length(rxiq) + 3);
N = length(CIR);
w1tmp = conj(CIR(1))*exp(j*pi/8); 
for n = 4 : length(rxiq)-3   % 对接收符号进行自适应滤波，消除符号间干扰。
    E=0;F=0;G=0;
    ex=zeros(1,6);
    y_out=zeros(1,3);
    ex = [exp(j*index_n(n+2)*pi/4),exp(j*index_n(n+1)*pi/4),exp(j*index_n(n)*pi/4),...
          exp(j*index_n(n-1)*pi/4),exp(j*index_n(n-2)*pi/4),exp(j*index_n(n-3)*pi/4)];

    r = CIR(2:N)*ex.';
    tmp = rxiq(n) - r;
    tem = tmp*w1tmp;
    Itmp = real(tem);
    Qtmp = imag(tem);
    E=sign(Itmp);
    F=sign(Qtmp);
    labs = abs(Itmp);
    Qabs = abs(Qtmp);

    if labs<Qabs
        G = 0;
    else
        G = 1;
    end
    
    if(E==1 && F==1 && G==1)    % 进行符号判决。
        index_n(n+3)=0;
        y_out=[1,1,1];
    elseif(E==1 && F==1 && G==0)
        index_n(n+3)=1;
        y_out=[0,1,1];
    elseif(E==-1 && F==1 && G==0)
        index_n(n+3)=2;
        y_out=[0,1,0];
    elseif(E==-1 && F==1 && G==1)
        index_n(n+3)=3;
        y_out=[0,0,0];
    elseif(E==-1 && F==-1 & G==1)
        index_n(n+3)=4;
        y_out=[0,0,1];
    elseif(E==-1 && F==-1 && G==0)
        index_n(n+3)=5;
        y_out=[1,0,1];
    elseif(E==1 && F==-1 && G==0)
        index_n(n+3)=6;
        y_out=[1,0,0];
    else
        index_n(n+3)=7;
        y_out=[1,1,0];
    end

    rx_data = [rx_data y_out];

end

