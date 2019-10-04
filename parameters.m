addpath('src')
addpath('ressources')

%% parameters of image processing to find droplets in a brightfield image
expected_radius = 35; % approximate expected radius of the droplets to be detected (in pixel) 
radius_margin = [0.8 1.2]; % margin of the approximate expected droplet radius (multiplicative coefficient)
structuring_element_size = 2; % size of the 'disk' structuring element used for image processing 
                               %(typically for cleaning binary images)  
binarization_sensitivity = 0.533; % sensitivity parameter of the Matlab 'imbinarize.m' function
imfindcircle_edge_threshold = 0.01; % 'EdgeThresjold' scalar ([0 1]) specifying the gradient threshold for determining edge pixels in the Matlab 'imfindcircles.m' function
imfindcircle_sensitivity = 0.85; % 'Sensitivity' factor ([0 1]) of the Matlab 'imfindcircles.m' function 

%% parameters of image processing to find intradroplet magnetic rod
rod.width_search_zone = 0.33; % droplet width factor ([0 1]) limitating
                              % (in the X direction, from left to right)
                              % the region of the droplet for searching the rod 
rod.mindiv = 0.2; % 'MinDiversity' parameter of the Matlab 'vl_mser.m' function
rod.maxvar = 1; % 'MaxVariation' parameter of the Matlab 'vl_mser.m' function
rod.delta = 20; % 'Delta' parameter of the Matlab 'vl_mser.m' function
rod.minarea = 10; % 'MinArea' parameter of the Matlab 'vl_mser.m' function
rod.maxarea = 100; % 'MaxArea' parameter of the Matlab 'vl_mser.m' function

%% parameters for tracking a specific droplet at the next time point 
extension_factor = 1.3;
csdil = 7;

