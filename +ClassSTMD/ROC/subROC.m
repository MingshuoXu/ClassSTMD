function [ Dr, Frd, threshold_value ] = subROC( ...
        Normalizing,	...
        Index,        	...
        r,             	...
        StartFrame,    	...
        Fr,            	...
        Threshold_max, 	...
        Threshold_min  	)
    %SUBROC 此处显示有关此函数的摘要
    %   此处显示详细说明
    
    %% init
    if nargin < 2
        error('The number of input parameters is insufficient.');
    end
    if size(Index,2) ~=3
        error('size(Index,2) ~=3');
    end
    if nargin < 3
        r = 5;
    end
    if nargin < 4
        StartFrame = 1;
    end
    if nargin < 5
        Fr = 1;
    end
    if nargin < 6
        Threshold_max = 1;
    end
    if nargin < 7
        Threshold_min = 0;
    end

    
    [m,n,T] = size(Normalizing);

    threshold_value = (Threshold_max + Threshold_min)/2;
    if isempty(Fr) % Fr == []
        threshold_value_old = threshold_value; 
        Fr = 0; % 这一步是为了确保下面的break判断条件不会报错
    else 
        threshold_value_old = -1;
    end
    
    %%
    while 1    
        threshold_Ip = Normalizing;
        threshold_Ip(threshold_Ip<threshold_value)  = 0;%阈值截断
        
        number_of_true_detections = 0;
        number_of_actual_target = 0;
        number_of_false_detection = 0;
        number_of_image = T;
        
        s = 1;
        while Index(s,1) < StartFrame
            s = s + 1;
        end
        
        for t = 1:T
            while t == Index(s,1) - StartFrame + 1
                index_x = round(Index(s,2));
                index_y = round(Index(s,3));
                
                s = s + 1;
                
                if index_x * index_y == 0
                    number_of_image = number_of_image - 1;
                    continue;
                end
                
                temp = threshold_Ip(:,:,t);
                detection_number = sum(sum(temp > 0));
                number_of_actual_target = number_of_actual_target + 1;
                
                temp_slice = temp( ...
                    max(index_x-r,1):min(index_x+r,m),  ...
                    max(index_y-r,1):min(index_y+r,n)   );
                
                if ~any(temp_slice(:)) % There is no response around Ground True
                    number_of_false_detection = number_of_false_detection + detection_number;
                else
                    number_of_true_detections = number_of_true_detections + 1;
                    number_of_false_detection = number_of_false_detection + detection_number - 1;
                end
                
            end % end while
        end % end for
        Dr = number_of_true_detections / number_of_actual_target;
        Frd = number_of_false_detection / number_of_image;
        
        if abs(Frd - Fr) < 0.05 || abs(threshold_value - threshold_value_old) < 1e-7
            break;
        else
            if Frd < Fr
                Threshold_max = threshold_value;
            else
                Threshold_min = threshold_value;
            end
            threshold_value_old = threshold_value;
            threshold_value = (Threshold_max + Threshold_min)/2;
        end
        
    end % end while
end