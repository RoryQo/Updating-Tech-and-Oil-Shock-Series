% this program computes impulse reponses from the matrix

function IRF=irfMA(Ainit,p,K,VDhor);
% Inputs:
%     p       =   number of lagrs int he VAR
%     K       =   number of variables in the VAR
%     Ainit   =   slopes of the var grouped by lag
%     VDhor   =   horizons for MA represenation
% Output
%     IRF     =   impulse response functions grouped by variable
%                 column i corresponds to IRF of variables to chock in the variable i
               

%store PI-matrices from VAR in the convenient matrix
Ps=zeros(K,K,p);
for i=1:p
   Ps(:,:,i)=Ainit(1:K,(i-1)*K+1:i*K);
end

% Moving average for vector process (Lutkepohl)

PsMA=zeros(K,K,VDhor+1);
PsMA(:,:,1)=eye(K);
for i=1:VDhor+1
   for j=2:min(i,p+1)
       PsMA(:,:,i)=PsMA(:,:,i)+PsMA(:,:,i-j+1)*Ps(:,:,j-1);
   end
end

IRF=PsMA;
return