clear all;
close all;
clc;

warning off;

% Name of the the real-world data set
% Dataset_name='Montana';
Dataset_name='Louisiana';

series=csvread( strcat(Dataset_name,'.csv'))';

% set the lag=3 for Louisiana and lag=2 for Montana
L = 3;
[P,N]=size(series);

I_n=[];
I_p=[];
I_g=[];
I_B=[];

dist=zeros(P,1);

for i=1:P
    display(strcat('Time Series',num2str(i)));
    dist(i)=fitDistribution(series(i,:)',1);
end

series=[dist,series];



%% ITGH

[Output_adj_ITGH,ITGH_runtime]=ITGHGreedy(series(:,:),L);

%% Graph

adj=Output_adj_ITGH;

for i=1:11
    for j=1:11
        if(i~=10)
            adj(i,j)=0;
        end
        if(i==j)
            adj(i,j)=0;
        end
    end
end

adj=adj';

label={'CO2','CH4','CO','H2','WET','CLD','VAP','PRE','FRS','TMP','GLO'};

G = digraph(adj,label);
plot(G,'Layout','circle');
title('ITGH');

disp('done ....')



