#!/bin/bash

if [ ! $# -eq 1 ]
then
    echo "Usage: ./run.sh <subjectID>"
    echo
    exit
fi

if [ ! -e $1 ]
then
    echo "subject $1 not found"
    exit
fi


cd $1
touch prediction.mif

echo "INFO: getting ready..."
dwiextract data.mif dwi.mif -quiet
mrconvert dwi.mif vol[].nii.gz -quiet
mrinfo dwi.mif -export_grad_mrtrix encoding.b -quiet

# initial registration to mean DWI (normalised mutual information)
echo "INFO: initial registration to mean DWI"
mrmath dwi.mif -axis 3 mean meandwi.nii.gz -quiet
for ((i=0; i<64; i++))
do
    echo -ne "...processing volume $i \r"
    rreg meandwi.nii.gz vol`zeropad $i 2`.nii.gz -dofout vol`zeropad $i 2`.dof > /dev/null
    transformation vol`zeropad $i 2`.nii.gz vol`zeropad $i 2`_reg.nii.gz -dofin vol`zeropad $i 2`.dof -target meandwi.nii.gz -bspline > /dev/null
done
mrcat vol??_reg.nii.gz -axis 3 it0.mif -quiet

# registration to synthetic images (cross correlation)
echo "INFO: registration to synthetic images (iteration 1)"
amp2sh it0.mif -grad encoding.b -lmax 4 - -quiet | sh2amp - -gradient encoding.b syn.mif -quiet
mrconvert syn.mif target[].nii.gz -quiet
rm *.dof *reg.nii.gz syn.mif

echo "Similarity measure = CC" > par.in
for ((i=0; i<64; i++))
do
    echo -ne "...processing volume $i \r"
    rreg target`zeropad $i 2`.nii.gz vol`zeropad $i 2`.nii.gz -parin par.in -dofout vol`zeropad $i 2`.dof > /dev/null
    transformation vol`zeropad $i 2`.nii.gz vol`zeropad $i 2`_reg.nii.gz -dofin vol`zeropad $i 2`.dof -target target`zeropad $i 2`.nii.gz -bspline > /dev/null
done
rm target??.nii.gz
mrcat vol??_reg.nii.gz -axis 3 it1.mif -quiet

# second registration to synthetic images (cross correlation) 
echo "INFO: registration to synthetic images (iteration 2)"
amp2sh it1.mif -grad encoding.b -lmax 4 - -quiet | sh2amp - -gradient encoding.b syn.mif -quiet
mrconvert syn.mif target[].nii.gz -quiet
rm *.dof *reg.nii.gz syn.mif

echo "Similarity measure = CC" > par.in
for ((i=0; i<64; i++))
do
    echo -ne "...processing volume $i \r"
    rreg target`zeropad $i 2`.nii.gz vol`zeropad $i 2`.nii.gz -parin par.in -dofout vol`zeropad $i 2`.dof > /dev/null
    transformation vol`zeropad $i 2`.nii.gz vol`zeropad $i 2`_reg.nii.gz -dofin vol`zeropad $i 2`.dof -target target`zeropad $i 2`.nii.gz -bspline > /dev/null
done
rm target??.nii.gz
mrcat vol??_reg.nii.gz -axis 3 it2.mif -quiet



# SH (lmax=4) estimation, reorientation, and prediction
echo "INFO: estimating SH coefficients, reorienting and predicting"
amp2sh it2.mif -grad encoding.b -lmax 4 sh.mif -quiet
for ((i=0; i<64; i++))
do
    echo -ne "...processing volume $i \r"
    dof2mat vol`zeropad $i 2`.dof -invert | tail -n 4 > vol`zeropad $i 2`.RAS.txt
    mrtransform sh.mif -template vol`zeropad $i 2`.nii.gz -linear vol`zeropad $i 2`.RAS.txt sh_`zeropad $i 2`.mif -quiet
    
    sh2amp sh_`zeropad $i 2`.mif -gradient encoding.b tmp.mif -quiet
    mrconvert tmp.mif -coord 3 $i prediction`zeropad $i 2`.mif -quiet
    rm tmp.mif sh_`zeropad $i 2`.mif
done
rm prediction.mif
mrcat prediction??.mif -axis 3 prediction.mif -quiet

# cleaning up
mkdir dofs
mv *.dof *RAS.txt dofs/
rm prediction??.mif vol??.nii.gz vol??_reg.nii.gz it?.mif meandwi.nii.gz par.in

