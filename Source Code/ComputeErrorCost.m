function PredictionError = ComputeErrorCost(error)


    [phat]= mle(error,'distribution','normal');
    
    PredictionError=0;
    
    for i=1:length(error)
        PredictionError= PredictionError - log2(normpdf(error(i),phat(1),phat(2)));
    end

% if (Dis==1)
%     % normal
%     [phat]= mle(error,'distribution','normal');
%     
%     PredictionError=0;
%     
%     for i=1:length(error)
%         PredictionError= PredictionError - log2(normpdf(error(i),phat(1),phat(2)));
%     end
% end
% 
% if (Dis==2)
%     % normal
%     [phat]= mle(error,'distribution','poisson');
%     
%     PredictionError=0;
%     
%     for i=1:length(error)
%         PredictionError= PredictionError - log2(poisspdf(error(i),phat(1)));
%     end
% end