function [beta_new] = glmfit_ITGH(X,Yframe,Dist)


% Normal
if Dist==1
    beta_new=fitglm(X,Yframe,'Distribution','normal','Intercept',false);
%     beta_new=fitglm(X,Yframe,'Distribution','normal');
end

% Poisson
if Dist==2
%     beta_new=glmfit(X,Yframe,'poisson','constant','off');
    beta_new=fitglm(X,Yframe,'Distribution','poisson','Intercept',false);
%     beta_new=fitglm(X,Yframe,'Distribution','poisson');
end

% Gamma
if Dist==3
%     beta_new=glmfit(X,Yframe,'gamma','constant','off');
     beta_new=fitglm(X(2:end,:),Yframe(2:end),'Distribution','gamma','Intercept',false);
%     beta_new=fitglm(X,Yframe,'Distribution','gamma');
end

% binomial
if Dist==4
    beta_new=fitglm(X,Yframe,'Distribution','binomial','Intercept',false);
end
