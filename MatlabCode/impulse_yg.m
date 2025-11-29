% impulse.m

% this file takes VAR coefficients, returns response of variable N to
% Choleski identified shock to variable FFRpos.  Assume Beta includes
% constant coefficient.  

function z = impulse(Y,X,periods,shockpos);

[T,K]=size(X);
beta=inv(X'*X)*(X'*Y);


Xa=zeros(1,length(beta)-1); 
Xa(shockpos-1)=1;   % drop constant
z(1)=Xa*beta(2:length(beta));

for j=2:periods
    Xa(j,1)=z(j-1,1);
    for i=2:length(beta)-1
        Xa(j,i)=Xa(j-1,i-1);
    end
    Xa(j,shockpos-1)=0;
    z(j,1)=Xa(j,:)*beta(2:length(beta));
end

z=z';

return

