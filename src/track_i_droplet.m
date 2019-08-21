function [im_droplet_ini, ...
          im_droplet_ini_ext, ...
          im_droplet_fin, ...
          xoffset, yoffset] = track_i_droplet(ATRACKini, ATRACK, i_droplet_to_track, ...
                                              extension_pix, ...
                                              droplist, map_droplets_ini, ...
                                              csdil)
%% track_i_droplet
% Tracks a given droplet (detected at T) at the subsequent time-point.
%
%   Usage 
% [im_droplet_ini, ...
%  im_droplet_ini_ext, ...
%  im_droplet_fin, ...
%  xoffset, yoffset] = track_i_droplet(ATRACKini, ATRACK, i_droplet_to_track, ...
%                                      extension_pix, ...
%                                      droplist, map_droplets_ini, ...
%                                      csdil)
% 
%	INPUT 
% ATRACKini:
% ATRACK:
% i_droplet_to_track: index of the droplet being tracked
% extension_pix: folder in which the output image will be saved
% droplist:
% map_droplets_ini:
% csdil:
%
%  
%	OUTPUTS 
% im_droplet_ini:
% im_droplet_ini_ext:
% im_droplet_fin:
% xoffset:
% yoffset:
% 
%	EXAMPLES
% [im_droplet_ini, ...
%  im_droplet_ini_ext, ...
%  im_droplet_fin, ...
%  xoffset, yoffset] = track_i_droplet(ATRACKini, ATRACK, i_droplet_to_track, ...
%                                      extension_pix, ...
%                                      droplist, map_droplets_ini, ...
%                                      csdil)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------

MedianInt_BFini = median(ATRACKini(:));
MedianInt_BF = median(ATRACK(:));
    
colLim = [max(1,round(droplist.centers_droplet(i_droplet_to_track,1) ...
          - droplist.radii_droplet(i_droplet_to_track))), ...
          min(size(ATRACKini,2),round(droplist.centers_droplet(i_droplet_to_track,1) ...
          + droplist.radii_droplet(i_droplet_to_track)))];
lineLim = [max(1,round(droplist.centers_droplet(i_droplet_to_track,2) ...
           - droplist.radii_droplet(i_droplet_to_track))),...
           min(size(ATRACKini,1),round(droplist.centers_droplet(i_droplet_to_track,2) ...
           + droplist.radii_droplet(i_droplet_to_track)))];


im_droplet_ini = ATRACKini( lineLim(1)-csdil : lineLim(2)+csdil, ...
                        colLim(1)-csdil : colLim(2)+csdil );
im_droplet_ini = im_droplet_ini.*imclearborder(bwmorph(map_droplets_ini(lineLim(1)-csdil : ...
                                                               lineLim(2)+csdil, ...
                                                               colLim(1)-csdil : ...
                                                               colLim(2)+csdil), ...
                                                               'thicken',6));
im_droplet_ini(im_droplet_ini == 0) = median(im_droplet_ini(:));
im_droplet_ini = im_droplet_ini / i_droplet_to_track;
im_droplet_fin = ATRACK( lineLim(1)-extension_pix : lineLim(2)+extension_pix, ...
                     colLim(1)-extension_pix : colLim(2)+extension_pix );
im_droplet_ini_ext = ATRACKini( lineLim(1)-extension_pix : lineLim(2)+extension_pix, ...
                        colLim(1)-extension_pix : colLim(2)+extension_pix );


cc = normxcorr2( im_droplet_ini / MedianInt_BFini, ...
                 im_droplet_fin / MedianInt_BF);
[ypeak,xpeak] = find( cc == max(cc(:)) );
xoffset = xpeak - size(im_droplet_ini,2);
yoffset = ypeak - size(im_droplet_ini,1);
end
