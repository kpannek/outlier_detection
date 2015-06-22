function get_tfce_maps(ID)

data=read_mrtrix(strcat(ID,'/dwi.mif'));
[xdim,ydim,zdim,tdim]=size(data.data);

prediction=read_mrtrix(strcat(ID,'/prediction.mif'));

labels_slice=logical(load(strcat(ID,'/automatic.csv')));
mask=prediction.data>0;
for ziter=1:zdim
    for titer=1:tdim
        if labels_slice(ziter,titer)
            mask(:,:,ziter,titer)=0; % remove known outlier slices
        end
    end
end

residual=data.data-prediction.data;
zscore=(residual - mean(residual(mask)))/std(residual(mask)).*mask;
mif=data; mif.datatype='Float32LE';
mif.data=zscore; write_mrtrix(mif,strcat(ID,'/zscore.mif'));

tfce_pos = tfce(zscore,1,100,4,.5,2,2);
tfce_neg = tfce(zscore,-1,100,4,.5,2,2);

mif=data; mif.datatype='Float32LE';
mif.data=tfce_pos; write_mrtrix(mif,strcat(ID,'/tfce_positive.mif'));
mif.data=tfce_neg; write_mrtrix(mif,strcat(ID,'/tfce_negative.mif'));
