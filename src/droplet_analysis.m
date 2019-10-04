function [imbf_drop, imcy5_drop, LOIC, numObjC, ...
          MR, numObjR] = droplet_analysis(imbf, imcy5, ...
                                          i_droplet, map_droplets, ...
                                          droplist, ...
                                          rod, structuring_element_size)
%% droplet_analysis 
% detect intradroplet rod and live cells for a given droplet and save a png image 
% of the original brightfield image of the analyzed droplet and of the
% detected intradroplet rod and live cells 
% 
%   Usage 
% [imbf_drop, imcy5_drop, LOIC, numObjC, ...
%  MR,numObjR] = droplet_analysis(imbf, imcy5, ...
%                                       i_droplet, map_droplets, ...
%                                       droplist, ...
%                                       rod,structuring_element_size, folderesults)
% 
%	INPUT 
% imbf: brightfield image of the field of droplets
% imcy5: CY5 image of the same field of droplets 
% i_droplet: index of the droplet being analyzed
% map_droplets: label matrix of the droplet map
% droplist: structure of droplet parameters
%       .n_droplets: number of detected whole droplets in the image
%       .centers_droplet: matrix (n_droplets x 2) of coordinates (x and y, in pixel) of droplet centers
%       .radii_droplet: vector (n_droplets) of droplet radii (in pixel)
% rod: structure containing rod detection parameters
%       .width_search_zone
%       .mindiv
%       .maxvar
%       .delta
%       .minarea
%       .maxarea
% structuring_element_size: size of the structuring element (disk) used for
%                         image processing
% folderesults: folder in which the output image will be saved
%  
%	OUTPUTS 
% imbf_drop: cropped brightfield image of the droplet (index i_droplet) being analyzed
% imcy5_drop: cropped CY5 image of the droplet being analyzed
% LOIC: label matrix of the live cells (CY5 positive) contained in the analyzed droplet
% numObjC: number of live cells (CY5 positive) detected in the analyzed droplet
% MR: mask of the magnetic rod contained in the analyzed droplet
% numObjR: number of rods detected on the brightfield image of the analyzed droplet
%
%	EXAMPLES
% [imbf_drop, imcy5_drop, LOIC, numObjC, ...
%  MR,numObjR] = droplet_analysis(imbf, imcy5, ...
%                                       i_droplet, map_droplets, ...
%                                       droplist, ...
%                                       rod,structuring_element_size, folderesults)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------

[imbf_drop, imcy5_drop, ...
          map_drop, size_drop, ...
          imcy5_drop_bin, im_droplet_for_MSER] = prepare_droplet_atom(imbf, imcy5, i_droplet, ...
                                                 droplist, map_droplets);

fprintf('      **Detecting intradroplet live cells on CY5 image \n');
[LOIC, numObjC] = find_live_cells(i_droplet, imcy5_drop_bin, map_drop);


fprintf('      **Detecting intradroplet rod on BF image \n');
[MR, numObjR] = find_rod(im_droplet_for_MSER, rod, ...
                                  size_drop, structuring_element_size);
end
