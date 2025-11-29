% MSC_LIV_FOMC_FE.m

% This file plots FE responses to shocks results for MSC, LIV, and FOMC.
clear all
close all
%%%  OPTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
boots=2000;      % number of bootstraps for standard errors
lags=0;         % set to -1 for AIC, 0 for BIC, 1 or above for fixed lags
MPvolckerindex=0;   % set to one to drop 1979-1983 period for MP shocks
startmin=1976;      % minimum startdate to use when not using common sample
lags_default = 16;   % number of lags if do not use info criteria (maximum possible lags with AIC/BIC)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load data with NBER recessions
data_NBER_recessions;

%%% ITERATE THROUGH DATASETS
for varindex=1:4
    
    %%% DATA LOAD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if varindex==1   % SPF: inflation
        load step001_all_shocks
        time=shocks_all(:,1);
        
        
        dur=4;
        data_SPF             % load SPF forecast errors (SPFfe) and disagreement (SPFdisp).
        dpgdpA=SPFfe;       % annual forecast errors
        dpgdpB=SPFpi;       % annual inflation
        dpgdpC=exp(SPFdisp);% disagreement (standard deviation)
        dpgdpD=SPFf;        % annual inflation forecast
        startmin=1977;
        
    elseif varindex==2  % MSC: inflation
        load step001_all_shocks
        time=shocks_all(:,1);
        
        data_MSC             % load SPF forecast errors (SPFfe) and disagreement (SPFdisp).
        dpgdpA=MSCfe;       % annual forecast errors
        dpgdpB=MSCpi;       % annual inflation
        dpgdpC=exp(MSCdisp);% disagreement (standard deviation)
        dpgdpD=MSCf;        % annual inflation forecast
        dur=4;              % quarterly frequency
        startmin=1976;
        
    elseif varindex==3  % Livingston: inflation
        load step001_all_shocks
        time=shocks_all_SA(:,1);
        
        data_LIV1             % load LIV forecast errors (SPFfe) and disagreement (SPFdisp).  Business, Banking and Consulting (LIV1)
        dpgdpA=LIVfe;       % annual forecast errors
        dpgdpB=LIVpi;       % annual inflation
        dpgdpC=exp(LIVdisp);% disagreement (standard deviation)
        dpgdpD=LIVf;        % annual inflation forecast
        dur=2;              % semiannual frequency
        lags_default=8;
        
        startmin=1976;
        
    elseif varindex==4  % FOMC: inflation
        load step001_all_shocks
        time=shocks_all_SA(:,1);
        
        data_FOMC1            % load FOMC forecast errors (SPFfe) and disagreement (SPFdisp).
        dpgdpA=FOMCfe;       % annual forecast errors
        dpgdpB=FOMCpi;       % annual inflation
        dpgdpC=(FOMCdisp);   % disagreement (dispersion)
        dpgdpD=FOMCf;        % annual inflation forecast
        dur=2;               % semiannual frequency
        
        startmin=1976;
        
    end
    
    
    
    %%%  ESTIMATION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if lags<1
        Lags=lags_default/dur;
    else
        Lags_shocks=lags_default/dur; % number of lags for the shock series
        Lags_endo  =lags_default/dur;
        Lags       =lags_default/dur;
    end
    
    %%% SET UP DATA FORMATTING GIVEN PERIOD AND SHOCK
    X=[dpgdpA time];
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
    dpgdpB1=dpgdpB(start:enddate);
    dpgdpC1=dpgdpC(start:enddate);
    dpgdpD1=dpgdpD(start:enddate);
    
    time_plot=time(start:enddate);
    
    figure(1)
    subplot(2,2,varindex)
    scale_fig=15;
    if varindex==2
        scale_Y=12;
    else
        scale_Y=2.5;
    end
    area(NBER_recession(:,1),100*NBER_recession(:,2),'FaceColor',[.8 .8 .8],'EdgeColor','none')
    hold on
    [AX,H1,H2] = plotyy( time_plot,dpgdpB1,time_plot,dpgdpC1,'plot');
    if varindex<=4
        set(get(AX(1),'Ylabel'),'String','Inflation rate, % per year')
    else
        set(get(AX(1),'Ylabel'),'String','Unemployment rate, % per year')
    end
    
    set(get(AX(2),'Ylabel'),'String','Disagreement')
    set(AX(1),'YTick',[0:2:15],'YColor','black')
    set(AX(2),'YColor','black')
    set(H1,'color','black','LineStyle','-','Linewidth',3)
    set(H2,'color','black','LineStyle','--','Linewidth',1.5,'MarkerFaceColor',[1 1 1])
    plot( time_plot,dpgdpD1,'black -','Marker','o','MarkerFaceColor',[1 1 1],'Linewidth',1,'MarkerSize',3.5)
    hold off
    set(AX(1),'XLim',[1977 2007])
    set(AX(2),'XLim',[1977 2007])
    set(AX(1),'YLim',[0 scale_fig])
    set(AX(2),'YLim',[-1 scale_Y])
    box off
    if varindex==1   % SPF: inflation
        title('Panel A: Survey of Professional Forecasters ')
        legend('NBER recession','Inflation','Forecast','Disagreement (right axis)','Orientation','horizontal')        
    elseif varindex==2  % MSC: inflation
        title('Panel B: Michigan Survey of Consumers ')
    elseif varindex==3  % Livingston: inflation
        title('Panel C: Fims in Livingston Survey ')
    elseif varindex==4  % FOMC: inflation
        title('Panel D: FOMC Members ')
    end
    
end


disp('step010 plot time series for SPF MSC LIV FOMC - done OK')