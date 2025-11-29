% SPFcombined.m

% This file plots results for SPF.
clear all
close all
randn('seed',1234567)
rand('seed',123456711)

%%%  OPTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
boots=2000;         % number of bootstraps for standard errors
lags=0;             % set to -1 for AIC, 0 for BIC, 1 or above for fixed lags
startmin=1977;      % minimum startdate to use when not using common sample
lags_default = 8;   % number of lags if do not use info criteria (maximum possible lags with AIC/BIC)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% DATA LOAD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ordering:
% 02: Technology        :	Gali
% 03: News              :	Sims
% 04: Oil               :	Hamilton
% 05: Unidentified      :	Residuals

load step001_all_shocks
time=shocks_all(:,1);
Shocks=[shocks_all(:,1) shocks_all(:,2) shocks_all(:,3)  shocks_all(:,4) shocks_all(:,5)];

dur=4;
data_SPF             % load SPF forecast errors (SPFfe) and disagreement (SPFdisp).
dpgdpA=SPFfe;       % annual forecast errors
dpgdpB=SPFpi;       % annual inflation
dpgdpC=exp(SPFdisp);% disagreement (standard deviation)
dpgdpD=SPFf;        % annual inflation forecast

Shocks1=abs(Shocks);% absolute value of shocks

%%%  ESTIMATION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
subaxis(4,4,1,'SpacingVert',0.04,'SpacingHoriz',0.04);
rho_boot=zeros(boots,cols(Shocks)-2); % store results for estimate persistence
for i=2:cols(Shocks)
    if lags<1
        Lags=lags_default;
    else
        Lags_shocks=lags_default; % number of lags for the shock series
        Lags_endo  =lags_default;
        Lags       =lags_default;
    end
    
    %%% SET UP DATA FORMATTING GIVEN PERIOD AND SHOCK
    X=[dpgdpA Shocks(:,i)];
    ind=0;
    row=1;
    while ind<1
        temp=sum(X(row,:));
        if isnan(temp)
            row=row+1;
        else
            ind=1;  start=row;  % identify startdate
        end
    end
    ind=0; row=length(dpgdpA);
    while ind<1
        temp=sum(X(row,:));
        if isnan(temp)
            row=row-1;
        else
            ind=1;  enddate=row;  % identify enddate
        end
    end
    
    startdatemin=find(time==startmin);
    start=max(start,startdatemin);
    disp(['start date = ' num2str(1951+round(start/dur))])
    
    dpgdpA1=dpgdpA(start:enddate);
    dpgdpA1=makelags(dpgdpA1,Lags);
    dpgdpB1=dpgdpB(start:enddate);
    dpgdpB1=makelags(dpgdpB1,Lags);
    dpgdpC1=dpgdpC(start:enddate);
    dpgdpC1=makelags(dpgdpC1,Lags);
    dpgdpD1=dpgdpD(start:enddate);
    dpgdpD1=makelags(dpgdpD1,Lags);
    
    sh=Shocks(start:enddate,i);
    sh=makelags(sh,Lags);
    sh1=Shocks1(start:enddate,i);
    sh1=makelags(sh1,Lags);
    
    
    %%% Information criterion lag selection
    if lags<1
        ivopt.lags=4; ivopt.linear=1;
        for ll=1:Lags
            for ll2=0:Lags
                b0=zeros(1,2*ll+1);
                outA = iv(b0,ivopt,dpgdpA1(:,1),...
                    [ones(length(dpgdpA1),1) dpgdpA1(:,2:ll+1) sh(:,1:ll2+1)],...
                    [ones(length(dpgdpA1),1) dpgdpA1(:,2:ll+1) sh(:,1:ll2+1)]);
                outB = iv(b0,ivopt,dpgdpB1(:,1),...
                    [ones(length(dpgdpB1),1) dpgdpB1(:,2:ll+1) sh(:,1:ll2+1)],...
                    [ones(length(dpgdpB1),1) dpgdpB1(:,2:ll+1) sh(:,1:ll2+1)]);
                outC = iv(b0,ivopt,dpgdpC1(:,1),...
                    [ones(length(dpgdpC1),1) dpgdpC1(:,2:ll+1) sh1(:,1:ll2+1)],...
                    [ones(length(dpgdpC1),1) dpgdpC1(:,2:ll+1) sh1(:,1:ll2+1)]);
                outD = iv(b0,ivopt,dpgdpD1(:,1),...
                    [ones(length(dpgdpD1),1) dpgdpD1(:,2:ll+1) sh(:,1:ll2+1)],...
                    [ones(length(dpgdpD1),1) dpgdpD1(:,2:ll+1) sh(:,1:ll2+1)]);
                outF = iv(b0,ivopt,dpgdpA1(:,1),...
                    [ones(length(dpgdpA1),1) dpgdpA1(:,2:ll+1) sh1(:,1:ll2+1)],...
                    [ones(length(dpgdpA1),1) dpgdpA1(:,2:ll+1) sh1(:,1:ll2+1)]);
                
                bicA(ll,ll2+1)=outA.bic;
                aicA(ll,ll2+1)=outA.aic;
                bicB(ll,ll2+1)=outB.bic;
                aicB(ll,ll2+1)=outB.aic;
                bicC(ll,ll2+1)=outC.bic;
                aicC(ll,ll2+1)=outC.aic;
                bicD(ll,ll2+1)=outD.bic;
                aicD(ll,ll2+1)=outD.aic;
                bicF(ll,ll2+1)=outF.bic;
                aicF(ll,ll2+1)=outF.aic;
            end
        end
        if lags==0
            [Lags_endoA,Lags_shocksA]=find(bicA==max(vec(bicA)));
            Lags_shocksA=Lags_shocksA-1;
            [Lags_endoB,Lags_shocksB]=find(bicB==max(vec(bicB)));
            Lags_shocksB=Lags_shocksB-1;
            [Lags_endoC,Lags_shocksC]=find(bicC==max(vec(bicC)));
            Lags_shocksC=Lags_shocksC-1;
            [Lags_endoD,Lags_shocksD]=find(bicD==max(vec(bicD)));
            Lags_shocksD=Lags_shocksD-1;
            [Lags_endoF,Lags_shocksF]=find(bicF==max(vec(bicF)));
            Lags_shocksF=Lags_shocksF-1;
        else
            [Lags_endoA,Lags_shocksA]=find(aicA==max(vec(aicA)));
            Lags_shocksA=Lags_shocksA-1;
            [Lags_endoB,Lags_shocksB]=find(aicB==max(vec(aicB)));
            Lags_shocksB=Lags_shocksB-1;
            [Lags_endoC,Lags_shocksC]=find(aicC==max(vec(aicC)));
            Lags_shocksC=Lags_shocksC-1;
            [Lags_endoD,Lags_shocksD]=find(aicD==max(vec(aicD)));
            Lags_shocksD=Lags_shocksD-1;
            [Lags_endoF,Lags_shocksF]=find(aicF==max(vec(aicF)));
            Lags_shocksF=Lags_shocksF-1;
        end
    end
    
    
    %%% estimate impulse response to unit shock
    impC=impulse_yg(dpgdpC1(:,1),[ones(length(dpgdpC1),1) dpgdpC1(:,2:Lags_endoC+1) sh1(:,1:Lags_shocksC+1)],20,Lags_endoC+2); % this is the impulse response of disagreement
    impA=impulse_yg(dpgdpA1(:,1),[ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh(:,1:Lags_shocksA+1)],24,Lags_endoA+2); % this is the impulse response of FE
    impB=impulse_yg(dpgdpB1(:,1),[ones(length(dpgdpB1),1) dpgdpB1(:,2:Lags_endoB+1) sh(:,1:Lags_shocksB+1)],24,Lags_endoB+2); % this is the impulse response of PI
    impF=impulse_yg(dpgdpA1(:,1),[ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoF+1) sh1(:,1:Lags_shocksF+1)],24,Lags_endoF+2); % this is the impulse response of FE to abs. value of shocks
    impE=impA./impB;                                    % response of FE's normalized by inflation response
    impE=impE(dur+1:length(impE));                      % drop first four periods of normalized FE's
    
    rho(i)= fminsearch(@(x) persistence(x,impE,eye(length(impE))),.5);      % estimate of information rigidity from response of FE's normalized by response of inflation

    sipred= sipredicted(rho(i),impB(5:length(impB)),20);                    % counstruct counterfactual response predicted from SI model
    
    impA=impA(5:length(impA));                      % drop first four periods of FE responses
    impB=impB(5:length(impB));                      % drop first four periods of annual inflation responses
    impF=impF(5:length(impF));                      % drop first four periods of FE responses to abs. value of shocks
    
    % distributions of parameters for bootstraps
    ivopt.lags=Lags; ivopt.linear=1;
    b0A=zeros(1,Lags_endoA+Lags_shocksA+1);
    outA = iv(b0A,ivopt,dpgdpA1(:,1),...
        [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh(:,1:Lags_shocksA+1)],...
        [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh(:,1:Lags_shocksA+1)]);
    betaA=outA.beta;     seA=outA.se;   covA=outA.betacov;
    
    b0B=zeros(1,Lags_endoB+Lags_shocksB+1);
    outB = iv(b0B,ivopt,dpgdpB1(:,1),...
        [ones(length(dpgdpB1),1) dpgdpB1(:,2:Lags_endoB+1) sh(:,1:Lags_shocksB+1)],...
        [ones(length(dpgdpB1),1) dpgdpB1(:,2:Lags_endoB+1) sh(:,1:Lags_shocksB+1)]);
    betaB=outB.beta;     seB=outB.se;   covB=outB.betacov;
    
    
    b0C=zeros(1,Lags_endoC+Lags_shocksC+1);
    outC = iv(b0C,ivopt,dpgdpC1(:,1),...
        [ones(length(dpgdpC1),1) dpgdpC1(:,2:Lags_endoC+1) sh1(:,1:Lags_shocksC+1)],...
        [ones(length(dpgdpC1),1) dpgdpC1(:,2:Lags_endoC+1) sh1(:,1:Lags_shocksC+1)]);
    betaC=outC.beta;     seC=outC.se;   covC=outC.betacov;
    
    b0F=zeros(1,Lags_endoF+Lags_shocksF+1);
    outF = iv(b0F,ivopt,dpgdpA1(:,1),...
        [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoF+1) sh1(:,1:Lags_shocksF+1)],...
        [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoF+1) sh1(:,1:Lags_shocksF+1)]);
    betaF=outF.beta;     seF=outF.se;   covF=outF.betacov;
    
    
   
    % Bootstrap distribution of impulse responses
    impbootA=zeros(boots,24);
    impbootB=zeros(boots,24);
    impbootC=zeros(boots,20);
    impbootF=zeros(boots,24);
    
    for j=1:boots
        rdA=randn(Lags_shocksA+Lags_endoA+1+1,1);
        rdA=betaA+(covA^.5)*rdA;
        impbootA(j,:)=impulse1_yg(rdA,dpgdpA1(:,1),...
            [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh(:,1:Lags_shocksA+1)],...
            24,Lags_endoA+2);
        
        rdB=randn(Lags_shocksB+Lags_endoB+1+1,1);
        rdB=betaB+(covB^.5)*rdB;
        impbootB(j,:)=impulse1_yg(rdB,dpgdpB1(:,1),...
            [ones(length(dpgdpB1),1) dpgdpB1(:,2:Lags_endoB+1) sh(:,1:Lags_shocksB+1)],...
            24,Lags_endoB+2);
        
        rdC=randn(Lags_shocksC+Lags_endoC+1+1,1);
        rdC=betaC+(covC^.5)*rdC;
        impbootC(j,:)=impulse1_yg(rdC,dpgdpC1(:,1),...
            [ones(length(dpgdpC1),1) dpgdpC1(:,2:Lags_endoC+1) sh1(:,1:Lags_shocksC+1)],...
            20,Lags_endoC+2);
        
        rdF=randn(Lags_shocksF+Lags_endoF+1+1,1);
        rdF=betaF+(covF^.5)*rdF;
        impbootF(j,:)=impulse1_yg(rdF,dpgdpA1(:,1),...
            [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoF+1) sh1(:,1:Lags_shocksF+1)],...
            24,Lags_endoF+2);
        
        
    end
    impbootA=sort(impbootA);
    impbootB=sort(impbootB);
    impbootC=sort(impbootC);
    impbootF=sort(impbootF);
    impbootA=impbootA(:,5:24);
    impbootB=impbootB(:,5:24);
    impbootF=impbootF(:,5:24);
    
    
    if 4*(i-2)+1~=11
        subaxis(4*(i-2)+1);
        xv = [1:length(impB),fliplr(1:length(impB))];
        yv = [impbootB(ceil(boots*.975),:),fliplr(impbootB(ceil(boots*.025),:))];
        hReg = fill(xv,yv,[0.75 0.75 0.75],'EdgeColor','none'); % draw region
        hold on
        yv = [impbootB(ceil(boots*0.84),:),fliplr(impbootB(ceil(boots*0.16),:))];
        hReg = fill(xv,yv,[0.5 0.5 0.5],'EdgeColor','none'); % draw region
        
        plot(impB,'k','Linewidth',4)
        xlim([1 length(impB)])
        
        hold off
    end
    if i==2 title('Ex-Post Annual Inflation Response to Shocks'); ylabel('Technology Shock'); end
    if i==3 ylabel('News Shock'); end
    if i==4 ylabel('Oil Price Shock'); end
    if i==5 ylabel('Unidentified Shock'); end
    

    if 4*(i-2)+2~=11
        subaxis(4*(i-2)+2);
        xv = [1:length(impA),fliplr(1:length(impA))];
        yv = [impbootA(ceil(boots*.975),:),fliplr(impbootA(ceil(boots*.025),:))];
        hReg = fill(xv,yv,[0.75 0.75 0.75],'EdgeColor','none'); % draw region
        hold on
        yv = [impbootA(ceil(boots*0.84),:),fliplr(impbootA(ceil(boots*0.16),:))];
        hReg = fill(xv,yv,[0.5 0.5 0.5],'EdgeColor','none'); % draw region
        
        plot(impA,'k','Linewidth',4)
        xlim([1 length(impA)])
        hold off
        if i==2 title('Mean Forecast Error Response to Shocks'); end
    end

    if 4*(i-2)+3~=11
        subaxis(4*(i-2)+3);
        xv = [1:length(impF),fliplr(1:length(impF))];
        yv = [impbootF(ceil(boots*.975),:),fliplr(impbootF(ceil(boots*.025),:))];
        hReg = fill(xv,yv,[0.75 0.75 0.75],'EdgeColor','none'); % draw region
        hold on
        yv = [impbootF(ceil(boots*0.84),:),fliplr(impbootF(ceil(boots*0.16),:))];
        hReg = fill(xv,yv,[0.5 0.5 0.5],'EdgeColor','none'); % draw region
        
        plot(impF,'k','Linewidth',4)
        xlim([1 length(impF)])
        hold off
    end
    if i==2
        title('Mean Forecast Error to Abs. Value of Shocks');
    end
    
    if 4*(i-2)+4~=11
        subaxis(4*(i-2)+4);
        xv = [1:length(impC),fliplr(1:length(impC))];
        yv = [impbootC(ceil(boots*.975),:),fliplr(impbootC(ceil(boots*.025),:))];
        hReg = fill(xv,yv,[0.75 0.75 0.75],'EdgeColor','none'); % draw region
        hold on
        yv = [impbootC(ceil(boots*0.84),:),fliplr(impbootC(ceil(boots*0.16),:))];
        hReg = fill(xv,yv,[0.5 0.5 0.5],'EdgeColor','none'); % draw region
        
        plot(impC,'k','Linewidth',4)
        plot(sipred,'k o-','Linewidth',2,'MarkerFaceColor',[1 1 1])
        xlim([1 length(impC)])
        hold off
        if i==2
            title('Disagreement to Abs. Value of Shocks');
            legend('95% CI','66% CI','IRF','Implied response')
        end
    end
    

end


disp('step002 SPF combined done OK')
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
