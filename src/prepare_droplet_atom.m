function [imbf_drop, imcy5_drop, ...
          map_drop, size_drop, ...
          imcy5_drop_bin, im_droplet_for_MSER] = prepare_droplet_atom(imbf, imcy5, i_droplet, ...
                                                 droplist, map_droplets)
%% prepare_droplet_atom 
% Generates various images of a given droplet (using cropping).
% 
%   Usage 
% [imbf_drop, imcy5_drop, ...
%  map_drop, size_drop, ...
%  imcy5_drop_bin, im_droplet_for_MSER] = prepare_droplet_atom(imbf, imcy5, i_droplet, ...
%                                                  droplist, map_droplets)
% 
%	INPUT 
% imbf: brightfield image of the field of droplets
% imcy5: CY5 image of the field of droplets
% i_droplet: index of the droplet being analyzed
% centers_droplet: matrix of coordinates (x and y, in pixel) of all droplet centers
% radii_droplet: vector of all droplet radii (in pixel)
% map_droplets: label matrix of the droplet map
% 
%	OUTPUTS 
% imbf_drop: imbf after cropping around the droplet being analyzed
% imcy5_drop: imcy5 after cropping around the droplet being analyzed
% map_drop: map of droplets, after cropping around the droplet being analyzed
% size_drop: size of imbf_drop image
% imcy5_drop_bin: binarized CY5 image, after cropping around the droplet to be analyzed
% im_droplet_for_MSER: brightfield image cropped around the droplet being analyzed,
%                      and modified to enable object detection using vl_mser (library VL_feat)
%
%	EXAMPLES
% [imbf_drop, imcy5_drop, ...
%  map_drop, size_drop, ...
%  imcy5_drop_bin, im_droplet_for_MSER] = prepare_droplet_atom(imbf, imcy5, i_droplet, ...
%                                                  droplist, map_droplets)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------

colLim = [max(1,round(droplist.centers_droplet(i_droplet,1)-droplist.radii_droplet(i_droplet))),...
          min(size(imbf,2),round(droplist.centers_droplet(i_droplet,1)+droplist.radii_droplet(i_droplet)))];
lineLim = [max(1,round(droplist.centers_droplet(i_droplet,2)-droplist.radii_droplet(i_droplet))),...
           min(size(imbf,1),round(droplist.centers_droplet(i_droplet,2)+droplist.radii_droplet(i_droplet)))];

map_drop = map_droplets( lineLim(1):lineLim(2), colLim(1):colLim(2) );

imbf_drop = im2double( imbf(lineLim(1):lineLim(2),colLim(1):colLim(2)) );
size_drop = size(imbf_drop);

imcy5_drop = im2double( imcy5(lineLim(1):lineLim(2), colLim(1):colLim(2)) );

imcy5_bin = imbinarize(imcy5);
imcy5_drop_bin = im2double( imcy5_bin(lineLim(1):lineLim(2), colLim(1):colLim(2)) );

im8_for_MSER = uint8(imbf/256);
im8_for_MSER(~map_droplets) = 255;
im_droplet_for_MSER = im8_for_MSER( lineLim(1):lineLim(2), colLim(1):colLim(2) );
im_droplet_for_MSER( map_droplets(lineLim(1):lineLim(2), colLim(1):colLim(2) ) ~= i_droplet) = 255;
end
