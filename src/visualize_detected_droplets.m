function [overlay_fullname] = visualize_detected_droplets(im, ...
                                                          strct_image, ...
                                                          droplist, ...
                                                          folderesults)
%% visualize_detected_droplets 
% Create and save an overlay png image of the original brightfield image
% and indexed detected droplets
% 
%   Usage 
% [overlay_fullname] = visualize_detected_droplets(im, strct_image, ...
%                                                  droplist, ...
%                                                  folderesults)
% 
%	INPUT 
% im: brightfield image
% folderesults: folder in which the output image will be saved
% field_number: index of the field of view (string)
% time_number: time point of the field of view (string)
% n_droplets: number of whole droplets in the image
% centers_droplet: matrix (size: n_droplets x 2) of coordinates (x and y, in pixel) of droplet centers
% radii_droplet: vector (length: n_droplets) of droplet radii (in pixel)
% linewidth: line width of the drawn circles in final image
% fontsize: font size of the text in final image
%  
%	OUTPUTS 
% overlay_fullname: full name of the saved png overlay image
% 
%	EXAMPLES
% [overlay_fullname] = visualize_detected_droplets(im, strct_image, ...
%                                                  droplist, ...
%                                                  folderesults)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------
    figure;
        imagesc(im); axis image off; colormap gray;
        viscircles(droplist.centers_droplet, droplist.radii_droplet, 'EdgeColor', 'b', ...
               'LineStyle', '-', 'LineWidth', 1);
        hold on;
        for i_droplet=1:droplist.n_droplets
            text(droplist.centers_droplet(i_droplet,1), ...
                 droplist.centers_droplet(i_droplet,2), ...
                 num2str(i_droplet),'Color','r', ...
                 'FontSize',4);
        end
        title(sprintf('%d detected drops - BF \n',droplist.n_droplets));
        hold off;
    supname=char(strcat('T', strct_image.time_number, '_XY', strct_image.field_number, '_detected_drops_BF'));
    overlay_fullname = fullfile(folderesults,supname);
    print(gcf, overlay_fullname, '-dpng','-r250');
    clf;
    close;
end


