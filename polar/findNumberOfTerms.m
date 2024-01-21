function n = findNumberOfTerms(S, a, d)
    % 输入参数：S 为等差数列的和，a 为首项，d 为公差
    % 输出参数：n 为等差数列的项数

    % 计算二次方程的系数
    A = 1;
    B = (2*a - 1)*d;
    C = -2*S;

    % 使用一元二次方程的求根公式
    discriminant = sqrt(B^2 - 4*A*C);
    n1 = (-B + discriminant) / (2*A);
    n2 = (-B - discriminant) / (2*A);

    % 选择正整数解
    n = max(n1, n2);

    % 四舍五入取整
    n = round(n);
end
