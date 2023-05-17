%Demo demo for ClassSTMD
clc,clear,close all;
path_pwd = pwd;
addpath(path_pwd(1:end-15));
import ClassSTMD.*;

%% Instantiation
demo_obj = fracSTMD_Core();

%{
basalSTMD_Core
ESTMD_Core DSTMD_Core fracSTMD_Core 
STMDplus_Core apgSTMD_Core
FSTMD_Core feedbackSTMD_Core
%}

%% Set Input and output
demo_obj.Imagetitle = 'DemoImage';
demo_obj.get_ImageName = ...
    @(~,~,~,NowFrame)...
    [path_pwd(1:end-4),'datafolder\\DemoFig',...
    sprintf('%04d',NowFrame),'.tif'];
%{
obj.path0 = 'path0'; % Set the path of the dataset
obj.Imagetitle = 'GeneratingDataSet'; % Image file name
obj.Imagetype = '.tif'; % Image file extension name
obj.get_ImageName = ...
    @(path0,Imagetitle,Imagetype,NowFrame)...
    [path0,'\\',Imagetitle,...
    sprintf('%04d',NowFrame),Imagetype];
%}
demo_obj.IsSaveAsVideo = true; % Is savethe Visualize video
demo_obj.Video_Par = {'.\result', whos('demo_obj').class(11:end-5)};

%% Set parameters
demo_obj.StartFrame = 1; % Start frame, default 1
demo_obj.EndFrame = 300; % End frame, if set to 0, will always run upto stop
demo_obj.SamplingFrequency = 200;
demo_obj.Gammakernel_3_Tau = ...
    demo_obj.Gammakernel_3_Tau * demo_obj.SamplingFrequency /1000;

%{
obj.property = value ; % set the parameter for model
...
%}

%% Visualize handle
% Progress bar: false indicates no display and true indicates display.
demo_obj.IsWaitbar = true; %   The default value is false
demo_obj.Isvisualize = true; % Visualization or not

%% Program started
demo_obj.Run() 




