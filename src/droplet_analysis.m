function [LOIC, numObjC, MR, ...
          overlay_fullname] = droplet_analysis(imbf, imcy5, field_number, time_number, ...
                                               i_droplet, map_droplets, ...
                                               centers_droplet, radii_droplet, ...
                                               structure_element_size, folderesults)
imcy5_bin=imbinarize(imcy5);
se = strel('disk',structure_element_size);

colLim=[max(1,round(centers_droplet(i_droplet,1)-radii_droplet(i_droplet))),...
        min(size(imbf,2),round(centers_droplet(i_droplet,1)+radii_droplet(i_droplet)))];
lineLim=[max(1,round(centers_droplet(i_droplet,2)-radii_droplet(i_droplet))),...
        min(size(imbf,1),round(centers_droplet(i_droplet,2)+radii_droplet(i_droplet)))];
imDroplet=imbf(lineLim(1):lineLim(2),colLim(1):colLim(2));
SizeDrop=size(imDroplet);
imbfDrop=im2double(imbf(lineLim(1):lineLim(2),colLim(1):colLim(2)));
imcy5Drop=im2double(imcy5(lineLim(1):lineLim(2),colLim(1):colLim(2)));


fprintf('      **Detecting intradroplet live cell on CY5 image \n');
    mapdrop=map_droplets(lineLim(1):lineLim(2),colLim(1):colLim(2));
    mapdrop(mapdrop~=i_droplet)=0;
    imcy5Dropbin=im2double(imcy5_bin(lineLim(1):lineLim(2),colLim(1):colLim(2)));
    mask=imfill(imcy5Dropbin);
    mask(mapdrop~=i_droplet)=0;
    MC=mask;
    [~,LOIC,numObjC]=bwboundaries(MC,8,'noholes');


fprintf('      **Detecting intradroplet rod on BF image \n');
    %%a) Detect dark objects in zone A (=left-hand part of the droplet, whose width is defined as widthA x width of the droplet) of the brightfield image of the droplet in order to detect the entire rod in zone A
    widthA=0.33;
    mindiv=0.2;
    maxvar=1;
    delta=20;
    minarea=10;
    maxarea=100;
    im8 = uint8(imbf/256);
    im8forMSER = im8;
    im8forMSER(~map_droplets) = 255;
    imDropletforMSER = im8forMSER(lineLim(1):lineLim(2),colLim(1):colLim(2));
    imDropletforMSER(map_droplets(lineLim(1):lineLim(2),colLim(1):colLim(2)) ~= i_droplet) = 255;
    imDropletforMSER(:,round(widthA*SizeDrop(2)):SizeDrop(2))=255;
    imDropletforMSER(1:round(SizeDrop(1)/3),:)=255;
    imDropletforMSER(round(2*SizeDrop(1)/3):SizeDrop(1),:)=255;
    [rr,~] = vl_mser(imDropletforMSER,'MinDiversity',mindiv,'MaxVariation',maxvar,'Delta',delta,...
        'MinArea',minarea/numel(imDropletforMSER),'MaxArea',maxarea/numel(imDropletforMSER),...
        'BrightOnDark',0,'DarkOnBright',1);
    MA1 = zeros(size(imDroplet));
        for x=rr'
        s = vl_erfill(imDropletforMSER,x) ;
        MA1(s) = 1;
        end
    %%b) Find largest rectangle fitting in it in order to mimic the rod by an horizontal rectangle
    MA1=imfill(MA1);
    [~,~,~,MR] = FindLargestRectangles(MA1,[1 5 1]);
    %%c) Dilating the rectangle to allow for slight fluctuation of the rod position during the kinetics, and smoothing the corners to mimic the real shape of the rod
    MR=imdilate(MR,se);
    MR=bwmorph(MR,'thicken',2);
        if size(MR)~=size(imDropletforMSER)
          disp('error MR in celldetection');
          size(imDropletforMSER)
          size(MR)
        end
    [~,~,numObjR]=bwboundaries(MR,8,'noholes');
    clear x rr s
   

fprintf('      **Saving overlay images for intradroplet object detection \n')
        if numObjR~=0 && numObjC~=0
        BOIC=bwboundaries(LOIC,8,'noholes');
        BR=bwboundaries(MR,8,'noholes');
            figure;
            subplot(1,2,1)
            imagesc(imbfDrop); hold on ; axis equal off; colormap gray;
            if isempty(BOIC)==0
                for k=1:length(BOIC)
                boundary = BOIC{k};
                plot(boundary(:,2), boundary(:,1), 'g','LineWidth',1);
                %randomize text position for better visibility
                rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
                col = boundary(rndRow,2); row = boundary(rndRow,1);
                h = text(col+1, row-1, num2str(LOIC(row,col)));
                set(h,'Color','g','FontSize',10,'FontWeight','normal');
                end
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
            imagesc(imcy5Drop); hold on ; axis equal off; colormap gray;
            if isempty(BOIC)==0
                for k=1:length(BOIC)
                boundary = BOIC{k};
                plot(boundary(:,2), boundary(:,1), 'g','LineWidth',1);
                %randomize text position for better visibility
                rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
                col = boundary(rndRow,2); row = boundary(rndRow,1);
                h = text(col+1, row-1, num2str(LOIC(row,col)));
                set(h,'Color','g','FontSize',10,'FontWeight','normal');
                end
            end
            hold on
            if isempty(BR)==0
                for k=1:length(BR)
                boundary = BR{k};
                plot(boundary(:,2), boundary(:,1),'r','LineWidth',1);
                end
            end
            title('CY5','FontSize',8);
            suptitle(sprintf('XY%s_T%s_droplet%d',field_number,time_number,i_droplet),'FontSize',12);
            supname=sprintf('IntraDropletObj_XY%s_T%s_droplet%d',field_number,time_number,i_droplet);
            overlay_fullname=fullfile(folderesults,supname);
            saveas(gcf,overlay_fullname,'png');
            hold off
            clf;
            close;
        end  
end
