function [overlay_fullname] = visualize_intradroplet_objects(imbf_drop, imcy5_drop, ...
                                                             strct_image, ...
                                                             i_droplet, ...
                                                             numObjR, numObjC, ...
                                                             LOIC, MR, folderesults)
%% visualize_intradroplet_objects
% Create and save an overlay png image of the original brightfield and CY5
% images of a given droplet together with the detected contours of intradroplet rod 
% and live cells
% 
%   Usage 
% [overlay_fullname] = visualize_intradroplet_objects(imbf_drop, imcy5_drop, ...
%                                                     strct_image, ...
%                                                     i_droplet, ...
%                                                     numObjR, numObjC, ...
%                                                     LOIC, MR, folderesults)
% 
%	INPUT 
% imbf_drop:
% imcy5_drop:
% field_number: index of the field of view (string)
% time_number: time point of the field of view (string)
% i_droplet: index of the droplet being analyzed
% numObjR: number of detected rods within the droplet
% numObjC: number of detected live cells within the droplet
% LOIC: Label matrix of the detected live cells
% MR: mask of the detected rod
% folderesults: folder in which the output image will be saved
%  
%	OUTPUTS 
% overlay_fullname: full name of the saved png overlay image
% 
%	EXAMPLES
% [overlay_fullname] = visualize_intradroplet_objects(imbf_drop, imcy5_drop, ...
%                                                     strct_image, ...
%                                                     i_droplet, ...
%                                                     numObjR, numObjC, ...
%                                                     LOIC, MR, folderesults)
% 
%   AUTHOR : DIXNEUF Sophie, BIOASTER
%   CREATED : 2019-08-20
%--------------------------------------------------------------------------
        if numObjR~=0 && numObjC ~= 0
            
            BOIC=bwboundaries(LOIC,8,'noholes');
            BR=bwboundaries(MR,8,'noholes');
            
            figure;
            subplot(1,2,1)
                imagesc(imbf_drop); hold on ; axis equal off; colormap gray;
                if isempty(BOIC)==0
                    show_index(BOIC, LOIC);
                end
                hold on
                if isempty(BR)==0
                    for k=1:length(BR)
                        boundary = BR{k};
                        plot(boundary(:,2), boundary(:,1),'r','LineWidth',1);
                    end
                end
                title('BF','FontSize',8);
             subplot(1,2,2)
                imagesc(imcy5_drop); hold on ; axis equal off; colormap gray;
                if isempty(BOIC)==0
                    show_index(BOIC, LOIC);
                end
                hold on
                if isempty(BR)==0
                    for k=1:length(BR)
                        boundary = BR{k};
                        plot(boundary(:,2), boundary(:,1),'r','LineWidth',1);
                    end
                end
                title('CY5','FontSize',8);
                suptitle(sprintf('XY%s_T%s_droplet%d',strct_image.field_number,...
                                 strct_image.time_number,i_droplet),'FontSize',12);
                supname=sprintf('IntraDropletObj_XY%s_T%s_droplet%d', ...
                                 strct_image.field_number, strct_image.time_number, ...
                                 i_droplet);
                overlay_fullname=fullfile(folderesults,supname);
                saveas(gcf,overlay_fullname,'png');
                hold off
                clf;
                close;
        else
                overlay_fullname='';
        end
end
