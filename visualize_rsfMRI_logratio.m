addpath("E:\Documents\Haesler\sniffnet_data_pipeline\")

rs_file = "swausub-01_rfMRI_REST1_LR.nii";
vol_mask = niftiread("art_mask_ausub-01_rfMRI_REST1_LR.nii");

V = niftiread(rs_file);
Vinfo = niftiinfo(rs_file);

%vol_space = zeros(91,109,91,1199);

for ii = 1:size(V,4)-1
    disp(ii)
%get the volumes
vol1 = V(:,:,:,ii);
vol2 = V(:,:,:,ii+1);

diffvol = vol2-vol1;
diffvol(~vol_mask) = nan; %apply brain mas

logratio_imaginary = log(vol2./vol1); %make logratio
logratio = real(logratio_imaginary); %discard imaginary part

logratio(isnan(logratio)) = 0; % make all the nans zero
logratio(isinf(logratio)) = 6; % make all the infs 1
logratio(~vol_mask) = nan; % apply brain mask
% logratio = normalize(logratio); %normalize

% vol_space(:,:,:,ii) = logratio;
vol_space(:,:,:,ii) = diffvol;


end
%create max and min values so MIP later is representative
vol_space(1,1,1,:) = max(vol_space(:)); %max value
vol_space(1,1,2,:) = min(vol_space(:)); %min value


filename = "rsfMRI-swausub1-vol-MPI_diffvol_10xrealspeed.mp4";
frame1 = 1;
frameEnd = 300;

% create the video writer 
writerObj = VideoWriter(filename,'MPEG-4');
writerObj.FrameRate = 13;

% open the video writer
open(writerObj);
% write the frames to the video
for nn=frame1:frameEnd
    disp(nn)
    %figure('visible','off');
    Vol = vol_space(:,:,:,nn);
%     Vol = V(:,:,:,nn);
    VisVol = imrotate3(Vol,nn,[0,0,1],'loose','FillValues',nan);
    volshow(VisVol,'Renderer','MaximumIntensityProjection')
    frame = getframe(gca);
    writeVideo(writerObj,frame);
    
   

end
% close the writer object
close(writerObj);
close()

