function [Output_adj,runtime] = ITGH_Greedy_PC_Probabilistic(series,lag)

tic;
disp('ITGH is running .....');

% Load data

X = series';

% Dimension of data (L: length, p: number of time series)
dist=X(1,:);
X(1,:)=[];
[T,p] = size(X);
N = T - lag;

% Compute the coding cost and Sort the time series based on their coding cost!
TS_Costs=zeros(3,p);
for i=1:p
    t(1:N, 1) = X((lag+1):(lag+N),i);
    PHI=InfoMatrix(X(:,i),lag);
    
    GLM_Model_B = glmfit_ITGH(PHI,t,dist(i));
    
    bhat0 = GLM_Model_B.Coefficients.Estimate;
    
     PredErrorCost0 = ComputeErrorCost(GLM_Model_B.Residuals.Raw);
%     PredErrorCost0 = ErrorCost(GLM_Model_B.Residuals.Raw,dist(i));
    TS_Costs(1,i)=PredErrorCost0;
    
    TS_Costs(2,i)=i;
end

% Sort time series based on their coding cost
% for i=1:p
%     for j=1:p
%         if(TS_Costs(1,i)<=TS_Costs(1,j))
%             temp=TS_Costs(:,i);
%             TS_Costs(:,i)=TS_Costs(:,j);
%             TS_Costs(:,j)=temp;
%         end
%     end
% end

Output_adj=zeros(p,p);
temp_TS_Cost=TS_Costs;

for target = 1:p
    
    TS_Costs=temp_TS_Cost;
    
    t(1:N, 1) = X((lag+1):(lag+N),target);
    PHI_Xc=InfoMatrix(X,lag);
    GLM_Model_target= glmfit_ITGH(PHI_Xc,t,dist(target));
    
    for j=1:p
        TS_Costs(3,j)=max(max(GLM_Model_target.Coefficients.Estimate((j-1)*lag+1:j*lag)));
    end
    
    
    %     sort according to the min of the coding cost deviation to X_i
    %     TS_Costs=temp_TS_Cost;
    %
    %     for j=1:p
    %         TS_Costs(3,j)=abs(TS_Costs(1,j)-TS_Costs(1,target));
    %     end
    
    for i=1:p
        for j=1:p
            if( TS_Costs(3,i)>=TS_Costs(3,j))
                temp=TS_Costs(:,i);
                TS_Costs(:,i)=TS_Costs(:,j);
                TS_Costs(:,j)=temp;
            end
        end
    end
    
    %     t(1:N, 1) = X((lag+1):(lag+N),target);
    %     X_target=X;
    %     X_target(:,target)=[];
    
    CoefCost0= p*lag*log2(T);
    MDL_Before = sum(TS_Costs(1,:))+CoefCost0;
    
    It_Pays_Off=1;
    count=0;
    Greedy_Counter=0;
    Max_Greedy_Counter=round(p/2);
    
    Xc=X(:,target);
    while((It_Pays_Off==1 || Greedy_Counter<Max_Greedy_Counter) && count<p)
%     while(It_Pays_Off==1 && count<p)
        
        count=count+1;
        Greedy_Counter=Greedy_Counter+1;
        trigger=TS_Costs(2,count);
        
        if(trigger==target)
            Greedy_Counter=Greedy_Counter-1;
            continue;
        else
            
            %             Xc = [Xc,X_target(:,trigger)];
            Xc = [Xc,X(:,trigger)];
            PHI_Xc=InfoMatrix(Xc,lag);
            
            %     calculate the coding cost of the coefficients
            GLM_Model_A = glmfit_ITGH(PHI_Xc,t,dist(target));
            
            %     calculate the coding cost of the coefficients
            bhatc=GLM_Model_A.Coefficients.Estimate;
            CoefCost=(length(bhatc)*log2(T) + (p-1)*lag*log2(T));
            
            for TiSe=1:p
                if (TS_Costs(2,TiSe)==target)
                    PredErrorCost0 = TS_Costs(1,TiSe);
                end
            end
            
            %     calculate the prediction coding cost
            PredErrorCost = ComputeErrorCost(GLM_Model_A.Residuals.Raw);
%             PredErrorCost = ErrorCost(GLM_Model_A.Residuals.Raw,dist(target));
            
            TransmitCost = sum(TS_Costs(1,:)) - PredErrorCost0;
            
            MDL_After = CoefCost+PredErrorCost+TransmitCost;
            
            % compression difference
            Delta = MDL_Before - MDL_After;
            
            if(Delta>0)
                MDL_Before=MDL_After;
                Output_adj(target,trigger)=1;
                Greedy_Counter=0;
            else
                It_Pays_Off=0;
                Xc=Xc(:,1:end-1);
                Output_adj(target,trigger)=0;
            end
        end
    end
end

runtime=toc;
disp('ITGH is done .....');
end

