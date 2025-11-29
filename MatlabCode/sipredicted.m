% sipredicted.m

% this file takes estimate of information ("rho"), impulse response of
% inflation ("pi") and delivers predicted response of disagreement from SI
% model to 1 one unit shock.

function     x = sipredicted(rho,pi,T)

for j=1:T
    x(j)=(rho^j)*(1-rho^j)*pi(j)^2;
end
x=x.^0.5;        % response of standard deviation


