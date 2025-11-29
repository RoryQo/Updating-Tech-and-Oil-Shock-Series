% MSC_LIV_FOMC_Absolute.m

% This file plots responses of forecast errors to absolute values of shocks
clear all
close all
%%%  OPTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
boots=10000;      % number of bootstraps for standard errors
lags=0;         % set to -1 for AIC, 0 for BIC, 1 or above for fixed lags
startmin=1976;      % minimum startdate to use when not using common sample
lags_default = 16;   % number of lags if do not use info criteria (maximum possible lags with AIC/BIC)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% ITERATE THROUGH DATASETS
for varindex=1:3
    
    %%% DATA LOAD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if varindex==1
        % Ordering:
        % 02: Technology        :	Gali
        % 03: News              :	Sims
        % 04: Oil               :	Hamilton
        % 05: Unidentified      :	Residuals
        load step001_all_shocks
        time=shocks_all(:,1);
        Shocks=[shocks_all(:,1) shocks_all(:,2) shocks_all(:,3)  shocks_all(:,4) shocks_all(:,5)];
        
        data_MSC              % load SPF forecast errors (SPFfe) and disagreement (SPFdisp).
        dpgdpA=MSCfe;       % annual forecast errors
        dur=4;              % quarterly frequency
        startmin=1976;
        
    elseif varindex==2
        load step001_all_shocks
        time=shocks_all_SA(:,1);
        Shocks=[shocks_all_SA(:,1) shocks_all_SA(:,2) shocks_all_SA(:,3)  shocks_all_SA(:,4) shocks_all_SA(:,5)];
        
        data_LIV1             % load LIV forecast errors (SPFfe) and disagreement (SPFdisp).  Business, Banking and Consulting (LIV1)
        dpgdpA=LIVfe;       % annual forecast errors
        dur=2;              % semiannual frequency
        lags_default=8;
        startmin=1976;
        
    else
        load step001_all_shocks
        time=shocks_all_SA(:,1);
        Shocks=[shocks_all_SA(:,1) shocks_all_SA(:,2) shocks_all_SA(:,3)  shocks_all_SA(:,4) shocks_all_SA(:,5)];
        
        data_FOMC1             % load FOMC forecast errors (SPFfe) and disagreement (SPFdisp).
        dpgdpA=FOMCfe;       % annual forecast errors
        dur=2;              % semiannual frequency
        startmin=1976;
        
    end
    Shocks=[Shocks(:,1:3) Shocks(:,5)];     % drop oil price shocks since these are all positive by construction
    Shocks1=abs(Shocks);                    % absolute value of shocks
    
    
    %%%  ESTIMATION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(1)
    subaxis(3,3,1,'SpacingVert',0.04,'SpacingHoriz',0.04);
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
                        [ones(length(dpgdpA1),1) dpgdpA1(:,2:ll+1) sh1(:,1:ll2+1)],...
                        [ones(length(dpgdpA1),1) dpgdpA1(:,2:ll+1) sh1(:,1:ll2+1)]);
                    bicA(ll,ll2+1)=outA.bic;
                    aicA(ll,ll2+1)=outA.aic;
                end
            end
            if lags==0
                [Lags_endoA,Lags_shocksA]=find(bicA==max(vec(bicA)));
                Lags_shocksA=Lags_shocksA-1;
            else
                [Lags_endoA,Lags_shocksA]=find(aicA==max(vec(aicA)));
                Lags_shocksA=Lags_shocksA-1;
            end
        end
        
        %%% estimate impulse response to unit shock
        [varindex i Lags_endoA Lags_shocksA]
        
        impA=impulse_yg(dpgdpA1(:,1),[ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh1(:,1:Lags_shocksA+1)],6*dur,Lags_endoA+2);  % this is the impulse response of FE
        impA=impA(dur+1:length(impA));                      % drop first four periods of FE responses
        
        % distributions of parameters for bootstraps
        ivopt.lags=Lags; ivopt.linear=1;
        b0A=zeros(1,Lags_endoA+Lags_shocksA+1);
        outA = iv(b0A,ivopt,dpgdpA1(:,1),...
            [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh1(:,1:Lags_shocksA+1)],...
            [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh1(:,1:Lags_shocksA+1)]);
        betaA=outA.beta;     seA=outA.se;   covA=outA.betacov;
        
        % Bootstrap distribution of impulse responses
        impbootA=zeros(boots,6*dur);
        for j=1:boots
            rdA=randn(Lags_shocksA+Lags_endoA+1+1,1);
            rdA=betaA+(covA^.5)*rdA;
            impbootA(j,:)=impulse1_yg(rdA,dpgdpA1(:,1),...
                [ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh1(:,1:Lags_shocksA+1)],...
                6*dur,Lags_endoA+2);
        end
        impbootA=sort(impbootA);
        impbootA=impbootA(:,dur+1:6*dur);
        
        %     subplot(3,3,varindex+(i-2)*3)       % plot forecast error response to shock 1
        subaxis(varindex+(i-2)*3);
        xv = [1:length(impA),fliplr(1:length(impA))];
        yv = [impbootA(ceil(boots*.975),:),fliplr(impbootA(ceil(boots*.025),:))];
        hReg = fill(xv,yv,[0.75 0.75 0.75],'EdgeColor','none'); % draw region
        
        hold on
        yv = [impbootA(ceil(boots*0.84),:),fliplr(impbootA(ceil(boots*0.16),:))];
        hReg = fill(xv,yv,[0.5 0.5 0.5],'EdgeColor','none'); % draw region
        
        
        plot(impA,'k','Linewidth',4)
        hold on
        xlim([1 length(impA)])
        hold off
        if varindex==1
            if i==2 ylabel('Tech Shocks'); elseif i==3 ylabel('News Shocks'); else ylabel('Unidentified Shocks'); end
        end
        if i==2
            if varindex==1 title('Consumers'); elseif varindex==2 title('Firms'); else title('FOMC Members'); end
        elseif i==4
            if varindex==1 xlabel('Quarters'); else xlabel('Half-Years'); end
        end
        
        
    end
    
end
legend('95% CI','66% CI','IRF')

disp('step003 MSC LIV FOMC - absolute - done OK')