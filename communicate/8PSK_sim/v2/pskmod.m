%% 8PSK调制
function [s,si,base_symbol] = pskmod(base_bit)
DEBUG = 0;
len = length(base_bit);
base_symbol = [];
k = 1;
for i = 1:3:len
    % 将每三个二进制元素转换为字符串
    binary_str = strcat(num2str(base_bit(i)), num2str(base_bit(i+1)), num2str(base_bit(i+2)));
    % 直接进行映射
    switch binary_str
        case '111'
            base_symbol(k) = 0;
        case '011'
            base_symbol(k) = 1;
        case '010'
            base_symbol(k) = 2;
        case '000'
            base_symbol(k) = 3;
        case '001'
            base_symbol(k) = 4;
        case '101'
            base_symbol(k) = 5;
        case '100'
            base_symbol(k) = 6;
        case '110'
            base_symbol(k) = 7;
        otherwise
            warning('未找到映射对应关系：%s', binary_str);
    end
    k=k+1;
end

% IQ调相
for k = 1: length(base_symbol)
    si(k) = exp(j*pi/4*base_symbol(k));
end

if DEBUG
    figure;scatter(real(si),imag(si));title("IQ调相星座图");
    figure;subplot(3,1,1);plot(real(si));title("IQ调相实部图");
    subplot(3,1,2);plot(imag(si));title("IQ调相虚部图");
    subplot(3,1,3);plot(fftshift( abs(fft(si,65536)) ));title("IQ调相信号频谱图");
    figure;plot(si);title("IQ调相信号矢量图");
end

% 旋转
for k = 1: length(si)
    s(k) = si(k).*exp(j*3*pi/8*k);
end

if DEBUG
    figure;scatter(real(s),imag(s));title("旋转之后星座图");
    figure;subplot(3,1,1);plot(real(s));title("旋转之后信号实部图");
    subplot(3,1,2);plot(imag(s));title("旋转之后信号虚部图");
    subplot(3,1,3);plot(fftshift( abs(fft(s,65536)) ));title("旋转之后信号频谱图");
    figure;plot(s);title("旋转之后信号矢量图");
end

if DEBUG
    phi = atan2(imag(s), real(s));  % 计算信号的相位
    phi_unwrapped = unwrap(phi);  % 解包相位
    figure;plot(phi_unwrapped);  % 绘制解包后的相位
    title('Unwrapped Phase of 8PSK Signal');
end

end