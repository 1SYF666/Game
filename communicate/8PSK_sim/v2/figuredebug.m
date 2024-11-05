for k=1:length(s_real)
    up_sps_ds_real(1+sps*(k-1)) = s_real(k);
    up_sps_ds_real(2+sps*(k-1):sps*k) = s_real(k);
    up_sps_ds_imag(1+sps*(k-1)) = s_imge(k);
    up_sps_ds_imag(2+sps*(k-1):sps*k) = s_imge(k);
end
if DEBUG
    figure;scatter(real(s_rcos),imag(s_rcos));title("成型之后星座图");
    figure;subplot(3,1,1);plot(real(s_rcos));title("成型之后信号实部图");
    subplot(3,1,2);plot(imag(s_rcos));title("成型前后信号虚部对比图");hold on;plot(up_sps_ds_imag);
    subplot(3,1,3);plot(abs(fft(s_rcos,floor(fs))));title("成型之后信号频谱图");
    figure;plot(s_rcos);title("成型之后信号矢量图");
end


if DEBUG
    figure;subplot(3,1,1);plot(real(framesignal));title("精同步前输入信号实部图");
    subplot(3,1,2);plot(real(framesignal(pos:sps:end)));title("精同步后补偿前实部图");
    subplot(3,1,3);plot(real(s_synchronization));title("精同步后补偿后实部图");
end

if DEBUG
    figure;subplot(3,1,1);plot(real(rotsignal));title("解旋前信号实部图");
    subplot(3,1,2);plot(real(s_derot));title("解旋后信号实部图");
    subplot(3,1,3);plot(imag(s_derot));title("解旋后信号虚部图");
    figure;scatter(real(s_derot),imag(s_derot));title("解旋后信号星座图");
end