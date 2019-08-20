addpath('src')
addpath('ressources')

linewidth=1;
fontsize=4;

%% parameters of image processing to find droplets in a brightfield image
expectedRadius=35;
RadiusMargin=[0.8 1.2];
structure_element_size=2;
binarization_sensitivity=0.533;
imfindcircle_edge_threshold=0.01;
imfindcircle_sensitivity=0.85;

%% parameters for tracking a specific droplet at the next time point 
extension_factor=1.3;

