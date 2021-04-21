clear all;
close all;
clc;

warning off;

meanTable=zeros(1,4);
ComparingTable= zeros(1,6);

Max_Constant = 1;
Max_lambda =4;
Max_iteration=50;
count=1;
strength=0.8;
traning_data_size=1000;
proportion = 0.7;

for Features=5:1:5
 
    I_n=[];
    I_g=[round(Features*proportion)+1:Features];
    I_p=[1:round(Features*proportion)];
    I_B=[];
    
    dependency=round(Features/1.5);
    
    for itr=1:Max_iteration
        
        Filename = strcat( 'ITGH_', num2str(70),'Poisson_',num2str(30),'Gamma_');
        [series, Ground_Truth]= finalDataGenerator(traning_data_size,Max_Constant,Features,I_n,I_p,I_g,...
            I_B,strength,dependency,strcat(Filename,num2str(itr)),2);
        
        disp(strcat('Itr = ',num2str(itr)));
        
        Load_File=strcat(strcat('Synthetic Data/',Filename,num2str(itr)),'.mat');
        a = load(Load_File);
        
        series = a.series;
        [N,T1]=size(series);
        
        Max_Constant = 1;
        I_p=a.I_p;
        I_B=a.I_B;
        I_n=a.I_n;
        I_g=a.I_g;
        
        
        % set lag
        Max_Lag = 10;
        Min_Lag=2;
        
        %% Ground Truth:
        
        Ground_Truth=a.coef;
        for i=1:N
            for j=1:N
                
                if(Ground_Truth(i,j)>0)
                    Ground_Truth(i,j)=1;
                else
                    Ground_Truth(i,j)=0;
                end
            end
        end
              
        for Constant=1:Max_Constant
            for L=2:Max_Lag
                disp(strcat('Lag = ',num2str(L)));
                                
                dist=zeros(N,1);
                series=[dist,series];
                for index_i=1:size(series,1)
                    if ismember(index_i,I_n)
                        series(index_i,1)=1;
                    end
                    if ismember(index_i,I_p)
                        series(index_i,1)=2;
                    end
                    if ismember(index_i,I_g)
                        series(index_i,1)=3;
                    end
                    if ismember(index_i,I_B)
                        series(index_i,1)=4;
                    end
                end
                               
                [Output_adj_ITGH,ITGH_runtime]=ITGHGreedy(series(:,:),L);
                
                F_measure_ITGH=Fmeasure(Output_adj_ITGH,Ground_Truth);
                
                ComparingTable(count,:)= [itr Features dependency L F_measure_ITGH ITGH_runtime];
                count=count+1;
            end
        end
        diff=Max_Lag-Min_Lag;
        if diff==0
            meanTable(itr,:)= [itr strength F_measure_ITGH ITGH_runtime];
        else
            mean_F_measure_ITGH = mean (ComparingTable(count-diff:count-1,5));
            mean_Runtime_ITGH=  mean (ComparingTable(count-diff:count-1,6));
            meanTable(itr,:)= [itr strength mean_F_measure_ITGH mean_Runtime_ITGH];
        end
        
        FinalResult = strcat('Synthetic Results/',Filename);
        Mean_FinalResult = strcat( FinalResult,'_mean');
        save([FinalResult  '_Result.mat']);
        xlswrite([FinalResult '_Result.xlsx'],ComparingTable,1);
    end
    
end

