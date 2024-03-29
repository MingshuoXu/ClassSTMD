function getImageName(self)
    %getImageName set the name format of the image
    %
    % You can set the name format of the image to read through the handle
    % function, such as:
    %     obj.get_ImageName = ...
    %         @(path0,Imagetitle,Imagetype,NowFrame)...
    %         [path0,'\\',Imagetitle,...
    %         sprintf('%04d',NowFrame),Imagetype];
    % 
    % For real-time detection, you can set EndFrame to 0 and set the image 
    % name to fixed, which means they have nothing to do with NowFrame,
    % such as:
    %     obj.EndFrame = 0;
    %     obj.get_ImageName = ...
    %         @(path0,Imagetitle,Imagetype,NowFrame)...
    %         [path0,'\\',Imagetitle,Imagetype];
    %
    % The above 'obj' represents the instantiation object of the class
    
    if isempty(self.get_ImageName)
        self.ImageName = [self.path0,'\\',...
            self.Imagetitle,sprintf('%04d',self.NowFrame),self.Imagetype];
    else
        self.ImageName = self.get_ImageName(...
            self.path0,...
            self.Imagetitle,...
            self.Imagetype,...
            self.NowFrame);
    end
end

