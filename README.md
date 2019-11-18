1. Function

Basic functions of detection of droplets and intra-droplet objects for one image of the microcfluidic chamber.
Tracking of one droplet at the following time point.

2. Author

AUTHOR : DIXNEUF Sophie, BIOASTER
sophie.dixneuf@bioaster.org
CREATED : 2019-08-20


3. Summary

Reads brightfield and CY5 images for one field of view (XY) and one time point (T)
Detects droplets from the brightfield image.
For each droplet, detects intradroplet cells on the CY5 image and the magnetic bead
rod on the brightfield image, and saves the overlay image as a png file
Tracks one desired droplet at the following time point (T+1)

4. Prerequisites for Deployment 

Version R2018a of MATLAB or newer version

5. How to use

Run main.m and select the brightfield image to be analyzed when asked via a dialog box.
Object detection parameters can be changed in the parameters.m file.