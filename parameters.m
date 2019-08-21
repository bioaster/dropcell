addpath('src')
addpath('ressources')

%% parameters of image processing to find droplets in a brightfield image
expected_radius = 35;
radius_margin = [0.8 1.2];
structuring_element_size = 2;
binarization_sensitivity = 0.533;
imfindcircle_edge_threshold = 0.01;
imfindcircle_sensitivity = 0.85;

%% parameters of image processing to find intradroplet magnetic rod
rod.width_search_zone = 0.33;
rod.mindiv = 0.2;
rod.maxvar = 1;
rod.delta = 20;
rod.minarea = 10;
rod.maxarea = 100;

%% parameters for tracking a specific droplet at the next time point 
extension_factor = 1.3;
csdil = 7;

