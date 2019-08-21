function [overlay_fullname] = visualize_tracking(im_droplet_ini, im_droplet_ini_ext, ...
                                                 im_droplet_fin, ...
                                                 xoffset, yoffset, ...
                                                 strct_image, ...
                                                 i_droplet_to_track, ...
                                                 extension_pix, csdil, folderesults)
%% visualize_tracking
% Create and save an illustration of tracking procedure between two consecutive time point
% 
%   Usage 
% [overlay_fullname] = visualize_tracking(im_droplet_ini, im_droplet_ini_ext, ...
%                                         im_droplet_fin, ...
%                                         xoffset, yoffset, ...
%                                         strct_image, ...
%                                         i_droplet_to_track, ...
%                                         extension_pix, csdil, folderesults)
% 
%	INPUT 
% im_droplet_ini:
% im_droplet_ini_ext:
% im_droplet_fin:
% xoffset:
% yoffset:
% strct_image: structure containing time_number, field_number, and
%              time_to_track parameters
% i_droplet_to_track: index of the droplet being tracked
% extension_pix: folder in which the output image will be saved
% csdil:
%
% field_number: index of the field of view (string)
% time_number: time point of the field of view (string)
%  
%	OUTPUTS 
% overlay_fullname: full name of the saved png image
% 
%	EXAMPLES
% [overlay_fullname] = visualize_tracking(im_droplet_ini, im_droplet_ini_ext, ...
%                                         im_droplet_fin, ...
%                                         xoffset, yoffset, ...
%                                         strct_image, ...
%                                         i_droplet_to_track, ...
%                                         extension_pix, csdil, folderesults)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------

    if im_droplet_ini(:,:) ~= 0
        figure
        subplot(1,2,1)
            imshowpair(im_droplet_ini_ext,im_droplet_ini,'montage');
            hold on
            rectangle('Position',[extension_pix-2, extension_pix-2, ...
                      size(im_droplet_ini,2)-csdil-1, ...
                      size(im_droplet_ini,1)-csdil-1],'EdgeColor','r','LineWidth',2);
            title(sprintf('T0%d',str2double(strct_image.time_number)));
        subplot(1,2,2)
            imshowpair(im_droplet_ini_ext,im_droplet_fin,'montage');
            hold on
            imrect(gca,[xoffset+1+size(im_droplet_ini_ext,2), yoffset+1, ...
                        size(im_droplet_ini,2), size(im_droplet_ini,1)]);
            title(sprintf('T0%d-T0%d',str2double(strct_image.time_number), ...
                          str2double(strct_image.time_number)+1));
        supname = sprintf('tracking_XY%s_droplet%d_T%s_to_T%s',strct_image.field_number, ...
                        i_droplet_to_track,strct_image.time_number,strct_image.time_to_track);
        suptitle(supname);
        overlay_fullname = fullfile(folderesults,supname);
        set(gcf, 'Position', get(0,'Screensize'));
        saveas(gcf,overlay_fullname,'png');
        clf;
        close;
    else
         overlay_fullname = '';
    end
end
