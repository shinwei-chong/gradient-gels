% script file to calculate the first differential of the full temperature profile
% (T-x curve), fitted to fourier transform equation

syms f(x)

a0 = 31.03; 
a1 = -0.8526; 
b1 = 0.5079;
a2 = -0.8349;
b2 = 1.145;
a3 = 0.08635;
b3 = -0.3201;
a4 = 0.04816; 
b4 = 0.1166; 
w = 0.002607; 

x_arr = 1:2048; 

f(x) = a0 + a1*cos(x*w) + b1*sin(x*w) + ...
    a2*cos(2*x*w) + b2*sin(2*x*w) + a3*cos(3*x*w) + b3*sin(3*x*w) + ...
    a4*cos(4*x*w) + b4*sin(4*x*w) 

Df = diff(f,x);

T_act = dT_x;
T_pred = f(x_arr);
dTdx = Df(x_arr) .* conv_fac;

x_dist = x_arr ./ 0.62;

figure
% yyaxis left 
plot(x_dist, T_act,'b','DisplayName','Actual');
hold on 
plot(x_dist, T_pred,'r--', 'LineWidth', 1, 'DisplayName', 'Fitted');
ylabel('temperature (degC)')

yyaxis right 
plot(x_dist, dTdx, 'k', 'DisplayName', 'First derivative'); 
ylabel('dT/dx (degC/mm)')

legend 
axis tight 
xlabel('distance in x-direction (µm)')

