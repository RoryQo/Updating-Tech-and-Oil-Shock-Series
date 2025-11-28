%==========================================================================
% Replication codes for "Estimating hysteresis effects", by
% Furlanetto, Lepetit, Robstad, Rubio-Ramirez, Ulvedal (2023),
% AEJ:Macroeconomics
% The codes use functions from: 
% - Arias, Rubio-Ramirez and Waggoner (2019) Econometrica 
% - Giannone, Lenza and Primiceri (2015) Review of Economics and Statistics
%
% This file runs all the estimations used in the paper, and stores results
% in the folder "model_output". The file "plot_figures.m" plots all the
% figures in the paper, based on the files stored in "model_output"
%==========================================================================

%% Add paths for functions and set seed
addpath('Figure_codes')
addpath('Estimation_codes')
addpath('Data')
addpath(genpath('helpfunctions')) 


%% %%%%%%%%%%%%%%%% Estimations for figures in main text %%%%%%%%%%%%%%%%%%

%% 1. Blanchard-Quah with output and inflation (Figure 1)
rng(0);

% Estimate over the 1949Q1-1982Q4 sample
estimate_model_BQ_49_82;

% Estimate over the 1983Q1-2019Q4 sample
estimate_model_BQ_83_19;

%% 2. Main model (Figures 2-9, 12 and A-4)
clear;
rng(0);

% Estimate model
estimate_model_main; % Estimates the model and saves output

% Compute historical shocks
model_name = 'main';
historical_shocks; % Compute time series of historical shocks 

% Local projections
startDate = '1983Q1';
endDate = '2019Q4';

% Local projections: 20 quarters horizon
local_projections_20;

% Local projections: 40 quarters horizon
local_projections_40;

%% 3. Pre-crisis model, 1983Q1-2007Q4 (Figures 10-13)

clear;
rng(0);

% Estimate model
estimate_model_preCrisis; % Estimates the model and saves output in 'output_preCrisis_model.m'

model_name = 'preCrisis';

% Compute historical shocks
historical_shocks; % Compute time series of historical shocks 

% Local projections
startDate = '1983Q1';
endDate = '2007Q4';

% Local projections: 20 quarters horizon
local_projections_20;


%% 4. Model with break in 2008 (Figure 10)
clear;
rng(0);
estimate_model_break2008;

%% 5. Model with employment in levels (Figure 10)
clear;
rng(0);
estimate_model_ePopLevel;


%% 6. Model for the 1949Q1-2019Q4 sample (Figure 10)
clear;
rng(0);
estimate_model_49_19; % Estimates the main model and saves output in 'output_49_82_model.m'

%% 7. Model with shadow rate, 1983Q1-2007Q4 sample (Figure 12, 13)
clear;
rng(0);
estimate_model_MP4_preCrisis;

%% 8. Model with shadow rate, 1983Q1-2019Q4 sample (Figure 12, 13)
clear;
rng(0);
estimate_model_MP4;

%% 9. Model with shadow rate, 1983Q1-2019Q4 sample - monetary policy parameters rescaled (Figure 13)
clear;
rng(0);
estimate_model_MP4_CF;


%% 10. Estimate main model over an expanding window (Figure 14) [NOTE: This script runs 137 estimations, and takes a long time]
clear;
rng(0);
estimate_model_expanding;

%% 11. Model with monetary shocks (Figure 16)
clear;
rng(0);
estimate_model_monetaryPolicy_5var;

%% 12. Model with labor supply and technology shocks (Figure 17)
clear;
rng(0);
estimate_model_laborSupply;

%% 13. Model with relative price of investment (Figure 18)
clear;
rng(0);
estimate_model_relPriceInvestment

%% 14. Monte Carlo excercise (Figure 19)
clear;
rng(0);
monte_carlo_population

%% %%%%%%%%%%%%%%%% Estimations for figures in appendix %%%%%%%%%%%%%%%%%%%

%% 15. Blanchard Quah replication (Figure A-1)
clear;
rng(0);
replicate_BQ;

%% 16. Model where employment to population ratio is replaced by hours per capita (Figure A-2)
clear;
rng(0);
estimate_model_hours;

%% 17. Model with restrictions imposed on horizon 4 only (Figure A-3)
clear; 
rng(0);
estimate_model_hor4only;

%% 18. Model with business sector output and hours (Figure A-5 and A-6)
clear;
rng(0);
estimate_model_busSecY_hours;
%% 19. Model where data has been quadratically detrended (Figure A-7)
clear; 
rng(0);
estimate_model_83_19_detr_quadr;
%% 20. Model where data has been detrended using a one-sided HP-filter (Figure A-7)
clear; 
rng(0);
estimate_model_83_19_detr_HP1s;

%% 21. Model with prime-age male employment (Figure A-8)
clear; 
rng(0);
estimate_model_primeEmpl;

%% 22. Model where unemployment rate replaces employment to population ratio (Figure A-9)
clear;
rng(0);
estimate_model_unempl_replEmpl;

%% 23. Model where unemployment rate replaces investment (Figure A-9)
clear;
rng(0);
estimate_model_unempl_replInv;

%% 24. Monte Carlo exercise with small sample uncertainty (Figure A-10)
clear;
rng(0);
monte_carlo_smallsample


toc
