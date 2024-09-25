function [Y,Rhh] = mafi(r,L,T_SEQ,OSR)
    DEBUG = 0;
    
    T16 = conj(T_SEQ(6:21));

    GUARD = 10;

    center_r = round(length(r)/2);
    start_sub = center_r - (GUARD+8) * OSR;
    end_sub = center_r + (GUARD+8) * OSR;

    r_sub = r(start_sub:end_sub);

    if DEBUG
        count = 1 : length(r);
        figure;plot(count,real(r));
        plug = start_sub:end_sub;
        hold on;
        plot(plug,real(r_sub),'r');
        hold off;
        title("Real part of r and r_sub (red)");
    end

    chan_est = zeros(1,length(r_sub)-OSR*16);

    for n = 1:length(chan_est)
        chan_est(n) = r_sub(n:OSR:n+15*OSR)*T16.';
    end

    if DEBUG
        figure;plot(abs(chan_est));title('The absoulte value of the correlation');
    end

    chan_est = chan_est./16;

    WL = OSR*(L+1);

    search = abs(chan_est).^2;

    for n = 1:(length(search)-(WL-1))
        power_est(n) = sum( search(n : n+WL-1 ));
    end

    if DEBUG
        figure;plot(power_est);title("The window powers");
    end

    [peak, sync_w] = max(power_est);
    h_est = chan_est(sync_w:sync_w+WL-1);

    [peak, sync_h] = max(abs(h_est));
    sync_T16 = sync_w + sync_h -1;

    if DEBUG
        figure;plot(abs(h_est)); title('Absolute value of extracted impluse response');
    end

    burst_start = ( start_sub + sync_T16 - 1 ) - ( OSR*66 + 1 ) + 1;

    burst_start = burst_start - 2*OSR + 1;

    R_temp = xcorr(h_est);

    pos = (length(R_temp)+1)/2;

    hhh = R_temp(pos : OSR : pos + L*OSR);

    m = length(h_est) - 1;

    GUARDmf = (GUARD+1) * OSR;
    
    r_extended = [zeros(1,GUARDmf) r zeros(1,m) zeros(1,GUARDmf)];

    for n = 1 : 148
        aa = GUARDmf + burst_start + (n-1)*OSR;
        bb = GUARDmf + burst_start + (n-1)*OSR + m;
        Y(n) = r_extended(aa:bb)*h_est';
    end

end