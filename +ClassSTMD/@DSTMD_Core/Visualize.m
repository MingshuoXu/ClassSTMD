function Visualize(self)
    % visualize the output
    Output = max(self.Lobula_Output, [], 3);
    self.H.show_STMD(...
        self.NowFrame, self.original_image, Output, self.Direction);
end