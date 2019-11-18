%% main
% 1/ Reads brightfield and CY5 images for one field of view (XY) and one time point (T)
% 2/ Detects droplets from the brightfield image.
% 3/ For each droplet, detects intradroplet cells on the CY5 image and the magnetic bead
%    rod on the brightfield image, and saves the overlay image as a png file
% 4/ Tracks one desired droplet at the following time point (T+1)
%
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------

clear
close all
clc

run parameters

%% HIDE FIGURE WINDOWS
set(0, 'DefaultFigureVisible', 'off')
set(0, 'DefaultAxesVisible', 'off')
%--------------------------------------------------------------------------


%% GET INPUT DATA
fprintf('1/ Get input data \n')
[filename_BF,folderdata] = uigetfile(...
       '', ...
       'Select the brightfield image of the field to be analyzed');
[strct_image.field_number, ...
 strct_image.time_number, strct_image.time_to_track] = get_image_time_field(filename_BF);
folderesults=fullfile(folderdata,'FIGURES');
    if ~exist(folderesults,'dir')
        mkdir(folderesults)
    end
%--------------------------------------------------------------------------


%% READ BRIGHTFILED AND CY5 INPUT IMAGES
image_BF = imread(fullfile(folderdata,filename_BF));
filename_CY5 = strrep(filename_BF,'_BF','_CY5');
image_CY5 = imread(fullfile(folderdata,filename_CY5));
%--------------------------------------------------------------------------


%% DETECT DROPLETS IN THE BRIGHFIELD IMAGE
fprintf('2/ Detecting and visualizing droplets in field XY=%s at T=%s\n', ...
        strct_image.field_number,strct_image.time_number);
[droplist] = find_droplets(image_BF, expected_radius, radius_margin, ...
                           structuring_element_size,...
                           binarization_sensitivity, ...
                           imfindcircle_edge_threshold, ...
                           imfindcircle_sensitivity);
[overlay_fullname] = visualize_detected_droplets(image_BF,strct_image, ...
                                                 droplist, ...
                                                 folderesults);
%-------------------------------------------------------------------------


%% DETECT LIVE CELLS (ON CY5 IMAGE) AND ROD (ON BRIGHTFIELD IMAGE) WITHIN EACH DROPLET
fprintf('3/ Detecting intradroplet live cells and rod \n');

[xx, yy, map_droplets] = build_droplet_map(image_BF, droplist);
% i_droplet_initial=1;
% i_droplet_final=droplist.n_droplets;
i_droplet_initial=90;
i_droplet_final=100;
for i_droplet = i_droplet_initial : i_droplet_final
fprintf('Droplet n=%d over %d\n',i_droplet,droplist.n_droplets);
[imbf_drop, imcy5_drop, LOIC, numObjC, ...
 MR, numObjR] = droplet_analysis(image_BF, image_CY5, i_droplet, ...
                                 map_droplets, droplist, rod, structuring_element_size);
[overlay_fullname_droplet] = visualize_intradroplet_objects(imbf_drop, imcy5_drop, ...
                                                    strct_image, ...
                                                    i_droplet, ...
                                                    numObjR, numObjC, ...
                                                    LOIC, MR, folderesults);
end
%--------------------------------------------------------------------------


%% TRACK ONE CHOSEN DROPLET AT NEXT TIME POINT
prompt = {'Enter index of the droplet to be tracked'};
dlgtitle = 'i_droplet_to_track';
definput = {'100'};
i_droplet_to_track = str2double( cell2mat(inputdlg(prompt, dlgtitle, ...
                                 [1 40], definput)) );

fprintf('4/ Tracking droplet n=%d at t=%s \n', i_droplet_to_track, strct_image.time_to_track);

filename_BF_t_final = strrep(filename_BF,strcat('_T',strct_image.time_number), ...
                                         strcat('_T',strct_image.time_to_track));
image_BF_t_final = imread(fullfile(folderdata,filename_BF_t_final));

extension_pix = round(extension_factor*mean(droplist.radii_droplet));
ATRACKini = im2double(image_BF);
ATRACKini = medfilt2(ATRACKini,[3 3]);
ATRACK = im2double(image_BF_t_final);
ATRACK = medfilt2(ATRACK,[3 3]);

    if (droplist.centers_droplet(i_droplet_to_track,1) - droplist.radii_droplet(i_droplet_to_track)...
        - extension_pix) >= 1 ...
        && (droplist.centers_droplet(i_droplet_to_track,2) - droplist.radii_droplet(i_droplet_to_track) ...
            - extension_pix) >= 1 ...
        && (droplist.centers_droplet(i_droplet_to_track,1) + droplist.radii_droplet(i_droplet_to_track) ...
            + extension_pix) <= size(ATRACKini,2) ...
        && (droplist.centers_droplet(i_droplet_to_track,2) + droplist.radii_droplet(i_droplet_to_track)...
            + extension_pix) <= size(ATRACKini,1)
        
        [im_droplet_ini, ...
         im_droplet_ini_ext, ...
         im_droplet_fin, ...
         xoffset, yoffset] = track_i_droplet(ATRACKini, ...
                                             ATRACK, ...
                                             i_droplet_to_track, ...
                                             extension_pix, ...
                                             droplist, ...
                                             map_droplets, csdil);
        [overlay_fullname_tracking] = visualize_tracking(im_droplet_ini, im_droplet_ini_ext, ...
                                                         im_droplet_fin, ...
                                                         xoffset, yoffset, ...
                                                         strct_image, ...
                                                         i_droplet_to_track, ...
                                                         extension_pix, csdil, folderesults);
    end
%--------------------------------------------------------------------------


%% SHOW FIGURE WINDOWS
set(0, 'DefaultFigureVisible', 'on')
set(0, 'DefaultAxesVisible', 'on')
%--------------------------------------------------------------------------