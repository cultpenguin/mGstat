%% gamma coefficients
function w=gamma_coefficients(f0,gamma,f);
w = 1./(gamma*sqrt(2*pi))*exp(-(f-f0).^2/(2*(gamma.^2)));

