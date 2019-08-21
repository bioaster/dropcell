function [MR, numObjR] = find_rod(im_droplet_for_MSER, rod, ...
                                  size_drop, structuring_element_size)
%% find_rod 
% Detect the magnetic rod on the brightfield image and mimic it by a
% smooth-corner rectangle.
% 
%   Usage 
% [MR, numObjR] = find_rod(im_droplet_for_MSER, rod, ...
%                          size_drop, structuring_element_size)
% 
%	INPUT 
% im_droplet_for_MSER: 8 it image image of the droplet, prepared for using
%                       vl_mser function (VL_feat library)
% rod: structure pof parameters used to find intradroplet magnetic rod in
%      im_droplet_for_MSER image
% size_drop: size of droplet image
% structuring_element_size: size of the structuring element (disk) used for
%                           image processing
%  
%	OUTPUTS 
% MR: mask of the rod
% numObjR: number of detected rods within the droplet
%  
%	EXAMPLES
% [MR, numObjR] = find_rod(im_droplet_for_MSER, rod, ...
%                          size_drop, structuring_element_size)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------

%%Detect dark objects in left-hand part of the droplet
    im_droplet_for_MSER( :, round(rod.width_search_zone * size_drop(2)):size_drop(2) ) = 255;
    im_droplet_for_MSER(1:round(size_drop(1)/3), :) = 255;
    im_droplet_for_MSER(round(2*size_drop(1)/3):size_drop(1), :) = 255;
    [rr,~] = vl_mser( im_droplet_for_MSER, 'MinDiversity', rod.mindiv, ...
        'MaxVariation', rod.maxvar, 'Delta', rod.delta,...
        'MinArea', rod.minarea/numel(im_droplet_for_MSER), ...
        'MaxArea', rod.maxarea/numel(im_droplet_for_MSER),...
        'BrightOnDark', 0, 'DarkOnBright',1);
    MA1 = zeros(size_drop);
    for x = rr'
        s = vl_erfill(im_droplet_for_MSER,x) ;
        MA1(s) = 1;
    end
        
%%Find largest rectangle fitting in it in order to mimic
%%the rod by an horizontal rectangle
    MA1=imfill(MA1);
    [~,~,~,MR] = FindLargestRectangles(MA1,[1 5 1]);

%%Dilate the rectangle to allow for slight fluctuation 
%%of the rod position during the kinetics,
%%and smoothes the corners to mimic the real shape of the rod
    se = strel('disk',structuring_element_size);
    MR=imdilate(MR,se);
    MR=bwmorph(MR,'thicken',2);
    if size(MR)~=size(im_droplet_for_MSER)
        disp('error MR in celldetection');
        size(im_droplet_for_MSER)
        size(MR)
    end
    [~,~,numObjR]=bwboundaries(MR,8,'noholes');
    clear x rr s
end
