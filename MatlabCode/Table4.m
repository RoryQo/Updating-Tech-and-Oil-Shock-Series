% Results for Table 4


clear all
close all
%%%  OPTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
boots=10000;      % number of bootstraps for standard errors
lags=0;         % set to -1 for AIC, 0 for BIC, 1 or above for fixed lags
startmin=1976;      

%==================================================================
%           Stack together all agents and shocks
%==================================================================

dur_mat=zeros(4,4);
len_mat=zeros(4,4);        % matrix with the number of coefficients in each regression

% matrix with the start and end of each vector of coefs in regressions
len_mat_posA=zeros(4,4,2);   % regression A
len_mat_posB=zeros(4,4,2);   % regression B

% matrix with the start and end of each vector of regressors (length) in regressions
len_reg_posA=zeros(4,4,2);   % regression A
len_reg_posB=zeros(4,4,2);   % regression B


% matrix that stores # lags of endo var used in estimation
endo_lagsA_mat=zeros(4,4);
endo_lagsB_mat=zeros(4,4);

% matrix that stores # lags of shocks used in estimation
shock_lagsA_mat=zeros(4,4);
shock_lagsB_mat=zeros(4,4);

% counter: relative position of agents/shocks/regression in the stacked
% vector
pos_current_A=0; 
% counter: relative position of agents/shocks/regression in the stacked
% vector
pos_current_B=0;

counter0=1;
Y_all=[];   % matrix of the dep var with all agents/shocks/regressions stacked
X_all=[];   % matrix of the regressors with all agents/shocks/regressions stacked

%%% ITERATE THROUGH DATASETS
for varindex=1:4
    
    % DATA LOAD
    if varindex==1
        load step001_all_shocks
        time=shocks_all(:,1);
        Shocks=[shocks_all(:,1) shocks_all(:,2) shocks_all(:,3)  shocks_all(:,4) shocks_all(:,5)];
        data_SPF             % load SPF forecast errors (SPFfe) and disagreement (SPFdisp).
        dpgdpA=SPFfe;       % annual forecast errors
        dpgdpB=SPFpi;       % annual inflation
        dur=4;              % quarterly frequency
        dur_mat(varindex,:)=dur*ones(1,4);
        lags_default = 8;   % number of lags if do not use info criteria (maximum possible lags with AIC/BIC)
        startmin=1977;      % minimum startdate to use when not using common sample
        
    elseif varindex==2
        
        load step001_all_shocks
        time=shocks_all(:,1);
        Shocks=[shocks_all(:,1) shocks_all(:,2) shocks_all(:,3)  shocks_all(:,4) shocks_all(:,5)];
        
        data_MSC             % load SPF forecast errors (SPFfe) and disagreement (SPFdisp).
        dpgdpA=MSCfe;       % annual forecast errors
        dpgdpB=MSCpi;       % annual inflation
        dur=4;              % quarterly frequency
        dur_mat(varindex,:)=dur*ones(1,4);
        lags_default = 16;   % number of lags if do not use info criteria (maximum possible lags with AIC/BIC)
        startmin=1976;      % minimum startdate to use when not using common sample
        
    elseif varindex==3
        load step001_all_shocks
        time=shocks_all_SA(:,1);
        Shocks=[shocks_all_SA(:,1) shocks_all_SA(:,2) shocks_all_SA(:,3)  shocks_all_SA(:,4) shocks_all_SA(:,5)];
        
        data_LIV1             % load LIV forecast errors (SPFfe) and disagreement (SPFdisp).  Business, Banking and Consulting (LIV1)
        dpgdpA=LIVfe;       % annual forecast errors
        dpgdpB=LIVpi;       % annual inflation
        dur=2;              % semiannual frequency
        lags_default=8;
        dur_mat(varindex,:)=dur*ones(1,4);
        startmin=1976;      % minimum startdate to use when not using common sample
        
    elseif varindex==4
        load step001_all_shocks
        time=shocks_all_SA(:,1);
        Shocks=[shocks_all_SA(:,1) shocks_all_SA(:,2) shocks_all_SA(:,3)  shocks_all_SA(:,4) shocks_all_SA(:,5)];
        
        data_FOMC1             % load FOMC forecast errors (SPFfe) and disagreement (SPFdisp).
        dpgdpA=FOMCfe;       % annual forecast errors
        dpgdpB=FOMCpi;       % annual inflation
        dur=2;              % semiannual frequency
        lags_default=8;
        dur_mat(varindex,:)=dur*ones(1,4);
        startmin=1976;      % minimum startdate to use when not using common sample
        
    end
    
    
    
    %%% ITERATE THROUGH SHOCKS
    for i=2:cols(Shocks)
        if lags<1
            Lags=lags_default/dur;
        else
            Lags_shocks=lags_default/dur; % number of lags for the shock series
            Lags_endo  =lags_default/dur;
            Lags       =lags_default/dur;
        end
        
        % SET UP DATA FORMATTING GIVEN PERIOD AND SHOCK
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
        
        dpgdpA1=dpgdpA(start:enddate);
        dpgdpA1=makelags(dpgdpA1,Lags);
        dpgdpB1=dpgdpB(start:enddate);
        dpgdpB1=makelags(dpgdpB1,Lags);
        
        sh=Shocks(start:enddate,i);
        sh=makelags(sh,Lags);
        
        %%% Information criterion lag selection
        if lags<1
            ivopt.lags=2*dur; ivopt.linear=1;
            for ll=1:Lags
                for ll2=0:Lags
                    b0=zeros(1,2*ll+1);
                    outA = iv(b0,ivopt,dpgdpA1(:,1),...
                        [ones(length(dpgdpA1),1) dpgdpA1(:,2:ll+1) sh(:,1:ll2+1)],...
                        [ones(length(dpgdpA1),1) dpgdpA1(:,2:ll+1) sh(:,1:ll2+1)]);
                    outB = iv(b0,ivopt,dpgdpB1(:,1),...
                        [ones(length(dpgdpB1),1) dpgdpB1(:,2:ll+1) sh(:,1:ll2+1)],...
                        [ones(length(dpgdpB1),1) dpgdpB1(:,2:ll+1) sh(:,1:ll2+1)]);
                    bicA(ll,ll2+1)=outA.bic;
                    aicA(ll,ll2+1)=outA.aic;
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
        
        endo_lagsA_mat(varindex,i-1)=Lags_endoA;
        endo_lagsB_mat(varindex,i-1)=Lags_endoB;
        shock_lagsA_mat(varindex,i-1)=Lags_shocksA;
        shock_lagsB_mat(varindex,i-1)=Lags_shocksB;
        
        %%% estimate impulse response to unit shock
        
        
        YA=dpgdpA1(:,1);
        XA=[ones(length(dpgdpA1),1) dpgdpA1(:,2:Lags_endoA+1) sh(:,1:Lags_shocksA+1)];
        
        YB=dpgdpB1(:,1);
        XB=[ones(length(dpgdpB1),1) dpgdpB1(:,2:Lags_endoB+1) sh(:,1:Lags_shocksB+1)];
        
        impA=impulse_yg(YA,XA,6*dur,Lags_endoA+2);  % this is the impulse response of FE
        impB=impulse_yg(YB,XB,6*dur,Lags_endoB+2);  % this is the impulse response of PI
        % response of FE's normalized by inflation response
        impE=impA./impB;
        % drop periods of forecast error responses during which forecasts
        % predate shocks
        impE=impE(dur+1:length(impE));
        
        % estimate of information rigidity from response of FE's normalized
        % by response of inflation
        rho(1,counter0)= fminsearch(@(x) persistence(x,impE,eye(length(impE))),.5);
        if varindex>2
            rho(1,counter0)=rho(1,counter0)^0.5;
        end
        % stack all variables
        % dependent variables
        Y_all=[Y_all; YA; YB];
        
        % regressors
        X_all=[X_all zeros(rows(X_all),cols(XA)); zeros(rows(XA),cols(X_all)) XA];
        X_all=[X_all zeros(rows(X_all),cols(XB)); zeros(rows(XB),cols(X_all)) XB];
        
        len_mat_posA(varindex,i-1,1)=pos_current_A+1;
        len_mat_posA(varindex,i-1,2)=pos_current_A+cols(XA);
        
        len_mat_posB(varindex,i-1,1)=pos_current_A+cols(XA)+1;
        len_mat_posB(varindex,i-1,2)=pos_current_A+cols(XA)+cols(XB);
        
        len_reg_posA(varindex,i-1,1)=pos_current_B+1;
        len_reg_posA(varindex,i-1,2)=pos_current_B+rows(YA);
        
        len_reg_posB(varindex,i-1,1)=pos_current_B+rows(YA)+1;
        len_reg_posB(varindex,i-1,2)=pos_current_B+rows(YA)+rows(YB);
        
        pos_current_A=pos_current_A+cols(XA)+cols(XB);
        disp([num2str([varindex i]) ' | ' num2str([Lags_endoA Lags_shocksA])  ' | ' num2str([Lags_endoB Lags_shocksB])])
        counter0=counter0+1;
    end % finish iterating over shocks
end     % finish iterating over agents
disp('finish stacking data')


%=====================================================
%       estimate the FULL model:
% agents/shocks/regressions A/B are stacked
%=====================================================
disp('estimate the model on stacked data...')
ivopt.lags=4; ivopt.linear=1;
out_all = iv(zeros(cols(X_all),1),ivopt,Y_all,X_all,X_all);

beta_all=out_all.beta;
cov_all=out_all.betacov;
cov_all_root=cov_all^.5;
disp('           done')
disp('start boots...')
% Bootstrap distribution of impulse responses
for j=1:boots
    if mod(j,100)==0
        disp(j)
    end
    % to compute persistence of the estimates
    rd=randn(length(cov_all),1);
    rd=beta_all+cov_all_root*rd;
    
    %%% ITERATE THROUGH DATASETS
    counter0=1;
    for varindex=1:4
        % iterate over shocks
        for i=1:4
            % retrive coefficients for IRFs
            rd_A=rd(len_mat_posA(varindex,i,1):len_mat_posA(varindex,i,2));
            rd_B=rd(len_mat_posB(varindex,i,1):len_mat_posB(varindex,i,2));
            
            % restore data
            YA=Y_all(len_reg_posA(varindex,i,1):len_reg_posA(varindex,i,2),1);
            YB=Y_all(len_reg_posB(varindex,i,1):len_reg_posB(varindex,i,2),1);
            
            XA=X_all(len_reg_posA(varindex,i,1):len_reg_posA(varindex,i,2),len_mat_posA(varindex,i,1):len_mat_posA(varindex,i,2));
            XB=X_all(len_reg_posB(varindex,i,1):len_reg_posB(varindex,i,2),len_mat_posB(varindex,i,1):len_mat_posB(varindex,i,2));
            
            
            % compute IRFs
            impbootA=impulse1_yg(rd_A,YA,XA,6*dur_mat(varindex,i),endo_lagsA_mat(varindex,i)+2);
            impbootB=impulse1_yg(rd_B,YB,XB,6*dur_mat(varindex,i),endo_lagsB_mat(varindex,i)+2);
            
            % response of FE's normalized by inflation response
            impboot_E=impbootA./impbootB;
            % drop first four periods of normalized FE's
            impboot_E=impboot_E(dur_mat(varindex,i)+1:length(impboot_E));
            
            % estimate of information rigidity from response of FE's normalized by
            % response of inflation
            rho_boot0= fminsearch(@(x) persistence(x,impboot_E,eye(length(impboot_E))),.5);
            
            rho_boot(j,counter0)=rho_boot0;
            if varindex>2
                rho_boot(j,counter0)=rho_boot0^0.5;
            end
            counter0=counter0+1;
        end
    end
    
end
disp('           done')
disp('drop draws that generate boundary: rho=0...')
rho_boot_corrected=[];
for j=1:boots
    if max(rho_boot(j,:)<0.05)==0
        rho_boot_corrected=[rho_boot_corrected; rho_boot(j,:)];
    end
end
disp('           done')

figure(1)
for i=1:4
    for j=1:4
        subplot(4,4,(i-1)*4+j)
        hist(rho_boot_corrected(:,(i-1)*4+j),50)
    end
end
subplot(4,4,1)
ylabel('SPF')
subplot(4,4,5)
ylabel('MSC')
subplot(4,4,9)
ylabel('Firms')
subplot(4,4,13)
ylabel('FOMC')

subplot(4,4,1)
title('Technology')
subplot(4,4,2)
title('News')
subplot(4,4,3)
title('Oil')
subplot(4,4,4)
title('Unidentified')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
disp('compute standard errors...')
se_rho=std(rho_boot_corrected);
se_rho_mat=[];
for i=1:4
    for j=1:4
        se_rho_mat(i,j)=se_rho((i-1)*4+j);
    end
end

rho_mat=[];
for i=1:4
    for j=1:4
        rho_mat(i,j)=rho((i-1)*4+j);
    end
end

disp('           done')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
disp('test equality of speed across agents for each shock...')

% technology
cov1=cov([rho_boot_corrected(:,1) rho_boot_corrected(:,5) rho_boot_corrected(:,9)  rho_boot_corrected(:,13)]);
Bvec=[rho(1) rho(5) rho(9) rho(13)]-mean([rho(1) rho(5) rho(9) rho(13)]);
test4_chi2=Bvec*inv(cov1)*Bvec';
disp(['technology : p-value = ' num2str(1-chi2cdf(test4_chi2,3))])

% news
cov1=cov([rho_boot_corrected(:,2) rho_boot_corrected(:,6) rho_boot_corrected(:,10)  rho_boot_corrected(:,14)]);
Bvec=[rho(2) rho(6) rho(10) rho(14)]-mean([rho(2) rho(6) rho(10) rho(14)]);
test4_chi2=Bvec*inv(cov1)*Bvec';
disp(['news : p-value = ' num2str(1-chi2cdf(test4_chi2,3))])

% oil
cov1=cov([rho_boot_corrected(:,3) rho_boot_corrected(:,7) rho_boot_corrected(:,11)  rho_boot_corrected(:,15)]);
Bvec=[rho(3) rho(7) rho(11) rho(15)]-mean([rho(3) rho(7) rho(11) rho(15)]);
test4_chi2=Bvec*inv(cov1)*Bvec';
disp(['oil : p-value = ' num2str(1-chi2cdf(test4_chi2,3))])

% unidentified
cov1=cov([rho_boot_corrected(:,4) rho_boot_corrected(:,8) rho_boot_corrected(:,12)  rho_boot_corrected(:,16)]);
Bvec=[rho(4) rho(8) rho(12) rho(16)]-mean([rho(4) rho(8) rho(12) rho(16)]);
test4_chi2=Bvec*inv(cov1)*Bvec';
disp(['unidentied : p-value = ' num2str(1-chi2cdf(test4_chi2,3))])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
disp('test equality of speed across shocks for each agent...')

% technology
cov1=cov([rho_boot_corrected(:,1) rho_boot_corrected(:,2) rho_boot_corrected(:,3)  rho_boot_corrected(:,4)]);
Bvec=[rho(1) rho(2) rho(3) rho(4)]-mean([rho(1) rho(2) rho(3) rho(4)]);
test4_chi2=Bvec*inv(cov1)*Bvec';
disp(['SPF   : p-value = ' num2str(1-chi2cdf(test4_chi2,3))])

% news
cov1=cov([rho_boot_corrected(:,5) rho_boot_corrected(:,6) rho_boot_corrected(:,7)  rho_boot_corrected(:,8)]);
Bvec=[rho(5) rho(6) rho(7) rho(8)]-mean([rho(5) rho(6) rho(7) rho(8)]);
test4_chi2=Bvec*inv(cov1)*Bvec';
disp(['MSC   : p-value = ' num2str(1-chi2cdf(test4_chi2,3))])

% oil
cov1=cov([rho_boot_corrected(:,9) rho_boot_corrected(:,10) rho_boot_corrected(:,11)  rho_boot_corrected(:,12)]);
Bvec=[rho(9) rho(10) rho(11) rho(12)]-mean([rho(9) rho(10) rho(11) rho(12)]);
test4_chi2=Bvec*inv(cov1)*Bvec';
disp(['Firms : p-value = ' num2str(1-chi2cdf(test4_chi2,3))])

% unidentified
cov1=cov([rho_boot_corrected(:,13) rho_boot_corrected(:,14) rho_boot_corrected(:,15)  rho_boot_corrected(:,16)]);
Bvec=[rho(13) rho(14) rho(15) rho(16)]-mean([rho(13) rho(14) rho(15) rho(16)]);
test4_chi2=Bvec*inv(cov1)*Bvec';
disp(['FOMC  : p-value = ' num2str(1-chi2cdf(test4_chi2,3))])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
disp('test equality of across shocks and agents...')
Bvec=rho-mean(rho);
cov1=cov(rho_boot_corrected);
test4_chi2=Bvec*inv(cov1)*Bvec';
disp(['All shocks and agents  : p-value = ' num2str(1-chi2cdf(test4_chi2,length(Bvec)-1))])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
mean_SPF=mean([rho(1) rho(2) rho(3) rho(4)]);
mean_MSC=mean([rho(5) rho(6) rho(7) rho(8)]);
mean_mean=(mean_SPF+mean_MSC)/2;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
disp('matrix of info rigidity')
disp(rho_mat)
disp('matrix of s.e. for info rigidity')
disp(se_rho_mat)



