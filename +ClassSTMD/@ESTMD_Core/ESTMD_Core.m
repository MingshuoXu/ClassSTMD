classdef ESTMD_Core < ClassSTMD.basalSTMD_Core
    %ESTMD_Core Elementary Small Target Motion Detectors
    %
    %    api:
    %    addpath('[the parent folder of ClassSTMD]');
    %    import ClassSTMD.*;
    %    obj = ESTMD_Core();
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
    %   * S. D. Wiederman, P. A. Shoemarker, D. C. O¡¯Carroll, A model
    %   for the detection of moving targets in visual clutter inspired by
    %   insect physiology, PLoS ONE 3 (7) (2008) e2784¨C.
    %   * Wang H, Peng J, Yue S. A directionally selective small target
    %   motion detecting visual neural network in cluttered backgrounds[J].
    %   IEEE transactions on cybernetics, 2018, 50(4): 1541-1555.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11  
    
    properties
        Gammakernel_1_Order = 2;
        Gammakernel_1_Tau = 3;
        Gammakernel_2_Order = 6;
        Gammakernel_2_Tau = 9;
    end
    properties(Hidden)
        Gammakernel_1_len;
        Gammakernel_2_len;
        Gammakernel_1;
        Gammakernel_2;
        GammaFun1_Output;
        GammaFun2_Output;
    end
    
    methods
        % Constructor function
        function self = ESTMD_Core()
            self = self@ClassSTMD.basalSTMD_Core();
        end
        
        % Some initialization kernel function
        function init_Gammakernel_1_2(self)
            self.Gammakernel_1 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_1_Order,...
                self.Gammakernel_1_Tau,...
                self.Gammakernel_1_len );
            self.Gammakernel_2 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_2_Order,...
                self.Gammakernel_2_Tau,...
                self.Gammakernel_2_len);
        end
        % Initialize function
        function Init(self)
            % weakly dependent variable
            if isempty(self.Gammakernel_1_len)
                self.Gammakernel_1_len = 3 * ceil(self.Gammakernel_1_Tau);
            end
            if isempty(self.Gammakernel_2_len)
                self.Gammakernel_2_len = 3 * ceil(self.Gammakernel_2_Tau);
            end
            if isempty(self.LMCs_len)
                self.LMCs_len = max(self.Gammakernel_1_len,self.Gammakernel_2_len);
            end
            % init kernel
            self.init_Gammakernel_1_2();
            % Initialization of inherited functions
            Init@ClassSTMD.basalSTMD_Core(self);
            self.ESTMD_Lateral_Inhibition_Kernel = ...
                ClassSTMD.ToolFun.Generalize_ESTMD_Lateral_InhibitionKernel(...
                15, 1.5, 3, 1.5, 0, 1, 3);
        end
        
    end
    methods % The function body is outside the class function
        Lamina(self); % lamina layer
    end
end


