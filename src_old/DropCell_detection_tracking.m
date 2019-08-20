% Code DropCell_detection_tracking.m
% BIOASTER, Sophie Dixneuf; bioMérieux, Guillaume Perrin, 2018
% 1/ Read input data for one field of view (xyc) and one time point (tc)
% 2/ Detect droplets from the brightfield image.
% 3/ For each droplet, detects intradroplet cells on the CY5 image and the magnetic bead rod on the brightfield image, and saves the overlay image as a png file
% 4/ Tracks one desired droplet at the following time point (tc+1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%INPUT DATA
clear all
directory=pwd;
[filename,folderdata]=uigetfile('U:\UTEC08\Lyon\SAUVEGARDE_VM_REALISM\20171218_Icareb\*T01*BF.tif','Select the brightfield image of the field to be analyzed');
pos_T=strfind(filename,'T');
tc=strcat(filename(pos_T+1),filename(pos_T+2));%time to be analyzed
pos_Y=strfind(filename,'Y');
xyc=strcat(filename(pos_Y+1),filename(pos_Y+2),filename(pos_Y+3));%field of view to be analyzed
t_to_track=str2double(tc)+1;
    if t_to_track<10
        t_to_track=strcat('0',char(string(t_to_track)));
    else
        t_to_track=char(string(t_to_track));
    end
expectedRadius=35;
RadiusMargin=[0.8 1.2];
folderesults=fullfile(folderdata,'FIGURES_DROPCELL');
extension_factor=1.3;
linewidth=1;
fontsize=4;
set(0, 'DefaultFigureVisible', 'off')
set(0, 'DefaultAxesVisible', 'off')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('1/ Reading input images \n');
DBF=dir(fullfile(folderdata,'*BF*.tif'));
tiffilesBF={DBF.name};
FABF=strfind(tiffilesBF,strcat('T',tc,'_XY',xyc));
sbf=find(not(cellfun('isempty',FABF)));
im=imread(fullfile(folderdata,char(tiffilesBF(sbf))));

DBF=dir(fullfile(folderdata,'*CY5*.tif'));
tiffilesCY5={DBF.name};
FACY5=strfind(tiffilesCY5,strcat('T',tc,'_XY',xyc));
scy5=find(not(cellfun('isempty',FACY5)));
imcy5=imread(fullfile(folderdata,char(tiffilesCY5(scy5))));

    if ~exist(folderesults,'dir')
        mkdir(folderesults)
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('2/ Detecting droplets in field xy=%s at t=%s\n',xyc,tc);
imbin=imbinarize(im,'adaptive','ForegroundPolarity','dark','Sensitivity',0.533);
se=strel('disk',2);
imbin=imopen(imbin,se);
imbin=imclearborder(imbin);
[centersDroplet,radiiDroplet] = imfindcircles(imbin,round(expectedRadius*RadiusMargin),'ObjectPolarity','bright','EdgeThreshold',0.01,'Sensitivity',0.85);
nDroplets = length(radiiDroplet);
    %save overlay of the BF field image and droplet contours
    figure; imagesc(im); axis image off; colormap gray;
    viscircles(centersDroplet,radiiDroplet,'EdgeColor','b','LineStyle','-','LineWidth',linewidth);
    hold on;
        for iDroplet=1:nDroplets
            text(centersDroplet(iDroplet,1),centersDroplet(iDroplet,2),num2str(iDroplet),'Color','r','FontSize',fontsize);
        end
    title(sprintf('%d detected drops - BF \n',nDroplets));
    hold off;
    supname=char(strcat('T',tc,'_XY',xyc,'_detected_drops_BF'));
    fpc=fullfile(folderesults,supname);
    print(gcf,fpc,'-dpng','-r250');
    % saveas(gcf,fpc,'png');
    close;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('3/ Detecting intradroplet live cells and rod \n');

fprintf('Map of droplets in the field \n');
[xx,yy] = meshgrid(1:size(im,2),1:size(im,1));
mapDroplets = zeros(size(im));
    for iDroplet = 1:nDroplets
        mapDroplets((xx-centersDroplet(iDroplet,1)).^2+(yy-centersDroplet(iDroplet,2)).^2 < (radiiDroplet(iDroplet))^2) = iDroplet;
    end
    
nini=1;
nfin=nDroplets;
imcy5Bin=imbinarize(imcy5);
for iDroplet = nini:nfin
fprintf('Droplet n=%d over %d\n',iDroplet,nDroplets);
colLim=[max(1,round(centersDroplet(iDroplet,1)-radiiDroplet(iDroplet))),...
        min(size(im,2),round(centersDroplet(iDroplet,1)+radiiDroplet(iDroplet)))];
lineLim=[max(1,round(centersDroplet(iDroplet,2)-radiiDroplet(iDroplet))),...
        min(size(im,1),round(centersDroplet(iDroplet,2)+radiiDroplet(iDroplet)))];
imDroplet=im(lineLim(1):lineLim(2),colLim(1):colLim(2));
SizeDrop=size(imDroplet);
imbfDrop=im2double(im(lineLim(1):lineLim(2),colLim(1):colLim(2)));
imcy5Drop=im2double(imcy5(lineLim(1):lineLim(2),colLim(1):colLim(2)));


    fprintf('      **Detecting intradroplet live cell on CY5 image \n');
    mapdrop=mapDroplets(lineLim(1):lineLim(2),colLim(1):colLim(2));
    mapdrop(mapdrop~=iDroplet)=0;
    imcy5Dropbin=im2double(imcy5Bin(lineLim(1):lineLim(2),colLim(1):colLim(2)));
    mask=imfill(imcy5Dropbin);
    mask(mapdrop~=iDroplet)=0;
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
    im8 = uint8(im/256);
    im8forMSER = im8;
    im8forMSER(~mapDroplets) = 255;
    imDropletforMSER = im8forMSER(lineLim(1):lineLim(2),colLim(1):colLim(2));
    imDropletforMSER(mapDroplets(lineLim(1):lineLim(2),colLim(1):colLim(2)) ~= iDroplet) = 255;
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
            suptitle(sprintf('XY%s_T%s_droplet%d',xyc,tc,iDroplet),'FontSize',12);
            supname=sprintf('IntraDropletObj_XY%s_T%s_droplet%d',xyc,tc,iDroplet);
            fpc=fullfile(folderesults,supname);
            saveas(gcf,fpc,'png');
            hold off
            clf;
            close;
        end    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('4/ Tracking droplet n=%d at t=%s \n',iDroplet_to_track,t_to_track);

extensionPix=round(extension_factor*mean(radiiDroplet));
ATRACKini=im2double(im);
MedianInt_BFini=median(ATRACKini(:));
mapDroplets_ini=mapDroplets;
FABF=strfind(tiffilesBF,strcat('T',t_to_track,'_XY',xyc));
sbf=find(not(cellfun('isempty',FABF)));
ATRACK=im2double(imread(fullfile(folderdata,char(tiffilesBF(sbf)))));
ATRACK=medfilt2(ATRACK,[3 3]);
MedianInt_BF=median(ATRACK(:));
mapDroplets_end=zeros(size(ATRACKini));

prompt = {'Enter index of the droplet to be tracked'};
dlgtitle = 'iDroplet_to_track';
definput = {'100'};
iDroplet_to_track=str2double(cell2mat(inputdlg(prompt,dlgtitle,[1 40],definput)));

    if (centersDroplet(iDroplet_to_track,1)-radiiDroplet(iDroplet_to_track)-extensionPix)>=1 && (centersDroplet(iDroplet_to_track,2)-radiiDroplet(iDroplet_to_track)-extensionPix)>=1 ...
                && (centersDroplet(iDroplet_to_track,1)+radiiDroplet(iDroplet_to_track)+extensionPix)<=size(ATRACKini,2) && (centersDroplet(iDroplet_to_track,2)+radiiDroplet(iDroplet_to_track)+extensionPix)<=size(ATRACKini,1)
        colLim = [max(1,round(centersDroplet(iDroplet_to_track,1)-radiiDroplet(iDroplet_to_track))),...
            min(size(ATRACKini,2),round(centersDroplet(iDroplet_to_track,1)+radiiDroplet(iDroplet_to_track)))];
        lineLim = [max(1,round(centersDroplet(iDroplet_to_track,2)-radiiDroplet(iDroplet_to_track))),...
            min(size(ATRACKini,1),round(centersDroplet(iDroplet_to_track,2)+radiiDroplet(iDroplet_to_track)))];
        csdil=7;
        imDroplet1 = ATRACKini(lineLim(1)-csdil:lineLim(2)+csdil,colLim(1)-csdil:colLim(2)+csdil);
        imDroplet=imDroplet1.*imclearborder(bwmorph(mapDroplets_ini(lineLim(1)-csdil:lineLim(2)+csdil,colLim(1)-csdil:colLim(2)+csdil),'thicken',6));
        imDroplet(imDroplet==0)=median(imDroplet(:));
        imDroplet=imDroplet/iDroplet_to_track;
        imDroplett=ATRACK(lineLim(1)-extensionPix:lineLim(2)+extensionPix,colLim(1)-extensionPix:colLim(2)+extensionPix);
        imDroplett1=ATRACKini(lineLim(1)-extensionPix:lineLim(2)+extensionPix,colLim(1)-extensionPix:colLim(2)+extensionPix);

        if imDroplet(:,:)~=0
            cc=normxcorr2(imDroplet/MedianInt_BFini,imDroplett/MedianInt_BF);
            [ypeak,xpeak]=find(cc==max(cc(:)));
            xoffset=xpeak-size(imDroplet,2);
            yoffset=ypeak-size(imDroplet,1);

                figure
                subplot(1,2,1)
                imshowpair(imDroplett1,imDroplet,'montage');
                hold on
                rectangle('Position',[extensionPix-2, extensionPix-2, size(imDroplet,2)-csdil-1, size(imDroplet,1)-csdil-1],'EdgeColor','r','LineWidth',2);
                title(sprintf('T0%d',str2double(tc)));
                subplot(1,2,2)
                imshowpair(imDroplett1,imDroplett,'montage');
                hold on
                imrect(gca,[xoffset+1+size(imDroplett1,2), yoffset+1, size(imDroplet,2), size(imDroplet,1)]);
                title(sprintf('T0%d-T0%d',str2double(tc),str2double(tc)+1));
                supname=sprintf('tracking_XY%s_droplet%d_T%s_to_T%s',xyc,iDroplet_to_track,tc,t_to_track);
                suptitle(supname);
                fpc=fullfile(folderesults,supname);
                set(gcf, 'Position', get(0,'Screensize'));
                saveas(gcf,fpc,'png');
                clf;
                close;
         end
    end

set(0, 'DefaultFigureVisible', 'on')
set(0, 'DefaultAxesVisible', 'on')
    
