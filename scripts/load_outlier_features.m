function [features,labels] = load_outlier_features(ID)
% DESCRIPTION: loads the features and labels for slicewise outlier detection
% INPUT: list - structure obtained from dir()
% OUTPUT: features - Nx8 matrix
% 	  labels - Nx1 matrix

voxelcount=[]; sliceposition=[]; meansratio=[]; meanerror=[];
meanabsoluteerror=[]; rootmeansquarederror=[]; slope=[];
correlation=[]; label=[];
voxelcount=[voxelcount; load(strcat(ID,'/voxelcount_normalised.csv'))];
sliceposition=[sliceposition; load(strcat(ID,'/slicepos.csv'))];
meansratio=[meansratio; load(strcat(ID,'/meansratio.csv'))];
meanerror=[meanerror; load(strcat(ID,'/meanerror.csv'))];
meanabsoluteerror=[meanabsoluteerror; load(strcat(ID,'/meanabsoluteerror.csv'))];
rootmeansquarederror=[rootmeansquarederror; load(strcat(ID,'/rootmeansquarederror.csv'))];
slope=[slope; load(strcat(ID,'/slope.csv'))];
correlation=[correlation; load(strcat(ID,'/correlation.csv'))];
if (exist(strcat(ID,'/manual.csv'),'file'))
    label=[label; load(strcat(ID,'/manual.csv'))];
end

features=[voxelcount(:) sliceposition(:) meansratio(:) meanerror(:) ... 
    meanabsoluteerror(:) rootmeansquarederror(:) slope(:) correlation(:)];
labels=label(:);
