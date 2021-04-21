function [series,coef] = final_dataGenerator(traning_data_size,Constant,numOfTS, I_n, I_p,I_g,I_B,strength,Dep,Fname,lag)

%     for strength=0.2:0.1:0.9
for strength=strength:0.1:strength
    %     for strength=0.4:0.1:0.4
    %         for dependency=round(numOfTS/2):1:round(numOfTS*2)
    for dependency=Dep:1:Dep
        
                clc;
        % traning_data_size=1000; Constant=1;
        
        %             I_n=[1,2]; I_p=[3,4];
        
        numOfTS= size(I_n,2)+size(I_p,2)+size(I_g,2)+ size(I_B,2);
        %             proportion= size(I_n,2)/numOfTS;
        %             Filename = strcat( 'NewSynthetic_', num2str(proportion),'_Proportion.mat');
        Filename = strcat('Synthetic Data/',Fname);
        
        series = zeros(numOfTS,traning_data_size,Constant);
        Mean_training_file = zeros(numOfTS,traning_data_size,Constant);
        series(1,1,1)=inf;
        ISEMPTY=isempty(find(isinf(series))>0);
        ISBIG = 101;
        flag=1;
        % Generae random coefficients regarding mean value equations
        %               e.g. mean(t+1)= coeff_1*x_1 + coeff_2*x_2 + ....
        coef = zeros(numOfTS,numOfTS);
        
        %             while(ISEMPTY==0 || nnz(coef)~=dependency)
        while(ISEMPTY==0 || ISBIG>100 || flag==1)
            %             clc;
            
            %     Generate random values for sigma corresponding to any normal
            %     time series
            sigma_value=rand(1,numOfTS)*10+5;
            
            %Set the parameters for a gamma time series
            Shape=2+(3-2)*rand(1,numOfTS);
            
            %     coef = (1).*rand(numOfTS,numOfTS) -0.5;
            
            ISReflexive=1;
            coef = zeros(numOfTS,numOfTS);
            diagonal=1:numOfTS+1:numel(coef);
            
            while(ISReflexive==1)
                ISReflexive=0;
                indices=randperm(numOfTS*numOfTS,dependency);
                for index_i=1:dependency
                    if ismember(indices(index_i),diagonal)
                        ISReflexive=1;
                    end
                end
            end
            
            
            for index=1:numOfTS*numOfTS
                if ismember(index, indices)==1
                    coef(index)= strength + (0.1).*rand(1,1);
                end
            end
            
            %          coef=[0,0,0,0,0,0,0;0.3,0,0,0,0.3,0,0;0.3,0,0,0,0,0,0;0.3,0,0,0.3,0,0,0;0.3,0,0,0.3,0,0,0;0.3,0,0,0,0,0.3,0;0.3,0,0.3,0,0.3,0,0];
            %                 for row=1:numOfTS
            %                     for colm=1:numOfTS
            % %                         flag=(10)*rand -5;
            % %                         if(flag>2)
            % %                             coef(row,colm)= strength + (0.1).*rand(1,1);
            % %                         else
            % %                             coef(row,colm)=0;
            % %                         end
            %
            %                     end
            %                 end
            
            
            itr=0;
            
            for count=1:1:Constant
                
                itr=itr+1;
                
                for TS=1:numOfTS
                    
                    if ismember(TS, I_n)==1
                        series(TS,1,itr)=0;
                        while(series(TS,1,itr)<=0)
                            series(TS,1,itr)= randn;
                        end
                        while(series(TS,2,itr)<=0)
                            series(TS,2,itr)= randn;
                        end
                        while(series(TS,3,itr)<=0)
                            series(TS,3,itr)= randn;
                        end
                    end
                    
                    if ismember(TS, I_p)==1
                        for L=1:lag
                            series(TS,L,itr)= poissrnd(TS);
                        end
                    end
                    
                    if ismember(TS, I_B)==1
                        for L=1:lag
                        series(TS,L,itr)= binornd(1,0.5);
                        end
                    end
                    
                    if ismember(TS, I_g)==1
                        for L=1:lag
                        series(TS,L,itr)=0;
                        while(series(TS,L,itr)<=0 )
                            series(TS,L,itr)= randn;
                        end
                        end
                    end
                    
                    for L=1:lag
                        Mean_training_file(TS,L,itr)= series(TS,L,itr);
                    end
                end
                
                flag=0;
                for i=L+1:traning_data_size
                    if(flag==1)
                        break;
                    end
                    for j=1:numOfTS
                        
                        Mean_training_file(j,i,itr)=count;
                        
                        if ismember(j, I_p)==1
                            Mean_training_file(j,i,itr) = count/20;
                        end
                        
                        for k=1:numOfTS
                            if(coef(j,k)>0)
                                Mean_training_file(j,i,itr)= Mean_training_file(j,i,itr)+coef(j,k)*series(k,i-L,itr);
                            end
                        end
                        
                        if ismember(j, I_p)==1
                            Mean_training_file(j,i,itr) = exp(Mean_training_file(j,i,itr));
                        end
                        
                        if ismember(j, I_B)==1
                            Mean_training_file(j,i,itr) = exp(Mean_training_file(j,i,itr))...
                                /(1+exp(Mean_training_file(j,i,itr)));
                        end
                        
                        if ismember(j, I_g)==1
                            Mean_training_file(j,i,itr) = 1/(Mean_training_file(j,i,itr));
                        end
                        
                        
                        if ismember(j, I_n)==1
                            series(j,i,itr)=0;
                            while (isnan(series(j,i,itr)) || series(j,i,itr)<=0)
                                series(j,i,itr)= Mean_training_file(j,i,itr)*randn + sigma_value(1,j);
                            end
                        end
                        
                        if ismember(j, I_p)==1
                            series(j,i,itr)=0;
                            while (series(j,i,itr)==0 )
                                series(j,i,itr)= poissrnd(Mean_training_file(j,i,itr));
                            end
                        end
                        
                        if ismember(j, I_B)==1
                            series(j,i,itr)= binornd(1,Mean_training_file(j,i,itr));
                        end
                        
                        if ismember(j, I_g)==1
                            if(Mean_training_file(j,i,itr)==0)
                                flag=1;
                                break;
                            end
                            series(j,i,itr)=0;
                            while (series(j,i,itr)==0 || isnan(series(j,i,itr)))
                                series(j,i,itr)= gamrnd(Shape(1,j),Mean_training_file(j,i,itr)/Shape(1,j));
                            end
                        end
                        
                    end
                    
                end
                %         disp(series(:,:,itr));
            end
            ISEMPTY=isempty(find(isinf(series))>0);
            ISBIG = max(max(series));
            
            %     disp(series());
            %                 save(Filename);
        end
        
%         for i=1:numOfTS
%             subplot(numOfTS,1,i);
%             figure();
%             hist(series(i,:));
%             plot(series(i,:));
%             MIN=min(series(i,:));
%             MAX=max(series(i,:));
%             for j=1:length(series(i,:))
%                 
%                 series(i,j)= (series(i,j)-MIN)/(MAX-MIN)*10;
%                 
%                 if ismember(i,I_p)
%                     series(i,j)= round(series(i,j));
%                 end
%                 
%                 if ismember(i,I_B)
%                     series(i,j)= series(i,j)-10;
%                 end
%                 
%                 if ismember(i,I_g)
%                     series(i,j)= series(i,j)+10.1;
%                 end
%                
%             end
            
%             figure();
%             plot(series(i,:));
%             hist(series(i,:));
            
%         end
        
        
        save(Filename);
        %             disp(series());
        
        
        fileID = fopen(strcat('Synthetic Data/',Fname,'.txt'),'w');
        formatSpec='';
        first_line='';
        for i=1:numOfTS
            if ismember(i,I_n)
                %         series(i,1)=1;
                formatSpec= strcat(formatSpec,'%f\t');
                first_line = strcat(first_line,'n');
            end
            
            if ismember(i,I_p)
                %         series(index_i,1)=2;
                formatSpec= strcat(formatSpec,'%f\t');
                first_line = strcat(first_line,'i');
            end
            if ismember(i,I_g)
                %         series(index_i,1)=3;
                formatSpec=strcat(formatSpec,'%f\t');
                first_line = strcat(first_line,'n');
            end
            if ismember(i,I_B)
                %         series(index_i,1)=4;
                formatSpec= strcat(formatSpec,'%f\t');
                first_line = strcat(first_line,'b');
            end
            
            if i<numOfTS
                first_line = strcat(first_line,'\t');
            else
                first_line = strcat(first_line,'\n');
            end
        end
        formatSpec=strcat(formatSpec,'\n');
        fprintf(fileID,first_line);
        fprintf(fileID,formatSpec,series);
        fclose(fileID);
    end
end