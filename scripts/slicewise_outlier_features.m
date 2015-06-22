function slicewise_outlier_features(ID)
% DESCRIPTION
% INPUT: ID - participant ID
% OUTPUT: csv files

data=read_mrtrix(strcat(ID,'/dwi.mif'));
prediction=read_mrtrix(strcat(ID,'/prediction.mif'));
mask=prediction.data>0; data.data=data.data.*mask;

b0mask=read_mrtrix(strcat(ID,'/nodif_brain_mask.mif'));

[~,~,zdim,ndim]=size(data.data);

%% normalised voxel count per slice
voxcount=squeeze(sum(reshape(mask,[],zdim,ndim)));
dlmwrite(strcat(ID,'/voxelcount_normalised.csv'),voxcount./sum(b0mask.data(:)))

%% slice position
[~,idxmin]=max(voxcount>0);
[~,idxtmp]=max(flipud(voxcount>0));
idxmax=size(voxcount,1)-idxtmp;
slicepos=nan(size(voxcount));
for col=1:size(voxcount,2)
    slicepos(idxmin(col):idxmax(col),col)=linspace(0,1,idxmax(col)-idxmin(col)+1);
end
slicepos(:,1)=nan;
dlmwrite(strcat(ID,'/slicepos.csv'),slicepos);

%% means ratio
meansratio=squeeze(sum(sum(data.data)))./squeeze(sum(sum(prediction.data)));
dlmwrite(strcat(ID,'/meansratio.csv'),meansratio);

%% mean error
meanerror=squeeze(sum(sum(data.data-prediction.data)))./voxcount;
meanerror=(meanerror - nanmean(meanerror(:)))/nanstd(meanerror(:));
dlmwrite(strcat(ID,'/meanerror.csv'),meanerror);

%% mean absolute error
meanabsoluteerror=squeeze(sum(sum(abs(data.data-prediction.data))))./voxcount;
meanabsoluteerror=(meanabsoluteerror - nanmean(meanabsoluteerror(:)))/nanstd(meanabsoluteerror(:));
dlmwrite(strcat(ID,'/meanabsoluteerror.csv'),meanabsoluteerror);

%% root mean squared error
rootmeansquarederror=sqrt(squeeze(sum(sum((data.data-prediction.data).^2)))./voxcount);
rootmeansquarederror=(rootmeansquarederror-nanmean(rootmeansquarederror(:)))/nanstd(rootmeansquarederror(:));
dlmwrite(strcat(ID,'/rootmeansquarederror.csv'),rootmeansquarederror);

%% slope of regression line
slope=squeeze(sum(sum(data.data.*prediction.data)) ./ sum(sum(prediction.data.^2)));
dlmwrite(strcat(ID,'/slope.csv'),slope);

%% correlation coefficient
correlation=NaN(size(slicepos));
for niter=1:size(slicepos,2)
    for ziter=1:size(slicepos,1)
        tmp1 = data.data(:,:,ziter,niter);
        tmp2 = prediction.data(:,:,ziter,niter);
        if sum(sum(mask(:,:,ziter,niter)))
            correlation(ziter,niter) = corr(tmp1(mask(:,:,ziter,niter)==1),tmp2(mask(:,:,ziter,niter)==1));
        end
    end
end
dlmwrite(strcat(ID,'/correlation.csv'),correlation)