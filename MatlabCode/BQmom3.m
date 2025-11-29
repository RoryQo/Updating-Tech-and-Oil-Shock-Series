% Blanchard-Quah identification of technology shocks
% TRI-variate VAR
function J=BQmom3(Dvec,paramvec);

VARe1=paramvec(1); % var(e1)
VARe2=paramvec(2); % var(e2)
VARe3=paramvec(3); % var(e3)
COVe12=paramvec(4); % cov(e1,e2)
COVe13=paramvec(5); % cov(e1,e3)
COVe23=paramvec(6); % cov(e2,e3)
KSI11=paramvec(7); % KSI11(1)
KSI12=paramvec(8); % KSI12(1)
KSI13=paramvec(9); % KSI13(1)
KSI21=paramvec(10); % KSI21(1) 
KSI22=paramvec(11); % KSI22(1)
KSI23=paramvec(12); % KSI23(1)
KSI31=paramvec(13); % KSI31(1) 
KSI32=paramvec(14); % KSI32(1)
KSI33=paramvec(15); % KSI33(1)


D11=Dvec(1);
D12=Dvec(2);
D13=Dvec(3);
D21=Dvec(4);
D22=Dvec(5);
D23=Dvec(6);
D31=Dvec(7);
D32=Dvec(8);
D33=Dvec(9);

mom1 = VARe1 - (D11^2+D12^2+D13^2);
mom2 = VARe2 - (D21^2+D22^2+D23^2);
mom3 = VARe3 - (D31^2+D32^2+D33^2);
mom4 = COVe12 - (D11*D21+D22*D12+D23*D13);
mom5 = COVe13 - (D11*D31+D32*D12+D33*D13);
mom6 = COVe23 - (D31*D21+D32*D22+D33*D23);

mom7 = KSI11*D12 + KSI12*D22 + KSI13*D32;       % second structural shock has no LR effect on first variable
mom8 = KSI11*D13 + KSI12*D23 + KSI13*D33;       % third structural shock has no LR effect on first variable
mom9 = KSI21*D13 + KSI22*D23 + KSI23*D33;       % third structural shock has no LR effect on second variable


J = 10*sum( [mom1 mom2 mom3 mom4 mom5 mom6 mom7 mom8 mom9 ].^2);
end

% moments
% #1: var(e1)=D11(0)^2+D12(0)^2;
% #2: var(e2)=D21(0)^2+D22(0)^2;
% #3: cov(e1,e2)=D11(0)*D21(0)+D22(0)*D12(0);
% #4: KSI11(1)*D11(0)+KSI12(1)*D21(0)=0; (no long-run response)
