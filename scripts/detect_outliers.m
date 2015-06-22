function detect_outliers(ID)

% slicewise detection
slicewise_outlier_features(ID)
load('RF_trained.mat')
load(strcat(ID,'/meansratio.csv'));
[zdim,tdim]=size(meansratio);

[features,~] = load_outlier_features(ID);
p = str2num(cell2mat(predict(RF_trained,features)));
dlmwrite(strcat(ID,'/automatic.csv'),reshape(p,zdim,tdim))


% voxelwise detection
get_tfce_maps(ID)

% outlier map
load(strcat(ID,'/automatic.csv'))
tfcepos=read_mrtrix(strcat(ID,'/tfce_positive.mif'));
tfceneg=read_mrtrix(strcat(ID,'/tfce_negative.mif'));

outliermask=tfcepos;
outliermask.data=tfcepos.data+tfceneg.data;
outliermask.data=outliermask.data>15;
for ziter=1:zdim
    for titer=1:tdim
        if automatic(ziter,titer)
            outliermask.data(:,:,ziter,titer)=1;
        end
    end
end

write_mrtrix(outliermask,strcat(ID,'/outliers.mif'))
