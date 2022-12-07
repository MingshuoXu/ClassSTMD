function [MaxOperation_Output] = MaxOperation(Input, MaxRegionSize)
    %MaxOperation �ú������ڶ����ͼ����ÿһС�����ڽ��� Max Operation
    
    % Parameter Setting
    % Input : ����ͼ�񣬴�СΪ M*N
    % MaxRegionSize : ���� Max Operation �������СΪ
    %   (2*MaxRegionSize) *(2*MaxRegionSize)
    
    [M,N] = size(Input);
    
    if MaxRegionSize <= 5 && M*N >= 4e4
        %% Method based on convolution idea
        temp = zeros(M,N);
        MaxOperation_Output = Input;
        
        for rr = -MaxRegionSize:MaxRegionSize
            for cc = -MaxRegionSize:MaxRegionSize
                
                rr1 = max(1, 1+rr) : min(M, M+rr);
                cc1 = max(1, 1+cc) : min(N, N+cc);
                rr2 = max(1, 1-rr) : min(M, M-rr);
                cc2 = max(1, 1-cc) : min(N, N-cc);
                
                temp(rr2,cc2) = Input(rr1,cc1);
                MaxOperation_Output(MaxOperation_Output<temp) = 0;
            end % end for
        end % end for
        
    else
        %% greedy-based 
        MaxOperation_Output = zeros(M,N);
        temp_ = Input;
        [MAX_, Index] = max(temp_(:));
        while MAX_ > 1e-5
            [x,y] = ind2sub([M,N], Index);
            MaxOperation_Output(x,y) = Input(x,y);
            
            xx = max(1, x-MaxRegionSize) : min(M, x+MaxRegionSize);
            yy = max(1, y-MaxRegionSize) : min(N, y+MaxRegionSize);
            
            temp_(xx,yy) = 0;
            [MAX_, Index] = max(temp_(:));
        end
        %%
    end % end if
end % EOF