% MSC_LIV_FOMC_FE.m

% This file plots FE responses to shocks results for MSC, LIV, and FOMC.
clear all
close all
%%%  OPTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
boots=2000;      % number of bootstraps for standard errors
lags=0;         % set to -1 for AIC, 0 for BIC, 1 or above for fixed lags
startmin=1976;      % minimum startdate to use when not using common sample
lags_default = 16;   % number of lags if do not use info criteria (maximum possible lags with AIC/BIC)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% ITERATE THROUGH DATASETS
for varindex=1:3
    
    %%% DATA LOAD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if varindex==1   % MSE
        % Ordering:
        % 02: Technology        :	Gali
        % 03: News              :	Sims
        % 04: Oil               :	Hamilton
        % 05: Unidentified      :	Residuals

        load step001_all_shocks
        time=shocks_all(:,1);
        Shocks=[shocks_all(:,1) shocks_all(:,2) shocks_all(:,3)  shocks_all(:,4) shocks_all(:,5)];
        
        data_MSC             % load SPF forecast errors (SPFfe) and disagreement (SPFdisp).
        dpgdpA=MSCfe;       % annual forecast errors
        dpgdpB=MSCpi;       % annual inflation
        dpgdpC=exp(MSCdisp);% disagreement (standard deviation)
        dpgdpD=MSCf;        % annual inflation forecast
        dur=4;              % quarterly frequency
        startmin=1976;
        
    elseif varindex==2  % Livingston
        load step001_all_shocks
        time=shocks_all_SA(:,1);
        Shocks=[shocks_all_SA(:,1) shocks_all_SA(:,2) shocks_all_SA(:,3)  shocks_all_SA(:,4) shocks_all_SA(:,5)];
        
        data_LIV1             % load LIV forecast errors (SPFfe) and disagreement (SPFdisp).  Business, Banking and Consulting (LIV1)
        dpgdpA=LIVfe;       % annual forecast errors
        dpgdpB=LIVpi;       % annual inflation
        dpgdpC=exp(LIVdisp);% disagreement (standard deviation)
        dpgdpD=LIVf;        % annual inflation forecast
        dur=2;              % semiannual frequency
        lags_default=8;
        
        startmin=1976;
        
    else
        load step001_all_shocks
        time=shocks_all_SA(:,1);
        Shocks=[shocks_all_SA(:,1) shocks_all_SA(:,2) shocks_all_SA(:,3)  shocks_all_SA(:,4) shocks_all_SA(:,5)];
        
        
        data_FOMC1             % load FOMC forecast errors (SPFfe) and disagreement (SPFdisp).
        dpgdpA=FOMCfe;       % annual forecast errors
        dpgdpB=FOMCpi;       % annual inflation
        dpgdpC=(FOMCdisp);% disagreement (dispersion)
        dpgdpD=FOMCf;        % annual inflation forecast
        dur=2;              % semiannual frequency
        
        startmin=1976;
        
    end
    Shocks1=abs(Shocks);% absolute value of shocks
    
    
    %%%  ESTIMATION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(1)
    subaxis(4,3,1,'SpacingVert',0.03,'SpacingHoriz',0.03);
    for i=2:cols(Shocks)
        if varindex==1 && i==4 && startmin<1975
            startmin0=startmin;
            startmin=1975;
        end
        
        if lags<1
            Lags=lags_default/dur;
        else
            Lags_shocks=lags_default/dur; % number of lags for the shock series
            Lags_endo  =lags_default/dur;
            Lags       =lags_default/dur;
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
        if varindex==1 && i==4 && startmin<1975
            startmin=startmin0;
        end
        
        dpgdpA1=dpgdpA(start:enddate);
        dpgdpA1=makelags(dpgdpA1,Lags);
        
        dpgdpB1=dpgdpB(start:enddate);
        dpgdpB1=makelags(dpgdpB1,Lags);
        
        sh=Shocks(start:enddate,i);
        sh=makelags(sh,Lags);
        sh1=Shocks1(start:enddate,i);
        sh1=makelags(sh1,Lags);
        
        %%% Information criterion lag selection
        if lags<1
            ivopt.lags=2*dur; ivopt.linear=1;
            for ll=1:Lags
                for ll2=0:Lags
                    b0=zeros(1,2*ll+1);
                    outA = iv(b0,ivopt,dpgdpA1(:,1),...
                        [ones(length(dpgdpA1),1) dpgdpA1(:,2:ll+1) sh(:,1:ll2+1)],...
                        [ones(length(dpgdpA1),1) dpgdpA1(:,2:ll+1) sh(:,1:ll2+1)]);
                    bicA(ll,ll2+1)=outA.bic;
                    aicA(ll,ll2+1)=outA.aic;
                    
                    b0=zeros(1,2*ll+1);
                    outB = iv(b0,ivopt,dpgdpB1(:,1),...
                        [ones(length(dpgdpB1),1) dpgdpB1(:,2:ll+1) sh(:,1:ll2+1)],...
                        [ones(length(dpgdpB1),1) dpgdpB1(:,2:ll+1) sh(:,1:ll2+1)]);
                    bicB(ll,ll2+1)=outB.bic;
                    aicB(ll,ll2+1)=outB.aic;
                    
                end
            end
            if lags==0
                [Lags_endoA,Lags_shocksA]=find(bicA==max(vec(bicA)));
                Lags_shocksA=Lags_shocksA-1;
                
                [Lags_endoB,Lags_shocksB]=find(bicB==max(vec(bicB)));
                Lags_shocksB=Lags_shocksB-1;
            else
                [Lags_endoA,Lags_shocksA]=find(aicA==max(vec(aicA)));
                Lags_shocksA=Lags_shocksA-1;
                
                [Lags_endoB,Lags_shocksB]=find(aicB==max(vec(aicB)));
                Lags_shocksB=Lags_shocksB-1;
            end
        end
        
        %%% estimate impulse response to unit shock
        disp([num2str([varindex i]) '|'  num2str([Lags_endoA Lags_shocksA]) '|' num2str([Lags_endoB Lags_shocksB])])
        
        impA=impulse_yg(dpgdpA1(:,1),[ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh(:,1:Lags_shocksA+1)],6*dur,Lags_endoA+2);  % this is the impulse response of FE
        impA=impA(dur+1:length(impA));                      % drop first four periods of FE responses
        
        impB=impulse_yg(dpgdpB1(:,1),[ones(length(dpgdpB1),1) dpgdpB1(:,2:Lags_endoB+1) sh(:,1:Lags_shocksB+1)],6*dur,Lags_endoB+2);  % this is the impulse response of FE
        impB=impB(dur+1:length(impB));                      % drop first four periods of FE responses
        
        impE=impA./impB;                                % response of FE's normalized by inflation response
        impE=impE(dur+1:length(impE));                  % drop periods of forecast error responses during which forecasts predate shocks
        rho(i)= fminsearch(@(x) persistence(x,impE,eye(length(impE))),.5);      % estimate of information rigidity from response of FE's normalized by response of inflation
        
        if varindex>1
            rho(i)=rho(i)^.5;
        end
        
        % distributions of parameters for bootstraps
        ivopt.lags=Lags; ivopt.linear=1;
        b0A=zeros(1,Lags_endoA+Lags_shocksA+1);
        outA = iv(b0A,ivopt,dpgdpA1(:,1),...
            [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh(:,1:Lags_shocksA+1)],...
            [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh(:,1:Lags_shocksA+1)]);
        betaA=outA.beta;     seA=outA.se;   covA=outA.betacov;
        
        ivopt.lags=Lags; ivopt.linear=1;
        b0B=zeros(1,Lags_endoB+Lags_shocksB+1);
        outB = iv(b0B,ivopt,dpgdpB1(:,1),...
            [ones(length(dpgdpB1),1) dpgdpB1(:,2:Lags_endoB+1) sh(:,1:Lags_shocksB+1)],...
            [ones(length(dpgdpB1),1) dpgdpB1(:,2:Lags_endoB+1) sh(:,1:Lags_shocksB+1)]);
        betaB=outB.beta;     seB=outB.se;   covB=outB.betacov;
        
        % compute covariance matrix for draws for impA and impB
        residA=outA.resid;
        residB=outB.resid;
        length_cov=min(length(residA),length(residB));
        X_A=[ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh(:,1:Lags_shocksA+1)];
        X_B=[ones(length(dpgdpB1),1) dpgdpB1(:,2:Lags_endoB+1) sh(:,1:Lags_shocksB+1)];
        X_A=X_A(end-length_cov+1:end,:);
        X_B=X_B(end-length_cov+1:end,:);
        
        X_AB=[X_A zeros(rows(X_A),cols(X_B)); zeros(rows(X_B),cols(X_A)) X_B];
        Y_AB=[dpgdpA1(end-length_cov+1:end,1); dpgdpB1(end-length_cov+1:end,1)];
        outAB = iv(b0A,ivopt,Y_AB,X_AB,X_AB);
        beta_AB=outAB.beta;     se_AB=outAB.se;   cov_AB=outAB.betacov;
        
        
        % Bootstrap distribution of impulse responses
        impbootA=zeros(boots,6*dur);
        impbootB=zeros(boots,6*dur);
        
        for j=1:boots
            rdA=randn(Lags_shocksA+Lags_endoA+1+1,1);
            rdA=betaA+(covA^.5)*rdA;
            impbootA(j,:)=impulse1_yg(rdA,dpgdpA1(:,1),...
                [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh(:,1:Lags_shocksA+1)],...
                6*dur,Lags_endoA+2);
            
            rdB=randn(Lags_shocksB+Lags_endoB+1+1,1);
            rdB=betaB+(covB^.5)*rdB;
            impbootB(j,:)=impulse1_yg(rdB,dpgdpB1(:,1),...
                [ones(length(dpgdpB1),1) dpgdpB1(:,2:Lags_endoB+1) sh(:,1:Lags_shocksB+1)],...
                6*dur,Lags_endoB+2);
            
            
        end
        impbootA=sort(impbootA);
        impbootA=impbootA(:,dur+1:6*dur);
        impbootB=sort(impbootB);
        impbootB=impbootB(:,dur+1:6*dur);
        
        subaxis(varindex +(i-2)*3);
        xv = [1:length(impA),fliplr(1:length(impA))];
        yv = [impbootA(ceil(boots*.975),:),fliplr(impbootA(ceil(boots*.025),:))];
        hReg = fill(xv,yv,[0.75 0.75 0.75],'EdgeColor','none'); % draw region
        hold on
        yv = [impbootA(ceil(boots*0.84),:),fliplr(impbootA(ceil(boots*0.16),:))];
        hReg = fill(xv,yv,[0.5 0.5 0.5],'EdgeColor','none'); % draw region
        plot(impA,'k','Linewidth',4)
        xlim([1 length(impA)])
        
        hold off
        if varindex==1
            if i==2 ylabel('Tech Shocks'); elseif i==3 ylabel('News Shocks'); elseif i==4 ylabel('Oil Price Shocks'); else ylabel('Unidentified Shocks'); end
        end
        if i==2
            if varindex==1 title('Consumers'); elseif varindex==2 title('Firms'); else title('FOMC Members'); end
        elseif i==5
            if varindex==1 xlabel('Quarters'); else xlabel('Half-Years'); end
        end
  
    end
    
end

legend('95% CI','66% CI','IRF')

disp('step003 MSC LIV FOMC - FE - done OK')