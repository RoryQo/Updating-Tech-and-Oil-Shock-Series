% OLSVARC.M
% Lutz Kilian
% University of Michigan
% April 1997
%
% This program estimates a level VAR with intercept in companion format by LS

function [A,cov_slopes]=olsvar_lp2(y,techshocks,p,q,lead_h);

[t,q]=size(y);
y=y';

Y=y(:,p:t-lead_h);
for i=1:p-1
    Y=[Y; y(:,p-i:t-i-lead_h)];
end;

X=[ones(1,t-p-lead_h); techshocks(t-(t-p-lead_h)+1-lead_h:t-lead_h,2)'; Y(:,1:t-p-lead_h)];
Y1=y(end,t-length(X(1,:))+1:t);

A=(Y1*X')/(X*X');

ivopt.lags=1; ivopt.linear=1;
out = iv(A,ivopt,Y1',X',X');

A=out.beta;
A=A(2);
cov_slopes=out.se;
cov_slopes=(cov_slopes(2));

end
