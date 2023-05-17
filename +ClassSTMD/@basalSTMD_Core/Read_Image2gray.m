function Read_Image2gray(self)
    %Read_Image2gray Load input image and perform RGB binarization
    self.getImageName();
    try
        % Load the input image
        self.original_image = imread(self.ImageName); 
        % RGB binarization
        self.Input = double(rgb2gray(self.original_image)); 
        self.InputState = true;
    catch
        self.InputState = false;
        self.EndFrame = self.NowFrame - 1;
        self.Cell_Output(self.NowFrame:end) = [];
    end
end
