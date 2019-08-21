function [LOIC, numObjC] = find_live_cells(i_droplet, imcy5_drop_bin, map_drop)
%% find_live_cells 
% detect live cell contours on the CY5 fluorescence image of a given
% droplet
% 
%   Usage 
% [LOIC, numObjC] = find_live_cells(i_droplet, imcy5_drop_bin, map_drop)
% 
%	INPUT 
% imcy5_drop_bin: binarized CY5 image, after cropping around the droplet to be analyzed
% i_droplet: index of the droplet being analyzed
% map_drop: map of droplets, after cropping around the droplet to be analyzed
%  
%	OUTPUTS 
% LOIC: label matrix of the live cells (CY5 positive) contained in the analyzed droplet
% numObjC: number of live cells (CY5 positive) contained in the analyzed droplet
%  
%	EXAMPLES
% [LOIC, numObjC] = find_live_cells(i_droplet, imcy5_drop_bin, map_drop)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------
    map_drop(map_drop ~= i_droplet) = 0;
    mask = imfill(imcy5_drop_bin);
    mask(map_drop ~= i_droplet) = 0;
    MC = mask;
    [~, LOIC, numObjC] = bwboundaries(MC, 8, 'noholes');
end
