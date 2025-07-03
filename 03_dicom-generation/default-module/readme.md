# Create Dicom Module

This is the default module for Dicom Creation. It converts processed NIfTI files into DICOMs compatible with BrainLab and StealthStation software.

It requires that input nifti images are Int16 and has not been tested for all scanner models.

## Installation

Make sure to update the output directory path in paths.sh before use 

## Use 

This is automatically triggered. You should not need to call this directly.

## Help!

### Dicom Creation prints lots of stuff out

So long as it just says warning, that's probably normal. It is a tad overzealous.

### My Dicoms are all dark or all white, or are 'saturated' (large black/white spots)

Capture the nifi that is fed in here first. Check that it looks ok, that it has no NaN or infinity values.

If the nifti is ok, then normalization is failing in the DicomCreate executable somehow. Use your own normalisation strategy and turn of normalisation for DicomCreate.

### My Dicoms are cropped off at the top or bottom, or upside down

Check the nifti is ok.

If so, check you are feeding in the top slice of the fgatir dicom into this step. If you are, try the bottom.

If your images are upside down or rotated 90 degrees there is an issue with the way the header is being intepreted by the CreateDicom step. Try an axially-acquired image from another scanner or orientation to see what happens.