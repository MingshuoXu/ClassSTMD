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
        % size of gauss filter in retina layer
        GaussFilter_SIZE = 3;
        % sigma of gauss filter in retina layer
        GaussFilter_SIGMA = 1;
        % order of ganna kernel in madulla layer to delay the off channel
        Gammakernel_3_Order = 12;
        % time delay paramerer of ganna kernel in madulla layer
        %   to delay the off channel
        Gammakernel_3_Tau = 25;
        % the path of input image sequence
        path0;
        % the Imagetitle of input image sequence
        Imagetitle = 'GeneratingDataSet';
        % the Imagetype of input image sequence
        Imagetype = '.tif';
        % the start frame of model working
        StartFrame = 1;
        % the end frame of model working
        EndFrame = 450;
        % Sampling frequency of the input video
        SamplingFrequency;
        % a parameter about whether to display progress bar
        IsWaitbar = 1;
        % a parameter about whether to visualize the output
        Isvisualize = 0;
        % a parameter about whether to save the visual output as a video
        IsSaveAsVideo = 0;
        % Whether to use a matrix to store the Output of each frame
        IsRecondOutput;
    end
    properties(Hidden)
        % image name
        ImageName;
        % the height of input image
        IMAGE_H;
        % the width of input image
        IMAGE_W;
        % the GaussFilter with size = GaussFilter_SIZE
        %                 and sigma = GaussFilter_SIGMA
        GaussFilter;
        % the effective length of LMCs in convolution
        LMCs_len;
        % the gamma kernel3 used in off delay
        Gammakernel_3;
        % verify that the input image is empty
        InputState = 0;
        % the lateral inhibition kernel in lobula layer
        ESTMD_Lateral_Inhibition_Kernel;
        % current time input matrix
        original_image;
        % current time input matrix
        Input;
        % retina layer output in current time
        Photoreceptors_Output;
        % retina layer output in a period of time
        Matrix_Photoreceptors_Output;
        % lamina layer output in current time
        Lamina_Output;
        % Tm3 cells output of medulla layer in current time
        ON_Channel;
        % Tm2 cells output of medulla layer in current time
        OFF_Channel;
        % Tm3 cells output of medulla layer in a period of time
        Matrix_ON_Channel;
        % Tm2 cells output of medulla layer in a period of time
        Matrix_OFF_Channel;
        % Tm1 cells output of medulla layer in current time
        Delay_OFF_Channel;
        % output of multiply Tm3 cells by Tm1 cells
        Correlation_Output;
        % The output obtained by lateral suppression of Correlation_Output
        Lateral_Inhibition_Output;
        % output of lobula layer in current time, ...
        %   the positive part of the Lateral_Inhibition_Output
        Lobula_Output;
        % output of lobula layer in a period of time
        Matrix_Output;
        % the direction in a period of time
        Matrix_Direction;
        % the effective length of Tm2 cells delay in convolution
        Gammakernel_3_len;
        % record data parameters for debugging
        IsRecord = 0;
        % the current number of frames
        NowFrame = 1;
        % the par of video {save path, save name}
        Video_Par = {'C:\Users\HP\Desktop','test'};
        % the object of the visualized class
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
        % The direction of movement of the small target
        Direction;
    end
    
    methods
        % Constructor function
        function self = basalSTMD_Core()
        end
        % Some initialization kernel function
        function init_GaussFilter(self)
            % initialize the GaussFilter of retina layer
            self.GaussFilter = fspecial('gaussian',...
                self.GaussFilter_SIZE,...
                self.GaussFilter_SIGMA);
        end
        function init_Gammakernel_3(self)
            % initialize the Gammakernel3 of medulla layer
            self.Gammakernel_3 = ClassSTMD.ToolFun.Generalize_Gammakernel(...
                self.Gammakernel_3_Order,...
                self.Gammakernel_3_Tau,...
                self.Gammakernel_3_len);
        end
    end
    methods % The function body is outside the class function
        Init(self) % Initialize function
        Read_Image2gray(self); % Accept input and perform RGB binarization
        Retina(self); % retina layer
        Lamina(self); % lamina layer
        Medulla(self); % medulla layer
        Lobula(self); % lobula layer
        RecondOutput(self) % recond output
        Visualize(self) % visualization
        Run(self); % start function of small target motion detector
    end
    
end

