function [field_number, time_number, time_to_track] = get_image_time_field(file)
%% get_image_time_field 
% Find field and time index in the image file name. The file name must
%**************** A COMPLETER
% 
%   Usage 
% [field_number, time_number, time_to_track] = get_image_time_field(file)
% 
%	INPUT 
% file: image file name
% path: image folder complete path
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

    index_t = strfind(file, 'T');
    time_number = strcat( file(index_t+1), file(index_t+2) );
    index_y = strfind(file, 'Y');
    field_number = strcat( file(index_y+1), file(index_y+2), ...
                           file(index_y+3) );
    time_to_track = str2double(time_number)+1;
    if time_to_track < 10
        time_to_track = strcat( '0', char(string(time_to_track)) );
    else
        time_to_track = char( string(time_to_track) );
    end
end

