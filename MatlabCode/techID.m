% techID.m

% This file provides technology shocks from 3-variable VAR, using LR
% identification conditions (1 st variable unaffected by other 2 shocks,
% 2nd variable unaffected by 3rd shock).  p is lags, K is number of
% variables (MUST BE 3!!!).  Level index is for whether impulse response is
% in accumulated responses (1 for yes, 2 for not).

function shocks= techID(dataX,p,K,I,M,levelindex,periods)

[N,K]=size(dataX);

%estimate VAR on the original data
[Ainit,CVinit,SIGMAinit,Uinit,V]=olsvarc(dataX,p,K);
%store residuals and the covaraince matrix
UUinit=Uinit(1:K,:);    % reduced-form residuals
CV1init=V;              % intercepts
% compure the MA represenation
VDhor=500;
irfMAx=irfMA(Ainit,p,K,VDhor);

% initial values
initDvec=[.55 .36 -.45 -1.03 2.5 .09 -.30 -.1 -.31];    % starting values from Eviews for tech shock
KSI11=sum(sum(sum(irfMAx(1,1,:))));
KSI12=sum(sum(sum(irfMAx(1,2,:))));
KSI13=sum(sum(sum(irfMAx(1,3,:))));
KSI21=sum(sum(sum(irfMAx(2,1,:))));
KSI22=sum(sum(sum(irfMAx(2,2,:))));
KSI23=sum(sum(sum(irfMAx(2,3,:))));
KSI31=sum(sum(sum(irfMAx(3,1,:))));
KSI32=sum(sum(sum(irfMAx(3,2,:))));
KSI33=sum(sum(sum(irfMAx(3,3,:))));
KI31=irfMAx(3,1,1);
KI32=irfMAx(3,2,1);
KI33=irfMAx(3,3,1);

paramvec=[SIGMAinit(1,1) SIGMAinit(2,2) SIGMAinit(3,3) SIGMAinit(2,1) SIGMAinit(3,1) SIGMAinit(3,2) KSI11 KSI12 KSI13 KSI21 KSI22 KSI23 KSI31 KSI32 KSI33];

options=optimset('display','off','MaxFunEvals',10000,'MaxIter',10000,'TolX',1e-10,'TolFun',1e-10);
[estDvec, J]=fminsearch(@BQmom3,initDvec,options,paramvec);

% infer the structural shocks
matD=[estDvec(1) estDvec(2) estDvec(3); estDvec(4) estDvec(5) estDvec(6); estDvec(7) estDvec(8) estDvec(9)];
inv_matD=inv(matD);

shocks=inv_matD*UUinit;
shocks=shocks(1,:)';
return