clear all;
close all;
clc;

warning off;

comparingTable=zeros(1,3);

% Name of the the real-world data set
Dataset_name='Temperature';

series=csvread( strcat(Dataset_name,'.csv'))';

GT_name=strcat(Dataset_name,'_Solution.txt');
Ground_Truth=load (GT_name);   %Adjacency matrix of the ground truth

% set a random lag less than 5
L = round(4*rand()+1);
[p,N]=size(series);

I_n=[];
I_p=[];
I_g=[];
I_B=[];

for i=1:p
    display(strcat('Time Series',num2str(i)));
    Best_Dist=fitDistribution(series(i,:)',L);
    
    switch Best_Dist
        case 1
            I_n=[I_n,i];
        case 2
            I_p=[I_p,i];
        case 3
            I_g=[I_g,i];
        case 4
            I_B=[I_B,i];            
    end
    
end

dist=zeros(p,1);
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


%% ITGH
[Output_adj_ITGH,ITGH_runtime]=ITGHGreedy(series(:,:),L);

%% F_measure

F_measure_ITGH=Fmeasure(Output_adj_ITGH,Ground_Truth)

comparingTable(1,:)= [L F_measure_ITGH ITGH_runtime];

save([Dataset_name  'Result.mat']);
xlswrite([Dataset_name 'Result.xlsx'],comparingTable,1);

disp('done ....')



