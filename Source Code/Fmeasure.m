function f_measure=Fmeasure(Output_adj,Ground_Truth)
                %% Precision and recall
                [N,M]=size(Output_adj);
                same=0;
              
                for i=1:N
                    for j=1:M
                        if(Output_adj(i,j)==1 && Ground_Truth(i,j)==1)
                            same=same+1;
                        end
                    end
                end
                
                %precision
                              
                if (nnz(Output_adj)==0)
                    p=0;
                else
                    p= same/nnz(Output_adj);
                end
                 
                % recall
                
                r= same/nnz(Ground_Truth);
                
                % F-measure
                
                if(p==0 && r==0)
                    f_measure=0;
                else
                    f_measure=(2*p*r)/(p+r);
                end
                
