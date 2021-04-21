clear all;
close all;
clc;

meanTable=zeros(1,4);
ComparingTable= zeros(1,6);
Lag=2;
Max_Constant = 1;
Max_lambda =4;
Max_iteration=50;
count=1;
strength=0.8;
Features=4;
proportion = 0.7;

for traning_data_size=1000:1000:10000
    
    I_n=[];
    I_g=[round(Features*proportion)+1:Features];
    I_p=[1:round(Features*proportion)];
    I_B=[];
    
    dependency=round(Features/1.5);
    
    for itr=1:Max_iteration
        
        Filename = strcat( 'ITGH_Length',num2str(traning_data_size),'_70Poisson_30Gamma');
        
        [series, Ground_Truth]= finalDataGenerator(traning_data_size,Max_Constant,Features,I_n,I_p,I_g,...
            I_B,strength,dependency,strcat(Filename,'_',num2str(itr)),Lag);
        
        disp(strcat('data size = ',num2str(traning_data_size)));
        disp(strcat('Itr = ',num2str(itr)));
        
        Load_File=strcat(strcat('Synthetic Data/',Filename,'_',num2str(itr)),'.mat');
        a = load(Load_File);
        
        series = a.series;
        [N,T1]=size(series);
        
        Max_Constant = 1;
        I_p=a.I_p;
        I_B=a.I_B;
        I_n=a.I_n;
        I_g=a.I_g;
        
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
            for L=Min_Lag:Max_Lag
                disp(strcat('Lag = ',num2str(L)));
                [Output_adj_ITGH,ITGH_runtime]=ITGHGreedy(series(:,:),L);
                
                F_measure_ITGH=Fmeasure(Output_adj_ITGH,Ground_Truth);
                
                ComparingTable(count,:)= [itr traning_data_size strength L F_measure_ITGH ITGH_runtime];
                
                count=count+1;
            end
        end
        
        LagDiff = Max_Lag-Min_Lag;
        mean_F_measure_ITGH = mean (ComparingTable(count-LagDiff:count-1,5));
        mean_Runtime_ITGH=  mean (ComparingTable(count-LagDiff:count-1,6));
        meanTable((traning_data_size/1000-1)*Max_iteration+itr,:)= [itr traning_data_size mean_F_measure_ITGH mean_Runtime_ITGH];
        FinalResult = strcat('Synthetic Results/',Filename);
        Mean_FinalResult = strcat(FinalResult,'_mean');
        save([FinalResult  '_Result.mat']);
        xlswrite([FinalResult '_Result.xlsx'],ComparingTable,1);
        xlswrite([Mean_FinalResult '_Result.xlsx'],meanTable,1);
    end
    
end

