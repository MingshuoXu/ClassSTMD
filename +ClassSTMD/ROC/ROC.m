function [Detection_rate,False_drop_rate] = ...
        ROC(Input, Index, ...
        GroundTure_SmallTarget_distance,...
        False_drop_rate_max, False_drop_rate_step, ...
        StartFrame, False_drop_rate)
    
    %% init
    if nargin < 2
        error('The number of input parameters is insufficient.');
    end
    if nargin < 3
        GroundTure_SmallTarget_distance = 5;
    end
    if nargin < 4
        False_drop_rate_max = 20;
    end
    if nargin < 5
        False_drop_rate_step = 1;
    end
    if nargin < 6
        StartFrame = 1;
    end
    if nargin < 7
        min_Fr = mod(False_drop_rate_max, False_drop_rate_step);
        False_drop_rate = min_Fr:False_drop_rate_step:False_drop_rate_max;
    elseif nargin == 7
        False_drop_rate = sort(False_drop_rate);
    else
        error('Too many input parameters');
    end
    if size(Index,2) ~=3
        error('size(Index,2) ~=3');
    end
    
    %% Normalizing and MaxOperation
    [m,n,T] = size(Input);
    Normalizing_Ip = zeros(m,n,T);
    for t = 1:T
        Input_t = Input(:,:,t);
        max_ = max(Input_t(:));
        if max_ ~= 0
            temp_Norm_Input_t = Input_t/max_;%¹éÒ»»¯
            Normalizing_Ip(:,:,t) = ...
                ClassSTMD.MaxOperation(temp_Norm_Input_t,25);%MaxOperation
        end
    end
    
    %% Dr-Fr
    Threshold = 1;
    Detection_rate = zeros(size(False_drop_rate)) ;
    for jj = 1:size(False_drop_rate,2)
        [ Detection_rate(jj), False_drop_rate(jj), Threshold ] = ...
            ClassSTMD.ROC.subROC(Normalizing_Ip, Index, GroundTure_SmallTarget_distance,...
            StartFrame, False_drop_rate(jj), Threshold );
    end
    if min_Fr ~= 0
        False_drop_rate = [0,False_drop_rate];
        [ Dr_0, ~, ~ ] = ...
            ClassSTMD.ROC.subROC(Normalizing_Ip, Index, GroundTure_SmallTarget_distance,...
            StartFrame, [], 1, 1);
        Detection_rate = [Dr_0, Detection_rate];
    end
    
    
end










