function [xx, yy, map_droplets] = build_droplet_map(im,centers_droplet, ...
                                                    radii_droplet, n_droplets)
%% build_droplet_map 
%Build 2D grid of the image and Label matrix of the droplets map 
% 
%   Usage 
% [xx, yy, map_droplets] = build_droplet_map(im,centers_droplet, ...
%                                            radii_droplet, n_droplets)
% 
%	INPUT 
% im: brightfield image
% n_droplets: number of detected droplets in the image
% centers_droplet: matrix (n_droplets x 2) of coordinates (x and y, in pixel) of droplet centers
% radii_droplet: vector (n_droplets) of droplet radii (in pixel)
%
%  
%	OUTPUTS 
% xx: x coordinates (number of columns in im) by pixel of the image
% yy: y coordinates (number of rows in im) by pixel of the image
% map_droplets: label matrix of the droplet map
%
%
%	EXAMPLES
% [xx, yy, map_droplets] = build_droplet_map(im,centers_droplet, ...
%                                            radii_droplet, n_droplets)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------
[xx, yy] = meshgrid( 1:size(im,2), 1:size(im,1) );
map_droplets = zeros(size(im));
    for i_droplet = 1:n_droplets
        map_droplets( (xx-centers_droplet(i_droplet,1)).^2 + (yy-centers_droplet(i_droplet,2)).^2 < (radii_droplet(i_droplet))^2 ) = i_droplet;
    end
end
