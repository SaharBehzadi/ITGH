function [PHI] = InfoMatrix(series,lag)
            
    series=series';
    [p, T] = size(series);   

    % p = number of time series or covariates
    % t = number of observations
    D = p * lag;
    N = T - lag;
    
    %prepare design matrix which is useful for the linear combination part
    %of the lasso optimization problem
    % PHI is the preparing sum(X_lagged * B_i) , B_i is the lasso coefficients
    
    PHI = zeros(N,D);

%     t = zeros(N,1);
    for i = 1:N
        for j = 1:p
            cur_row_start = (j-1)*lag+1;
            cur_row_end = cur_row_start + lag - 1;
            PHI(i, cur_row_start:cur_row_end) = series(j,i:(i+lag-1));           
        end
    end
           
%     
%     %do regression with each time series as target
%     for target_row = 1:p
% %        runtime=toc;
% %        if runtime>60
% %            return;
% %        end
%         %X_test = normalize(X_test);
%         t(1:N, 1) = series(target_row, (lag+1):(lag+N))';
%         
%         %       We transform each x_i to W_i and do lasso on this transformation
%         %       		t(1:N, 1) = W(target_row, (lag+1):(lag+N))';
%         
%         if ismember(target_row, I_n)==1
% 
%             model= glm_gaussian(t,PHI,'nointercept');
%             options = statset(statset('glmfit'));
%             options.MaxIter=100000;
%             b = glmfit(PHI,t,'normal','Options',options,'link','identity','constant','off');
%             
%         end
%         
%         if ismember(target_row,I_g)==1
%             
%             model= glm_gamma(t,PHI,'nointercept');
%             options = statset(statset('glmfit'));
%             options.MaxIter=100000;
%             
%             if(nnz(~t)>0)
%                 dip();
%             end
%             b = glmfit(PHI,t,'gamma','Options',options,'link','reciprocal','constant','off');
%             
%         end
%         
%         % if x_j is a poisson time series
%         if ismember(target_row,I_p)==1
% 
%             model= glm_poisson(t,PHI,'nointercept');
%             options = statset(statset('glmfit'));
%             options.MaxIter=100000;
%             b = glmfit(PHI,t,'poisson','Options',options,'link','log','constant','off');
%             
%         end
%         
%         if ismember(target_row,I_B)==1
%             
%             model= glm_logistic(t,PHI,'nointercept');
%             options = statset(statset('glmfit'));
%             options.MaxIter=100000;
%             b = glmfit(PHI,t,'binomial','Options',options,'link','logit','constant','off');
%             
%         end
%   
%         fit_CV_glmfit= cv_penalized(model, @p_adaptive, 'lambdamax', lambda,'lambdaminratio', 0.01,'gamma',0.8, 'adaptivewt',{b});
%        
%         %b_opt is the optimal coefficients regarding AdLasso with glmfit
%         %intial weights
%         
%         b_opt=fit_CV_glmfit.bestbeta;
%         
%         if isempty(b_opt)
%             disp('Isempty');
%             b_opt=zeros(p,lag);
%         end
%         
%         AD_coeffs{target_row} = vec2mat(b_opt, lag);
%             
%     end
%     runtime=toc;
% %     fprintf('AD runtime is: %.2f seconds. \n',runtime')
% end
