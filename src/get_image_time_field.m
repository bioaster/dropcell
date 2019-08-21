function [field_number, time_number, time_to_track] = get_image_time_field(file)
%% get_image_time_field 
% Find field and time index in the brightfield image file name. The file name must contain 
% the string '_T' followed by the time_number string in 2 digits
% (ex:'_T05'), and the string '_XY' followed by the field_number string in
% 3 digits (ex:'_XY004').
% 
%   Usage 
% [field_number, time_number, time_to_track] = get_image_time_field(file)
% 
%	INPUT 
% file: image file name
%  
%	OUTPUTS 
% field_number: image field name
% time_number: image time point name
% time_to_track: following time point
% 
%	EXAMPLES
% [field_number, time_number, time_to_track] = get_image_time_field(file)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------

    index_t = strfind(file, '_T');
    time_number = strcat( file(index_t+2), file(index_t+3) );
    index_y = strfind(file, '_XY');
    field_number = strcat( file(index_y+3), file(index_y+4), ...
                           file(index_y+5) );
    time_to_track = str2double(time_number)+1;
    if time_to_track < 10
        time_to_track = strcat( '0', char(string(time_to_track)) );
    else
        time_to_track = char( string(time_to_track) );
    end
end

