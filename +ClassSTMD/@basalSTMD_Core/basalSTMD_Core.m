classdef basalSTMD_Core < handle
    %basalESTMD_Core  base Small Target Motion Detectors
    %
    %    api:
    %    addpath('[the parent folder of ClassSTMD]');
    %    import ClassSTMD.*;
    %    obj = basalSTMD_Core();
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
    %   * Q. Fu, H. Wang, C. Hu, S. Yue, Towards computational models
    %   and applications of insect visual systems for motion perception:
    %   A review, Artificial life 25 (3) (2019) 263¨C311.
    %
    %   Author: Mingshuo Xu
    %   Date: 2022-01-10
    %   LastEditTime: 2022-08-11  
    
    properties
        % Size of gauss filter in retina layer
        GaussFilter_SIZE = 3;
        % Sigma of gauss filter in retina layer
        GaussFilter_SIGMA = 1;
        % Order of gamma kernel in madulla layer to delay the off channel
        Gammakernel_3_Order = 12;
        % Time delay paramerer of ganna kernel in madulla layer
        %   to delay the off channel
        Gammakernel_3_Tau = 25;
        % The path of input image sequence
        path0;
        % The Imagetitle of input image sequence
        Imagetitle = 'GeneratingDataSet';
        % The Imagetype of input image sequence
        Imagetype = '.tif';
        % The start frame of model working
        StartFrame = 1;
        % The end frame of model working
        EndFrame = 450;
        % Sampling frequency of the input video
        SamplingFrequency = -1;
        % A parameter about whether to display progress bar
        IsWaitbar = true;
        % A parameter about whether to visualize the output
        Isvisualize = false;
        % A parameter about whether to save the visual output as a video
        IsSaveAsVideo = false;
        % Whether to use a matrix to store the output of each frame
        IsRecordOutput = false;
    end
    properties(Hidden)
        % Image name
        ImageName;
        % The height of input image
        IMAGE_H;
        % The width of input image
        IMAGE_W;
        % The GaussFilter with size = GaussFilter_SIZE
        %                 and sigma = GaussFilter_SIGMA
        GaussFilter;
        % The effective length of LMCs in convolution
        LMCs_len;
        % The gamma kernel3 used in off delay
        Gammakernel_3;
        % Verify that the input image is empty
        InputState = 0;
        % The lateral inhibition kernel in lobula layer
        InhibitionKernel_W2;
        % Current time input matrix
        original_image;
        % Current time input matrix
        Input;
        % Retina layer output in current time
        Photoreceptors_Output;
        % Retina layer output in a period of time
        Cell_Photoreceptors_Output;
        % Lamina layer output in current time
        Lamina_Output;
        % Tm3 cells output of medulla layer in current time
        ON_Channel;
        % Tm2 cells output of medulla layer in current time
        OFF_Channel;
        % Tm3 cells output of medulla layer in a period of time
        Cell_ON_Channel;
        % Tm2 cells output of medulla layer in a period of time
        Cell_OFF_Channel;
        % Tm1 cells output of medulla layer in current time
        Delay_OFF_Channel;
        % Output of multiply Tm3 cells by Tm1 cells
        Correlation_Output;
        % The output obtained by lateral suppression of Correlation_Output
        Lateral_Inhibition_Output;
        % Output of lobula layer in current time, ...
        %   the positive part of the Lateral_Inhibition_Output
        Lobula_Output;
        % Output of lobula layer in a period of time
        Cell_Output;
        % The direction of movement of the small target
        Direction;
        % The direction in a period of time
        Cell_Direction;
        % The output matrix in current time
        Output;
        % The effective length of Tm2 cells delay in convolution
        Gammakernel_3_len;
        % If record data parameters for debugging
        IsRecord = false;
        % The current number of frames
        NowFrame = 1;
        % The par of video {save path, save name}
        Video_Par = {'C:\Users\HP\Desktop','test'};
        % The object of the visualized class
        H;
        % A function to customize the format of the file name for input
        % The input and output of the function are as follows:
        % ImageName = get_ImageName(...
        %    self.path0,...
        %    self.Imagetitle,...
        %    self.Imagetype,...
        %    self.NowFrame);
        get_ImageName;
        % A parameter controls the truncation threshold in the visualization
        visualize_Threshold;
        % If open the menubar and toolbar in figure handle
        IsTestPatterinVisualization = false;
    end
    properties(Access = protected, Hidden)
        HalfWaveR = @(x)ClassSTMD.Half_Wave_Rectification(x);
    end
    
    methods
        % Constructor function
        function self = basalSTMD_Core()
        end
        % Some initialization kernel function
        function init_GaussFilter(self)
            % Initialize the GaussFilter of retina layer
            self.GaussFilter = fspecial('gaussian',...
                self.GaussFilter_SIZE,...
                self.GaussFilter_SIGMA);
        end
        function init_Gammakernel_3(self)
            % Initialize the Gammakernel3 of medulla layer
            self.Gammakernel_3 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_3_Order,...
                self.Gammakernel_3_Tau,...
                self.Gammakernel_3_len);
        end
    end
    methods % The function body is outside the class function
        Init(self); % Initialize function
        getImageName(self); % Set the name format of the image
        Read_Image2gray(self); % Accept input and perform RGB binarization
        Retina(self); % Tetina layer
        Lamina(self); % Lamina layer
        Medulla(self); % Medulla layer
        Lobula(self); % Lobula layer
        RecordOutput(self); % Record output
        Visualize(self); % Visualization
        Run(self); % Start function of small target motion detector
    end
    
end

