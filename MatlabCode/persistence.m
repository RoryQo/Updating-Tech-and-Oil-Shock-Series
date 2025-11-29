% persistence.m

function J = persistence(lam,resp,W)

T=length(resp);
init=resp(1);
for t=1:T
    pred(t)=lam^(t-1);
    resp(t)=resp(t)/init;
end

J = (resp-pred)*W*(resp-pred)';
if lam<0
    J=1000000;
end