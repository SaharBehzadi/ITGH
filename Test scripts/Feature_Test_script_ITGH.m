clear all;
close all;
clc;

meanTable=zeros(1,4);
ComparingTable= zeros(1,6);

Max_Lag = 10;
Min_Lag=2;
Max_iteration=50;
count=1;
strength=0.8;
traning_data_size=1000;
proportion = 0.7;

for Features=3:2:21
    
    I_n=[];
    I_g=[round(Features*proportion)+1:Features];
    I_p=[1:round(Features*proportion)];
    I_B=[];
    
    dependency=round(Features/1.5);
    
    for itr=1:Max_iteration
        
        Filename = strcat( 'ITGH_Features',num2str(Features),'_Poisson',num2str(size(I_p,2)),...
            '_Gamma',num2str(size(I_g,2)));
        
        [series, Ground_Truth]= finalDataGenerator(traning_data_size,1,Features,I_n,I_p,I_g,...
            I_B,strength,dependency,strcat(Filename,'_',num2str(itr)),Min_Lag);
        
        disp(strcat('Feature = ',num2str(Features)));
        disp(strcat('Itr = ',num2str(itr)));
        
        Load_File=strcat(strcat('Synthetic Data/',Filename,'_',num2str(itr)),'.mat');
        a = load(Load_File);
        
        series = a.series;
        [N,T1]=size(series);
        
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
        
        for L=2:Max_Lag
            disp(strcat('Lag = ',num2str(L)));
            
            %% ITGH
            
            [Output_adj_ITGH,ITGH_runtime]=ITGHGreedy(series(:,:),L);

            %% F_measure
            
            F_measure_ITGH=Fmeasure(Output_adj_ITGH,Ground_Truth);

            ComparingTable(count,:)= [itr strength Features L F_measure_ITGH ITGH_runtime];
            
            count=count+1;
        end
        
        LagDiff = Max_Lag-Min_Lag;
        mean_F_measure_ITGH = mean (ComparingTable(count-LagDiff:count-1,5));
        mean_Runtime_ITGH=  mean (ComparingTable(count-LagDiff:count-1,6));
        meanTable((Features-3)*Max_iteration+itr,:)= [itr Features mean_F_measure_ITGH mean_Runtime_ITGH];
        FinalResult = strcat('Synthetic Results/',Filename);
        Mean_FinalResult = strcat( FinalResult,'_mean');
        save([FinalResult  '_Result.mat']);
        xlswrite([FinalResult '_Result.xlsx'],ComparingTable,1);
        xlswrite([Mean_FinalResult '_Result.xlsx'],meanTable,1);
    end
    
end

