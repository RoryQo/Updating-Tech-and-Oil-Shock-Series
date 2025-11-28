%% Historical shocks

Y = num(nlag+1:end,:);
T  = size(Y,1);
N = nvar;
p = nlag;
nd = size(Ltilde,4);
m           = nvar*nlag + nex;                    

all_shocks = nan(T,N,nd);
all_init_cond = nan(T,N,nd);
all_histShocks = nan(T,N,nd);

X = zeros(T,nvar*nlag+nex);
for i=1:nlag
    X(:,nvar*(i-1)+1:nvar*i) = num((nlag-(i-1)):end-i,:) ;
end
if nex>=1
    X(:,nvar*nlag+nex)=ones(T,1);
end


for s=1:nd
    Bdraw       = Bdraw_all(:,:,s);
    Sigmadraw   = Sigmadraw_all(:,:,s);
    Qdraw       = Qdraw_all(:,:,s);
    x           = [reshape(Bdraw,m*nvar,1); reshape(Sigmadraw,nvar*nvar,1); Qdraw(:)];
%     structpara  = f_h_inv(x,info);

    Qmat = nan(N,N);
    for ii = 1:N
        Qmat(1,ii) = Ltilde(1,1,ii,s);
        Qmat(2,ii) = Ltilde(1,2,ii,s);
        Qmat(3,ii) = Ltilde(1,3,ii,s);
        Qmat(4,ii) = Ltilde(1,4,ii,s);
    end

    resid = Y - X*Bdraw;
    histShocks = Qmat\resid';
    betaNoConst = Bdraw(1:end-1,:);

    moving_av = zeros(N*p,N,T+1);

    % Coefficients in companion form
    alpha1 = betaNoConst'; % matrix of the coefficients
    alpha2 = [eye(N*(p-1)) zeros(N*(p-1),N)];
    alpha = [alpha1; alpha2];

    for ii = 1:T
        moving_av(:,:,ii+1) = alpha*moving_av(:,:,ii) + [Qmat*diag(histShocks(:,ii));zeros(N*(p-1),N)];
    end

    init_cond = Y' -squeeze(sum(moving_av(1:N,:,2:end),2));
    all_init_cond(:,:,s) = init_cond';
    temp_shocks = squeeze(moving_av(1,1:N,2:end))';
    all_shocks(:,:,s) = cumsum(temp_shocks);
    all_histShocks(:,:,s) = histShocks';
end    


save(strcat('model_output/all_histShocks_',model_name),'all_histShocks');


%% Shock contributions
all_shock_contributions = nan(T,N,N,nd);
all_shock_contributions_cum = nan(T,N,N,nd);

for s=1:nd
    Bdraw       = Bdraw_all(:,:,s);
    betaNoConst = Bdraw(1:end-1,:);
    
    Qmat = nan(nvar,nvar);
    for ii = 1:nvar
        for jj = 1:nvar
            Qmat(jj,ii) = Ltilde(1,jj,ii,s);
        end
    end
    
    %     Get residuals
    resid = Y - X*Bdraw;
    histShocks = Qmat\resid';
    
    % Coefficients in companion form
    alpha1 = betaNoConst'; % matrix of the coefficients
    alpha2 = [eye(N*(p-1)) zeros(N*(p-1),N)];
    alpha = [alpha1; alpha2];

    moving_av = zeros(N*p,N,T+1);
    for ii = 1:T
        moving_av(:,:,ii+1) = alpha*moving_av(:,:,ii) + [Qmat*diag(histShocks(:,ii));zeros(N*(p-1),N)];
    end
    
    init_cond = Y' -squeeze(sum(moving_av(1:N,:,2:end),2));
    all_init_cond(:,:,s) = init_cond';
    for ii = 1:N
        temp_shocks = squeeze(moving_av(ii,1:N,2:end))';
        all_shock_contributions(:,:,ii,s) = temp_shocks;
        all_shock_contributions_cum(:,:,ii,s) = cumsum(temp_shocks);
    end
end

save(strcat('model_output/all_shock_contributions_',model_name),'all_shock_contributions');

%% Counterfactual GDP

GDP = Y(:,1);
median_decomposition = median(all_shock_contributions,4);
GDP_decomposition = median_decomposition(:,:,1);

GDP_without_PD = GDP-GDP_decomposition(:,3);
GDP_without_PS = GDP-GDP_decomposition(:,4);

save(strcat('model_output/counterfactual_output_',model_name),'GDP','GDP_without_PD','GDP_without_PS');



