function Best_dist = fitDistribution(X,lag)

% currently it tries 4 distributions from te exponential famiy to find the
% best fitting distribution for any time series X

disp('Fitting process .....');

dtype= {};

if isempty(find(1- (X+1)./(fix(X)+1), 1))
    dtype= 'disc';
else
    dtype= 'cont';
end

% Dimension of data (L: length, p: number of time series)
T = length(X);
N = T - lag;

% Compute the coding cost for various distributions and Sort the time series based on their coding cost!
TS_Costs=zeros(2,2);

t(1:N, 1) = X((lag+1):(lag+N));
PHI=InfoMatrix(X,lag);

switch dtype(1:4)
    case 'cont'
        if min(min(PHI))>0
            for i=1:2:3
                GLM_Model_B = glmfit_ITGH(PHI,t,i);
                TS_Costs(2,i) = ComputeErrorCost(GLM_Model_B.Residuals.Raw);
                TS_Costs(1,i)=i;
            end
        else
            GLM_Model_B = glmfit_ITGH(PHI,t,1);
            TS_Costs(2,1) = ComputeErrorCost(GLM_Model_B.Residuals.Raw);
            TS_Costs(1,1)=1;
            TS_Costs(2,3) = realmax;
            TS_Costs(1,3)=3;
        end
        if TS_Costs(2,1)<TS_Costs(2,3)
            Best_dist = 1;
            display('Fitting Distribution is Normal');
        else
            Best_dist = 3;
            display('Fitting Distribution is Gamma');
        end
        
    case 'disc'
        if max(max(t))<2
            GLM_Model_B = glmfit_ITGH(PHI,t,4);
            TS_Costs(2,4) = ComputeErrorCost(GLM_Model_B.Residuals.Raw);
            TS_Costs(1,4)=4;
            TS_Costs(2,2)=realmax;
            TS_Costs(1,2)=4;
        else
            GLM_Model_B = glmfit_ITGH(PHI,t,2);
            TS_Costs(2,2) = ComputeErrorCost(GLM_Model_B.Residuals.Raw);
            TS_Costs(1,2)=2;
            TS_Costs(2,4)=realmax;
            TS_Costs(1,4)=4;
        end
        
        
        if TS_Costs(2,2)<TS_Costs(2,4)
            Best_dist = 2;
            display('Fitting Distribution is Poisson');
        else
            Best_dist = 4;
            display('Fitting Distribution is Bernoulli');
        end
end