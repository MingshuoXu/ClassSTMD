function Visualize(self)
    % visualize the output
    self.H.show_STMD(...
        self.NowFrame, self.original_image, self.Output, self.Direction);
end