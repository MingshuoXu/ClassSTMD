function Mushroom_Body(self)
    %Mushroom_Body Mushroom_Body in (STMD+)
    %   此处显示详细说明
    
    max_Lobula_Output = max(self.Lobula_Output,[],3);
    max_Lobula_Output = ClassSTMD.NMS(max_Lobula_Output, 15);
    index__ = repmat((max_Lobula_Output==0), [1,1,self.DSTMD_Directions]);
    self.Lobula_Output(index__) = 0;
    max_ = max(max_Lobula_Output(:));
    
    if max_
        max_Lobula_Output = max_Lobula_Output ./ max_;
    else
        return;
    end
    
    [index_x, index_y] = find(max_Lobula_Output > self.Detection_Threshold);
    index = [index_x,index_y];

    state_index    = false(size(index,1),1);
    state_TR_index = false(size(self.TR_index,1),1);
    if ~isempty(self.TR_index)
        DD = pdist2(self.TR_index, index);
       
        [D1,ind1] = min(DD,[],2);
        
        for ii = 1:length(D1)
            if D1(ii) <= self.DBSCAN_Distance
                j = ind1(ii);
                self.TR_index(ii,:) = index(j,:);
                state_TR_index(ii) = true;
                state_index(j) = true;
                self.TR{ii} = [self.TR{ii}, ...
                    squeeze(self.Contrast_Output(index(j,1),index(j,2),:)) ];
            end
        end
        jj_ = find(~state_TR_index);
        self.TR_index(jj_,:) = [];
        self.TR(jj_) = [];
        
    end
    
    EffectiveTrajectories_Num = length(self.TR);
    kk_ = find(~state_index);
    for kk = kk_'
        self.TR_index(end+1,:) = index(kk,:);
        self.TR{end+1} = squeeze( ...
            self.Contrast_Output(index(kk,1),index(kk,2),:) ) ;
    end
    
    %% Information Integration
    for i = 1:length(self.TR) % or EffectiveTrajectories_Num?
        if size(self.TR{i},2) > self.DBSCAN_len
            self.TR{i} = self.TR{i}(:,2:end);
            % The code above runs faster than follow
            % self.TR{i}(:,1) = [];
        end
        if max( std(self.TR{i}, 0, 2) ) < self.SD_Threshold
            self.Lobula_Output(self.TR_index(i,1),self.TR_index(i,2),:) = 0;
        end
    end
    self.Output = max(self.Lobula_Output,[],3);
    
end

