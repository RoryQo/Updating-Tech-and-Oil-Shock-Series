% olivar function

% takes data in form [x(t) x(t-1) ... x(t-12) y(t) y(t-1) ...] and runs
% VAR.  Returns coefficient estimates, VAR-COV matrix of residuals, and
% residuals.
function [Beta, Omega, eps,SIGMA_beta,CovOmega]= olivar(data,VARlags,K,dur);

[T,V]=size(data);
%K = number of variables in VAR
for j=1:K
    Y(:,j)=data(:,(j-1)*(dur+1)+1);      % time t variables
    X(:,(j-1)*(VARlags)+1:(j-1)*(VARlags)+VARlags)=data(:,(j-1)*(dur+1)+2:(j-1)*(dur+1)+VARlags+1);    % all lags
end
X=[ones(T,1) X];                         % allow for constant
for j=1:K
    eps(:,j)=Y(:,j)-X*( inv(X'*X)*(X'*Y(:,j)) );                        % residuals
    Beta(:,j)=inv(X'*X)*(X'*Y(:,j));                                    % coefficients
end
Omega=cov(eps);                           % VAR-COV matrix of residuals

SIGMA_beta=kron(Omega,inv( X'*X /length(X)))/T;

Dplus=inv(duplication(length(Omega))'*duplication(length(Omega)))*duplication(length(Omega))';
CovOmega=2*Dplus*kron(Omega,Omega)*Dplus'/T;
    
return