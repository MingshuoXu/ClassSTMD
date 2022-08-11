function Read_Image2gray(self)
    %Read_Image2gray read input image and perform RGB binarization
    self.getImageName();
    try
        % read input image
        self.original_image = imread(self.ImageName); 
        % RGB binarization
        self.Input = double(rgb2gray(self.original_image)); 
        self.InputState = 1;
    catch
        self.InputState = 0;
        self.EndFrame = self.NowFrame - 1;
        self.Matrix_Output(:,:,self.NowFrame:end) = [];
    end
end
