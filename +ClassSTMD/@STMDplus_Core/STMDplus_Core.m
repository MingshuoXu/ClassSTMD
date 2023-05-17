classdef STMDplus_Core < ClassSTMD.DSTMD_Core
    %DSTMD_Core Directional Small Target Motion Detectors
    %
    %	api:
    %	addpath('[the parent folder of ClassSTMD]');
    %	import ClassSTMD.*;
    %	obj = STMDplus_Core();
    %	% full path of ImageName
    %
    %     obj.get_ImageName = ...
    %         @(path0,Imagetitle,Imagetype,NowFrame)...
    %         ['full file name'];
    %
    %	% Set parameters of Small Target Motion Detectors
    %	% obj.Gammakernel_3_Tau = 25;
    %	% ...
    %	obj.Run() % Program started
    %
    %   References:
    %   * H. Wang, J. Peng, X. Zheng, S. Yue, A robust visual system for
    %   small target motion detection against cluttered moving back grounds,
    %   IEEE Transactions on Neural Networks and Learning Systems 31 (3)
    %   (2020) 839–853.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-29
    
    properties
        W_T_FilterNum = 4; % 方向对比度的方向个数
        Detection_Threshold = 0.01; % 聚类的阈值
        DBSCAN_len = 100; % 聚类的轨迹长度
        DBSCAN_Distance = 5; % 聚类的空间距离
        SD_Threshold = 15; % 标准差的阈值
    end
    properties(Hidden)
        Contrast_Output;
        W_T;
        TR_index;
        TR = {};
    end
    
    methods
        % Constructor function
        function self = STMDplus_Core()
            self = self@ClassSTMD.DSTMD_Core();
        end
        % Some initialization kernel function
        
        % Initialize function
        function Init(self)
            % Initialization of inherited functions
            Init@ClassSTMD.DSTMD_Core(self);
            
            % init kernel
            self.W_T = ClassSTMD.ToolFun.Generalize_T1_Neural_Kernels(...
                self.W_T_FilterNum);
            
            % allocate memory
            self.Output = zeros(self.IMAGE_H, self.IMAGE_W);
            self.Contrast_Output = zeros(...
                self.IMAGE_H, self.IMAGE_W, self.W_T_FilterNum);
            self.H.Show_Threshold = 0.1;
        end
    end % end methods
    methods % The function body is outside the class function
        Lamina(self);
        Contrast_Pathway(self);
        Mushroom_Body(self);
        Run(self);
    end % end methods
    
    
end

