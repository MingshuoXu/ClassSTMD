function [TP,FN,FP] = ComputeEvaluation(Prediction,...
        P_type,...
        GroundTruth,...
        GT_type,...
        varargin)
    %ComputeEvaluation 
    % P_type    : 'bbox' or 'logic_matrix'
    % GT_type   : 'bbox' or 'center_dots'
    % bbox = [x, y, width, height]
    % Additional optional parameters include:
    % 'ROI_threshold' and 'SpatialDistance_threshold'



    %// Define default values
    ROI_threshold = 0.5;
    SpatialDistance_threshold = 5;
    % Check if there are additional input arguments
    if ~isempty(varargin)
        for i = 1:2:length(varargin) %// Loop through input arguments
            eval([varargin{i},'= varargin{i+1};']);
        end
    end

    TP = 0;
    FN = 0;
    FP = 0;

    if strcmp(P_type,'bbox')
        %%%
        isFP = true(size(Prediction, 1),1);
        for ll = 1:size(GroundTruth, 1)
            isFN = true;
            for kk = 1:size(Prediction, 1)
                if strcmp(GT_type,'bbox')
                    %%%
                    ROI_ = ComputeROI(Prediction(kk,:), GroundTruth(ll,:));
                    isTP =  ROI_ >= ROI_threshold;
                elseif strcmp(GT_type,'center_dots')
                    %%%
                    isTP = Prediction(kk,1)<=GroundTruth(ll,1)...
                        && Prediction(kk,1)+Prediction(kk,3)>=GroundTruth(ll,1)...
                        && Prediction(kk,2)<=GroundTruth(ll,2)...
                        && Prediction(kk,2)+Prediction(kk,3)>=GroundTruth(ll,2);
                end
                if isTP
                    TP = TP + 1;
                    isFN = false;
                    isFP(ll) = false;
                end
            end % endfor
            if isFN
                FN = FN + 1;
            end
        end % endfor
        FP = FP + sum(isFP);

    elseif strcmp(P_type,'logic_matrix')
        %%%
        FP = sum(sum(Prediction>0));
        for ll = 1:size(GroundTruth, 1)
            isTP = Compute_SpatialDistance(...
                Prediction,...
                GroundTruth(ll,:),...
                SpatialDistance_threshold);
            if isTP
                TP = TP + 1;
                FP = FP - 1;
            else
                FN = FN + 1;
            end

        end % endfor

    end

end


function ROI = ComputeROI(rect1, rect2)
    % rect1, rect2: 一个矩形区域，格式为 [x, y, w, h]，其中 x 和 y 为左上角坐标，w 和 h 为宽度和高度

    % 计算两个矩形的交集
    x1 = rect1(1);
    y1 = rect1(2);
    w1 = rect1(3);
    h1 = rect1(4);
    x2 = rect2(1);
    y2 = rect2(2);
    w2 = rect2(3);
    h2 = rect2(4);

    % 确定两个矩形的左上角和右下角坐标
    left = max(x1, x2);
    top = max(y1, y2);
    right = min(x1 + w1, x2 + w2);
    bottom = min(y1 + h1, y2 + h2);

    % 计算交集面积
    if left < right && top < bottom
        area = (right - left) * (bottom - top);
    else
        area = 0;
    end

    % 计算 ROI
    ROI = area / (w1 * h1 + w2 * h2 - area);
end

function isFN_ = Compute_SpatialDistance(...
        Prediction_,...
        GroundTruth_,...
        Spa_Distance_threshold)
    [H,W] = size(Prediction_);
    GroundTruth_ = round(GroundTruth_);
    if size(GroundTruth_,2) == 2
        x1 = max(1,GroundTruth_(1)-Spa_Distance_threshold);
        x2 = min(W,GroundTruth_(1)+Spa_Distance_threshold);
        y1 = max(1,GroundTruth_(2)-Spa_Distance_threshold);
        y2 = min(H,GroundTruth_(2)+Spa_Distance_threshold);
    elseif size(GroundTruth_,2) == 4
        x1 = max(1,GroundTruth_(1)-Spa_Distance_threshold);
        x2 = min(W,GroundTruth_(1)+GroundTruth_(3)+Spa_Distance_threshold);
        y1 = max(1,GroundTruth_(2)-Spa_Distance_threshold);
        y2 = min(H,GroundTruth_(2)+GroundTruth_(4)+Spa_Distance_threshold);
    end
    temp_slice = Prediction_(y1:y2,x1:x2);

    isFN_ = any(temp_slice(:)); % There is no response around Ground True
        
end

