classdef DSTMD_Core < ClassSTMD.ESTMD_Core
    %DSTMD_Core Directional Small Target Motion Detectors
    %
    %    api:
    %    addpath('[the parent folder of ClassSTMD]');
    %    import ClassSTMD.*;
    %    obj = DSTMD_Core();
    %    % full path of ImageName
    %
    %    obj.get_ImageName = ...
    %       @(path0,Imagetitle,Imagetype,NowFrame)...
    %       ['full file name'];
    %
    %    % Set parameters of Small Target Motion Detectors
    %    % obj.Gammakernel_3_Tau = 25; 
    %    % ...
    %    obj.Run() % Program started
    %
    %   References:
    %   * Wang H, Peng J, Yue S. A directionally selective small target
    %   motion detecting visual neural network in cluttered backgrounds[J].
    %   IEEE transactions on cybernetics, 2018, 50(4): 1541-1555.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11 
    
    properties
        Gammakernel_4_Order = 3;
        Gammakernel_4_Tau = 15;
        Gammakernel_5_Order = 5;
        Gammakernel_5_Tau = 25;
        Gammakernel_6_Order = 8;
        Gammakernel_6_Tau = 40;
        DSTMD_Directions = 8;
        DSTMD_Dist = 3;
    end
    properties(Hidden)
        Gammakernel_4_len;
        Gammakernel_5_len;
        Gammakernel_6_len;
        Gammakernel_4;
        Gammakernel_5;
        Gammakernel_6;
        DSTMD_Lateral_Inhibition_Kernel
        DSTMD_Directional_Inhibition_Kernel
        Delay_ON_Channel;
        Delay_OFF_Channel_1;
        Delay_OFF_Channel_2;
    end
    
    methods
        % Constructor function
        function self = DSTMD_Core()
            self = self@ClassSTMD.ESTMD_Core();
        end
        % Some initialization kernel function
        function init_Gammakernel_4_5_6(self)
            self. Gammakernel_4 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_4_Order,...
                self.Gammakernel_4_Tau,...
                self.Gammakernel_4_len);
            self. Gammakernel_5 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_5_Order,...
                self.Gammakernel_5_Tau,...
                self.Gammakernel_5_len);
            self. Gammakernel_6 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_6_Order,...
                self.Gammakernel_6_Tau,...
                self.Gammakernel_6_len);
        end
        % Initialize function
        function Init(self)
            % Initialization of inherited functions
            Init@ClassSTMD.ESTMD_Core(self);
            % weakly dependent variable
            if isempty(self.Gammakernel_4_len)
                self.Gammakernel_4_len = 3 * self.Gammakernel_4_Tau;
            end
            if isempty(self.Gammakernel_5_len)
                self.Gammakernel_5_len = 3 * self.Gammakernel_5_Tau;
            end
            if isempty(self.Gammakernel_6_len)
                self.Gammakernel_6_len = 3 * self.Gammakernel_6_Tau;
            end
            % init kernel
            self.init_Gammakernel_4_5_6();
            self.DSTMD_Lateral_Inhibition_Kernel = ...
                ClassSTMD.ToolFun.Generalize_DSTMD_Lateral_InhibitionKernel();
            self.DSTMD_Directional_Inhibition_Kernel = ...
                ClassSTMD.ToolFun.Generalize_DSTMD_Directional_InhibitionKernel();
            % allocate memory
            self.Matrix_ON_Channel = ...
                zeros(self.IMAGE_H,self.IMAGE_W,self.Gammakernel_4_len);
            self.Matrix_OFF_Channel = ...
                zeros(self.IMAGE_H,self.IMAGE_W,...
                max(self.Gammakernel_5_len,self.Gammakernel_6_len) );
            [self.Correlation_Output,self.Lateral_Inhibition_Output,...
                self.Lobula_Output] = ...
                deal(zeros(self.IMAGE_H,self.IMAGE_W,self.DSTMD_Directions ));
        end
    end % end methods
    methods % The function body is outside the class function
        Lobula(self); % lobula layer
        Visualize(self); 
        RecondOutput(self);
    end % end methods
    
    
end

