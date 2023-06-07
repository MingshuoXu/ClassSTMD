classdef fracSTMD_Core < ClassSTMD.basalSTMD_Core
    %fracSTMD_Core Fractional-order Small Target Motion Detectors
    %
    %    api:
    %    addpath('[the parent folder of ClassSTMD]');
    %    import ClassSTMD.*;
    %    obj = fracSTMD_Core();
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
    %   * M. Caputo, M. Fabrizio, A new definition of fractional derivative
    %   without singular kernel, Progress in Fractional Differentiation &
    %   Applications 1 (2) (2015) 73¨C85.
    %
    %   Author: Mingshuo Xu
    %   E-mail: mingshuoxu99@gmail.com
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11
    %

    properties
        FractionalDerivative_Order = 0.8;
    end
    properties(Hidden)
        Lamina_cur;
        Lamina_pre;
    end

    methods
        % Constructor function
        function self = fracSTMD_Core()
            self@ClassSTMD.basalSTMD_Core();
            self.Gammakernel_3_Order = 100;
        end

        % Some initialization kernel function
        function init_FractionalDerivativekernel(self)
            while self.SamplingFrequency < 1 || ...
                    isnan(self.SamplingFrequency)
                warning(['Sampling Frequency must be an integer',...
                    ' greater than 1.']);
                Str_Input1 = input('Please input SamplingFrequency: ','s');
                self.SamplingFrequency = str2double(Str_Input1);
            end
            while self.FractionalDerivative_Order > 1 ||...
                    self.FractionalDerivative_Order <= 0 ||...
                    isnan(self.FractionalDerivative_Order)
                warning(['Fractional Difference Order must be',...
                    ' a float in the interval (0,1].']);
                Str_Input2 = input('Please input alpha: ','s');
                self.FractionalDerivative_Order = str2double(Str_Input2);
            end
            
            alpha_ = self.FractionalDerivative_Order;
            fps_ = self.SamplingFrequency;
            self.Lamina_pre = exp( -(1-alpha_)/alpha_ );
            self.Lamina_cur = ( 1-exp(-(1-alpha_)/alpha_) ) / alpha_/fps_;
            %{
            self.Lamina_cur = ...
                ( 1 - exp(-alpha_*self.FD_Integral_Time*fps_/(1-alpha_)) )...
                / alpha_ / fps_; 
            %}
        end

        % Initialize function
        function Init(self)
            % init kernel
            self.init_FractionalDerivativekernel();
            % Initialization of inherited functions
            Init@ClassSTMD.basalSTMD_Core(self);
            self.LMCs_len = 2;
            % Regenerate the inhibitory Kernel
            self.InhibitionKernel_W2 = ...
                ClassSTMD.ToolFun.Generalize_Lateral_InhibitionKernel_W2(...
                15, 1.5, 3, 1.8, 0, 1, 3);
            % Allocate memory
            [self.Cell_Photoreceptors_Output{1},...
                self.Cell_Photoreceptors_Output{2},...
                self.Lamina_Output]...
                = deal(zeros(self.IMAGE_H,self.IMAGE_W));
        end % end Init 

    end % end methods
    methods % The function body is outside the class function
        Lamina(self); % lamina layer
    end % end methods
end

