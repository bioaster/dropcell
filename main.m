%% Code DropCell_detection_tracking.m
% BIOASTER, Sophie Dixneuf; bioMérieux, Guillaume Perrin, 2018
% 1/ Reads brightfield and CY5 images for one field of view (XY) and one time point (T)
% 2/ Detects droplets from the brightfield image.
% 3/ For each droplet, detects intradroplet cells on the CY5 image and the magnetic bead
%    rod on the brightfield image, and saves the overlay image as a png file
% 4/ Tracks one desired droplet at the following time point (T+1)
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
[filename_BF,folderdata] = uigetfile('U:\UTEC08\Lyon\SAUVEGARDE_VM_REALISM\20171218_Icareb\*T01*BF.tif', ...
                                  'Select the brightfield image of the field to be analyzed');
[field_number, time_number, time_to_track] = get_image_time_field(filename_BF);
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
fprintf('2/ Detecting and visualizing droplets in field xy=%s at t=%s\n', ...
        field_number,time_number);
[centers_droplet, ...
 radii_droplet, ...
 n_droplets] = find_droplets(image_BF, expectedRadius, RadiusMargin, ...
                             structure_element_size,...
                             binarization_sensitivity, ...
                             imfindcircle_edge_threshold, ...
                             imfindcircle_sensitivity);
 [overlay_fullname] = visualize_detected_droplets(image_BF, folderesults, ...
                                                          field_number, ...
                                                          time_number, ...
                                                          centers_droplet, ...
                                                          radii_droplet, ...
                                                          n_droplets, ...
                                                          linewidth, ...
                                                          fontsize);
%-------------------------------------------------------------------------


%% DETECT LIVE CELLS (ON CY5 IMAGE) AND ROD (ON BRIGHTFIELD IMAGE) WITHIN EACH DROPLET
fprintf('3/ Detecting intradroplet live cells and rod \n');
fprintf('Map of droplets in the field \n');
[xx, yy, map_droplets] = build_droplet_map(image_BF, centers_droplet, radii_droplet, n_droplets);

% fprintf('Droplet analysis \n');
% % nini=1;
% % nfin=n_droplets;
% nfin=10;
% nfin=20;
% imcy5Bin=imbinarize(image_CY5);
% for i_droplet = nini:nfin
% end





%--------------------------------------------------------------------------



