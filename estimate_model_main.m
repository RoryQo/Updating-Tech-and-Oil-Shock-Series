%==========================================================================
% Replication codes for "Estimating hysteresis effects", by
% Furlanetto, Lepetit, Robstad, Rubio-Ramirez, Ulvedal (2023),
% AEJ:Macroeconomics
% The codes use functions from: 
% - Arias, Rubio-Ramirez and Waggoner (2019) Econometrica 
% - Giannone, Lenza and Primiceri (2015) Review of Economics and Statistics
%==========================================================================
%% Housekeeping

clear variables;
clear;
close all;
userpath('clear');
clc;
tic;

addpath(genpath('../helpfunctions')) 
addpath(genpath('../helpfunctions/plothelpfunctions')) 
addpath(genpath('../helpfunctions/Functions_GLP/GLPreplicationWeb'))       % Prior Selection for Vector Autoregressions
addpath(genpath('../helpfunctions/Functions_GLP/BGLreplication'))          % Conditional Forecasts and Scenario Analysis with Vector Autoregressions for Large Cross-Sections
addpath(genpath('../helpfunctions/Functions_GLP/AdditionalFunctions'))     % Other functions

%% Settings - reduced form model

% Sample settings
startPreSample  = '1949Q1'; % Start of pre-sample (used to compute y0_hat in 
startSample     = '1983Q1'; % Start of sample
endSample       = '2019Q4'; % End of sample

% Other settings
nvar            = 4;        % number of endogenous variables
nlag            = 3;        % number of lags
horizon         = 40;       % maximum horizon for IRFs
nd              = 2e3;      % number of orthogonal-reduced-form (B,Sigma,Q) draws
timesMCMC       = 100;      % number of mcmc draws = nd*timesMCMC
ndDisc          = 1e3;      % number of burn-in MCMC draws

%% Identifying restrictions. Code from Arias, Rubio-Ramirez and Waggoner (2019)
% identification: declare Ss and Zs matrices
%==========================================================================
% restrictions on IRFs
horizons=[0,1,inf];         % horizons to restrict: restricting IRFs on the two first periods and long-run
NS = numel(horizons);       % number of objects in F(THETA) to which we impose sign and zero restrictios: F(THETA)=[L_{0};L_{infinity}]

% Specify the short term sign restrictions
S = cell(nvar,1);
for ii=1:nvar
    S{ii}=zeros(0,nvar*NS);
end

% Shock 1: Temporary Demand
ns1  = (NS-1)*2; 
S{1} = zeros(ns1,nvar*NS);
% Impact
S{1}(1,1) = 1; % GDP
S{1}(2,2) = 1; % Prices
% horizon 1
S{1}(3,nvar+1)=1; % GDP
S{1}(4,nvar+2)=1; % Prices


% Shock 2: Temporary Supply
ns2  = (NS-1)*2; 
S{2} = zeros(ns2,nvar*NS);
% Impact
S{2}(1,1) = 1;  % GDP
S{2}(2,2) = -1; % Prices
% horizon 1
S{2}(3,nvar+1)=1; % GDP
S{2}(4,nvar+2)=-1; % Prices

% Shock 3: Permanent Demand
ns3  = (NS-1)*2; 
S{3} = zeros(ns3,nvar*NS);
% Impact
S{3}(1,1) = 1; % GDP
S{3}(2,2) = 1; % Prices
% horizon 1
S{3}(3,nvar+1)=1; % GDP
S{3}(4,nvar+2)=1; % Prices


% Shock 4: Permanent Supply
% Impact
ns4  = (NS-1)*2; 
S{4} = zeros(ns4,nvar*NS);
S{4}(1,1) = 1;  % GDP
S{4}(2,2) = -1; % Prices
% horizon 1
S{4}(3,nvar+1)=1; % GDP
S{4}(4,nvar+2)=-1; % Prices



% Specify the long term zero restrictions
Z=cell(nvar,1);
for i=1:nvar
    Z{i}=zeros(0,NS*nvar);
end

% Shock 1: Temporary Demand
nz1=2; 
Z{1}=zeros(nz1,NS*nvar);
Z{1}(1,(NS-1)*nvar+1)=1; % GDP
Z{1}(2,(NS-1)*nvar+3)=1; % Employment

% Shock 2: Temporary Supply
nz2=2; 
Z{2}=zeros(nz2,NS*nvar);
Z{2}(1,(NS-1)*nvar+1)=1; % GDP
Z{2}(2,(NS-1)*nvar+3)=1; % Employment


%% Load data 
% Import data from excel file
% [excelData,excelText] = xlsread('data_hysteresis.xlsx');

% Load data
load('data_hysteresis.mat');

% Dates 
datesExcel = excelText(2:end,1);

% Add variables to rawData object
rawVariables = excelText(1,2:end); % Name of variables (using Fred-names)
for ii = 1:length(rawVariables)
    rawData.(rawVariables{ii}) = excelData(:,ii);
end

%% Convert data
variable_list = {% Short name, code generating variable, name, transformation
    'y',    'log(rawData.GDPC1)-log(rawData.B230RC0Q173SBEA)',  'GDP',          'diff';...
    'p',    'log(rawData.DPCERD3Q086SBEA)',                     'Prices',       'diff';...
    'e',    'log(rawData.EMRATIO*0.01)',                        'Employment',   'diff';...
    'i',    'log(rawData.GPDIC1)-log(rawData.B230RC0Q173SBEA)', 'Investment',   'diff'};

variables = variable_list(:,1)'; % Short name of variable
var_legends = variable_list(:,3)'; % Descriptive name of variable

% Load data into the DATA object
for ii = 1:size(variable_list,1)
    codeString = strcat('DATA.',variable_list{ii,1},' = ',variable_list{ii,2},';');
    eval(codeString);
end

data    = nan(size(DATA.y,1)-1,size(variables,2)); % Data matrix

% Take first differences (where specified)
for ii = 1:size(variables,2)
    if strcmp('diff',variable_list{ii,4})
        data(:,ii) = DATA.(variables{ii})(2:end,:)-DATA.(variables{ii})(1:end-1,:);
    else
        data(:,ii) = DATA.(variables{ii})(2:end,:);
    end
end

data = data*100; % Multiply data by 100
dates = datesExcel(2:end); % Dates 

startIndPreSample   = find(strcmp(startPreSample,dates)); % First observation in pre-sample
endInd              = find(strcmp(endSample,dates));      % Last observation in sample
data                = data(startIndPreSample:endInd,:);      % Remove observations before the start of the pre-sample and after the end of the sample
dates               = dates(startIndPreSample:endInd,:);     % Remove observations before the start of the pre-sample and after the end of the sample

%% Model setup

startInd    = find(strcmp(startSample,dates));    % first observation
num         = data(startInd:end,:);               % data matrix
dates_smpl  = dates(startInd+nlag:end);           % dates in sample
y0_hat      = mean(data(1:startInd-1,:));         % y0_hat used in sum-of-coefficients prior
nex         = 1;                                  % set equal to 1 if a constant is included; 0 otherwise
m           = nvar*nlag + nex;                    % 
iter_show   = 1;                                % display iteration every iter_show draws
e           = eye(nvar);                          % create identity matrix
conjugate   = 'structural';                       % structural or irfs or empty

%% Estimate reduced form model using Primiceri, Lenza and Giannone (2015) priors
mcmc_const = 2.5;
res    = bvarGLP_y0(num, nlag, 'noc',1,'sur', 0, 'mcmc', 1, 'MCMCconst', mcmc_const, 'MNalpha',0,'MNpsi',0,'pos', [1,2,3,4], 'Ndraws', timesMCMC*nd+ndDisc, 'Ndrawsdiscard', ndDisc, 'hyperpriors', 1,'y0_custom',y0_hat);  


%% Settings for info object (from Arias, Rubio-Ramirez and Waggoner (2019))
info=SetupInfo(nvar,m,Z,@(x)chol(x));

% ZIRF()
info.nlag     = nlag;
info.horizons = horizons;
info.ZF       = @(x,y)ZIRF(x,y);

% functions useful to compute the importance sampler weights
fs      = @(x)ff_h(x,info);
r       = @(x)ZeroRestrictions(x,info);

if strcmp(conjugate,'irfs')==1
    fo              = @(x)f_h(x,info);
    fo_str2irfs     = @(x)StructuralToIRF(x,info);
    fo_str2irfs_inv = @(x)IRFToStructural(x,info);
    r_irfs          = @(x)IRFRestrictions(x,info); 
end


% function useful to check the sign restrictions
fh_S_restrictions  = @(y)StructuralRestrictions(y,S,info);


%% Useful definitions (from Arias, Rubio-Ramirez and Waggoner (2019)) 
% definitios used to store orthogonal-reduced-form draws, volume elements, and unnormalized weights
Bdraws         = cell([nd,1]); % reduced-form lag parameters
Sigmadraws     = cell([nd,1]); % reduced-form covariance matrices
Qdraws         = cell([nd,1]); % orthogonal matrices
storevefh      = zeros(nd,1);  % volume element f_{h}
storevegfhZ    = zeros(nd,1);  % volume element g o f_{h}|Z
uw             = zeros(nd,1);  % unnormalized importance sampler weights

if strcmp(conjugate,'irfs')==1
    storevephi      = zeros(nd,1);  % volume element f_{h}
    storevegphiZ    = zeros(nd,1);  % volume element g o f_{h}|Z
end

% definitions related to IRFs; based on page 12 of Rubio, Waggoner, and Zha (RES 2010)
J      = [e;repmat(zeros(nvar),nlag-1,1)];
A      = cell(nlag,1);
extraF = repmat(zeros(nvar),1,nlag-1);
F      = zeros(nlag*nvar,nlag*nvar);
for l=1:nlag-1
    F((l-1)*nvar+1:l*nvar,nvar+1:nlag*nvar)=[repmat(zeros(nvar),1,l-1) e repmat(zeros(nvar),1,nlag-(l+1))];
end

% definition to facilitate the draws from B|Sigma
hh              = info.h;


%% Initialize counters to track the state of the computations (from Arias, Rubio-Ramirez and Waggoner (2019))

counter = 1;
counter2 = 1;
goodrecord = 1;
sizemcmc=size(res.mcmc.beta,3);

while goodrecord<=nd
    
    counter2 = counter2 +1;
    
    record = randi(sizemcmc);
    
    
    %% step 1 in Algorithm 2
    % Get parameter draws from the reduced form estimation
    Bdraw        = [res.mcmc.beta(2:end,:,record); res.mcmc.beta(1,:,record)];
    Sigmadraw     = res.mcmc.sigma(:,:,record);
    cholSigmadraw = hh(Sigmadraw)';


    % store reduced-form draws
    Bdraws{goodrecord,1}     = Bdraw;
    Sigmadraws{goodrecord,1} = Sigmadraw;
   
    %% steps 2:4 of Algorithm 2
    w           = DrawW(info);   
    %x           = [vec(Bdraw); vec(Sigmadraw); w];
    %structpara  = ff_h_inv(x,info);
    
    % store the matrix Q associated with step 3
    Qdraw           = SpheresToQ(w,info,Bdraw,Sigmadraw);
    Qdraw           = reshape(Qdraw,nvar,nvar);
    %Qdraws{goodrecord,1} = reshape(Qdraw,nvar,nvar);

    %% Eficiency
    L0 = info.h(Sigmadraw)'*Qdraw;
    if L0(1,1)<0
        Qdraw(:,1)=-Qdraw(:,1);
    end
    
    %L0 = info.h(Sigmadraw)'*Qdraw;
    if L0(1,2)<0 
        Qdraw(:,2)=-Qdraw(:,2);
    end
    
    %L0 = info.h(Sigmadraw)'*Qdraw;
    if L0(1,3)<0
        Qdraw(:,3)=-Qdraw(:,3);
    end
    
    %L0 = info.h(Sigmadraw)'*Qdraw;
    if L0(1,4)<0 
        Qdraw(:,4)=-Qdraw(:,4);
    end
    
    Qdraws{goodrecord,1} = Qdraw;

    x           = [vec(Bdraw); vec(Sigmadraw); vec(Qdraw)];
    structpara  = f_h_inv(x,info);
    
    %% check if sign restrictions hold
    signs      = fh_S_restrictions(structpara);

    if (sum(signs>0))==size(signs,1)
       
  
        %% compute importance sampling weights
        
        switch conjugate
            
            case 'structural'
                
                
                storevefh(goodrecord,1)   = (nvar*(nvar+1)/2)*log(2)-(2*nvar+m+1)*LogAbsDet(reshape(structpara(1:nvar*nvar),nvar,nvar));
                storevegfhZ(goodrecord,1) = LogVolumeElement(fs,structpara,r); 
                uw(goodrecord,1)          = exp(storevefh(goodrecord,1) - storevegfhZ(goodrecord,1));
                
            case 'irfs'
                
                irfpara                = fo_str2irfs(structpara);
                storevephi(goodrecord,1)   = LogVolumeElement(fo,structpara)   + LogVolumeElement(fo_str2irfs_inv,irfpara);%log(2)*nvar*(nvar+1)/2 - LogAbsDet(inv(reshape(structpara(1:nvar*nvar),nvar,nvar)*reshape(structpara(1:nvar*nvar),nvar,nvar)'))*(2*nvar*nlag-m-1)/2;
                storevegphiZ(goodrecord,1) = LogVolumeElement(fs,structpara,r) + LogVolumeElement(fo_str2irfs_inv,irfpara,r_irfs); 
                uw(goodrecord,1)           = exp(storevephi(goodrecord,1) - storevegphiZ(goodrecord,1));
                
            otherwise
                
                uw(goodrecord,1) = 1;
                
        end
        
        counter = counter + 1;
        goodrecord = goodrecord + 1;
        
    end
    
    if counter==iter_show
        
%         goodrecord
        
        display(['Number of draws = ',num2str(goodrecord)])
        display(['Remaining draws = ',num2str(nd-(goodrecord))])
        counter =0;
        
    end
    
    
    
    
end
toc


% compute the normalized weights and estimate the effective sample size of the importance sampler
imp_w  = uw/sum(uw);
ne     = floor(1/sum(imp_w.^2));


%% Useful definitions to store relevant objects (from Arias, Rubio-Ramirez and Waggoner (2019))
A0tilde       = zeros(nvar,nvar,ne);               % define array to store A0
Aplustilde    = zeros(m,nvar,ne);                  % define array to store Aplus
Ltilde        = zeros(horizon+1,nvar,nvar,ne);     % define array to store IRF
Llongrun      = zeros(nvar,nvar,ne);                 % define array to store FEVD
cumLtilde     = zeros(horizon+1,nvar,nvar,ne);     % define array to store IRF
% initialize counter to track the state of the importance sampler
count_IRF     = 0;
Qdraw_all = nan(nvar,nvar,ne);
Bdraw_all = nan([size(Bdraws{1,1}),ne]);
Sigmadraw_all = nan(nvar,nvar,ne);

for s=1:nd
    
    %% draw: B,Sigma,Q
    is_draw     = randsample(1:size(imp_w,1),1,true,imp_w);
    Bdraw       = Bdraws{is_draw,1};
    Sigmadraw   = Sigmadraws{is_draw,1};
    Qdraw       = Qdraws{is_draw,1};
    
    x          = [reshape(Bdraw,m*nvar,1); reshape(Sigmadraw,nvar*nvar,1); Qdraw(:)];
    structpara = f_h_inv(x,info);
    

    LIRF = IRF_horizons(structpara, nvar, nlag, m, 0:horizon);
    Llongrun(:,:,s) = IRF_horizons(structpara, nvar, nlag, m, Inf);
   
    
    for h=0:horizon
        Ltilde(h+1,:,:,s) =  LIRF(1+h*nvar:(h+1)*nvar,:);
         for i=1:nvar       
            cumLtilde(h+1,1:nvar,i,s)    = sum(Ltilde(1:h+1,1:nvar,i,s),1);
         end
    end
    
      
 
    Qdraw_all(:,:,s) = Qdraw; 
    Bdraw_all(:,:,s) = Bdraw; 
    Sigmadraw_all(:,:,s) = Sigmadraw; 
    % store weighted independent draws
    A0tilde(:,:,s)    = reshape(structpara(1:nvar*nvar),nvar,nvar);
    Aplustilde(:,:,s) = reshape(structpara(nvar*nvar+1:end),m,nvar);
    
end
A0tilde      = A0tilde(:,:,1:s);
Aplustilde   = Aplustilde(:,:,1:s);
Ltilde_diff  = Ltilde;
Ltilde       = cumLtilde(:,:,:,1:s);
productivity = Ltilde(:,1,:,:)-Ltilde(:,3,:,:);
Ltilde       = [Ltilde, productivity];

save('model_output/output_model_main','Ltilde','num','nvar','nlag','nex','dates_smpl');
