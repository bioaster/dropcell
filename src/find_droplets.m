function [droplist] = find_droplets(im, expected_radius, radius_margin, ...
                                      structure_element_size, ...
                                      binarization_sensitivity, ...
                                      imfindcircle_edge_threshold, ...
                                      imfindcircle_sensitivity)
%% find_droplets 
%Find whole droplets in a brightfield image.
% 
%   Usage 
% [droplist] = find_droplets(im, expected_radius, radius_margin, ...
%                              structure_element_size, ...
%                              binarization_sensitivity, ...
%                              imfindcircle_edge_threshold, ...
%                              imfindcircle_sensitivity)
% 
%	INPUT 
% im: brightfield image of the field of droplets
% expected_radius: approximate radius (in pixel) of droplets to be detected 
% radius_margin: vector (length: 2) of margin (multiplicative factor)
%                allowed on the input expected_radius 
% structure_element_size: size of the structuring element (disk) used for
%                         image processing
% binarization_sensitivity: 'Sensitivity' parameter of the imbinarize Matlab function
% imfindcircle_edge_threshold: 'EdgeThreshold' parameter of the imfindcircle
%                              Matlab function
% imfindcircle_sensitivity: 'Sensitivity' parameter of the imfindcircle
%                            Matlab function
%  
%	OUTPUTS 
% droplist: structure of droplet parameters
%       .centers_droplet: matrix (size: n_droplets x 2) of coordinates (x and y, in pixel) of droplet centers
%       .radii_droplet: vector (length: n_droplets) of droplet radii (in pixel)
%       .n_droplets: number of whole droplets in the image
%
%	EXAMPLES
% expected_radius=35;
% radius_margin=[0.8 1.2];
% structure_element_size=2;
% binarization_sensitivity=0.533;
% imfindcircle_edge_threshold=0.01;
% imfindcircle_sensitivity=0.85;
% [droplist] = find_droplets(im, expected_radius, radius_margin, ...
%                              structure_element_size, ...
%                              binarization_sensitivity, ...
%                              imfindcircle_edge_threshold, ...
%                              imfindcircle_sensitivity)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------                                 
    imbin = imbinarize(im, 'adaptive', 'ForegroundPolarity', 'dark', ...
                       'Sensitivity', binarization_sensitivity);
    se = strel('disk',structure_element_size);
    imbin = imopen(imbin,se);
    imbin = imclearborder(imbin);
    [droplist.centers_droplet, ...
     droplist.radii_droplet] = imfindcircles(imbin, round(expected_radius * radius_margin),...
                                    'ObjectPolarity', 'bright', ...
                                    'EdgeThreshold', imfindcircle_edge_threshold, ...
                                    'Sensitivity', imfindcircle_sensitivity);
    droplist.n_droplets = length(droplist.radii_droplet);
   
    
end