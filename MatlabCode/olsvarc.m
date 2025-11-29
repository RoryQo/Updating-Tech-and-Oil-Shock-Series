% OLSVARC.M
% Lutz Kilian
% University of Michigan
% April 1997
%
% This program estimates a level VAR with intercept in companion format by LS

function [A,CV,SIGMA,U,V,X,cov_slopes,cov_SIGMA]=olsvarc(y,p,q);

[t,q]=size(y);
y=y';

Y=y(:,p:t);
for i=1:p-1
    Y=[Y; y(:,p-i:t-i)];
end;

X=[ones(1,t-p); Y(:,1:t-p)];
Y=Y(:,2:t-p+1);
%size(Y)
A=(Y*X')/(X*X');

U=Y-A*X;
SIGMA=U*U'/(t-p-p*q-1);
CV=A(1:q,1);        %constant
V=A(:,1);
A=A(:,2:q*p+1);     %slopes

% compute the covariance matrix of the estimates for slopes and
% volatility of shocks

cov_slopes=kron(inv(X*X'),SIGMA(1:q,1:q));
cov_slopes=cov_slopes(q+1:end,q+1:end); % drop the terms that correspond to intercepts

Dn=dupmat(q);
Dplus=inv(Dn'*Dn)*Dn';
cov_SIGMA=2*Dplus*kron(SIGMA(1:q,1:q),SIGMA(1:q,1:q))*Dplus'/t;

