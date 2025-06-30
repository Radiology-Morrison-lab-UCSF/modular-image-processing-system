import SimpleITK
import argparse, sys, os, shutil
import ants
from run_executable import RunExecutable
import tempfile

class QSMPostProcessor():

    def __init__(self, dir_input:str, dir_output:str, filename_qsm:str):
        self.dir_input = dir_input
        self.dir_output = dir_output
        self.loc_qsm = os.path.join(dir_input,  filename_qsm)
        self.loc_t1_qsmSpace = os.path.join(dir_input,  "t1.nii")
        self.loc_qsm_brainmask = os.path.join(dir_input,  "qsm-brainmask.nii.gz")
        self.dir_fgatir_dicoms = os.path.join(dir_input, "dicoms", "fgatir")
        self.dir_qsm_dicoms = os.path.join(dir_input, "dicoms", "qsm")

        self.loc_qsm_fgatirSpace = os.path.join(dir_output, "qsm-post-processed.nii")
        self.loc_mag_fgatirSpace = os.path.join(dir_output, "mag-fgatirSpace.nii")
        self.loc_magToFgatir_mat = os.path.join(dir_output, "mag-to-fgatir.mat") 
        self.loc_fgatir = os.path.join(dir_output, "fgatir.nii.gz")
        self.loc_t1ToFgatir_mat = os.path.join(dir_output, "t1-to-fgatir.mat") 
        self.loc_t1_fgatirSpace = os.path.join(dir_output, "t1-fgatirSpace.nii.gz") 

        self.dir_out_dicoms = os.path.join(dir_output, "dicoms-qsm-fgatir-space")

        self._AssertExists(self.loc_qsm)
        self._AssertExists(self.dir_fgatir_dicoms)
        self._AssertExists(self.loc_qsm_brainmask)
        self._AssertExists(self.loc_t1_qsmSpace)


    def _AssertExists(self, loc):
        if not os.path.exists(loc):
            raise FileNotFoundError("Missing " + loc)


    def Process(self):
        qsm = self.ReadQSMIm()

        self.ConvertFGATIRDicoms()
        self.RegisterToFGATIR(qsm, self.loc_qsm_fgatirSpace)
        self.GenerateDicoms()


    def ReadQSMIm(self) -> SimpleITK.Image:
        return SimpleITK.ReadImage(self.loc_qsm)


    def GetQSMMag(self) -> SimpleITK.Image:
        origFiles = os.listdir(self.dir_qsm_dicoms)
        RunExecutable("dcm2niix", ["-z", "y", 
                                    "-b", "n", 
                                    self.dir_qsm_dicoms])
        new_files = [f for f in os.listdir(self.dir_qsm_dicoms) if f not in origFiles]
        try:
            mag_0 = os.path.join(self.dir_qsm_dicoms, [f for f in new_files if f.endswith("_e1.nii.gz")][0])
            return SimpleITK.ReadImage(mag_0)
        finally:
            for fn in new_files:
                os.remove(os.path.join(self.dir_qsm_dicoms,fn))


    def ConvertFGATIRDicoms(self):
        if os.path.exists(self.loc_fgatir):
            print("Found:", self.loc_fgatir, "- not regenerated")
            return
        
        RunExecutable("dcm2niix", ["-z", "y", 
                                    "-b", "n", 
                                    self.dir_fgatir_dicoms])

        locs_niftis = [f for f in os.listdir(self.dir_fgatir_dicoms) if f.endswith(".nii.gz")]
        if len(locs_niftis) != 1:
            raise Exception("Expected single nifti when converting fgatir but got:" + " ".join(locs_niftis))
        
        os.rename(os.path.join(self.dir_fgatir_dicoms, locs_niftis[0]), self.loc_fgatir)


    def SkullstripFGATIR(self):
        if os.path.exists(self.loc_fgatir_brainmask):
            print("found:", self.loc_fgatir_brainmask, "- not regenerated")
            return
        

    def ITKToAntsIm(self, itkIm:SimpleITK.Image):
        '''
        Converts ITK Image to an Ants image
        '''
        # Get temp file name ending in .nii
        loc_temp = tempfile.mktemp(suffix='.nii')

        try:
            # Write to temp file name location 
            SimpleITK.WriteImage(itkIm, loc_temp)

            return ants.image_read(loc_temp)    
        finally:
            if os.path.exists(loc_temp):
                os.remove(loc_temp)


    def RegisterQSMMagToFGATIR(self, mag):
        if os.path.exists(self.loc_mag_fgatirSpace):
            print("found:", self.loc_mag_fgatirSpace, " - Not regenerated")
            return

        fixed = ants.image_read(self.loc_t1_fgatirSpace)

        moving = self.ITKToAntsIm(mag)
        #moving_mask = ants.image_read(self.loc_qsm_brainmask)

        # initialise with the t1 to fgatir which should be very close to perfect
        # we are just recalculating because of errors seen in some cases between
        # t1 -> mag in earlier stages
        result = ants.registration(fixed, moving, "Rigid",
                                initial_transform=[self.loc_t1ToFgatir_mat],
                                verbose=True, 
                                aff_iterations = (1200, 50, 50),
                                aff_shrink_factors = (2, 1, 1),
                                aff_smoothing_sigmas = (1, 1, 0)                                
                                )

        mag_aligned_to_fgatir:ants.ants_image.ANTsImage = result["warpedmovout"]

        ants.image_write(mag_aligned_to_fgatir, self.loc_mag_fgatirSpace)
        
        transform = result["fwdtransforms"][0] 
        os.rename(transform, self.loc_magToFgatir_mat)


    def RegisterT1ToFGATIR(self) -> ants.ANTsTransform:
        if os.path.exists(self.loc_t1ToFgatir_mat):
            print("found:", self.loc_t1ToFgatir_mat, " - Not regenerated")
        else:
            
            print("Registering T1 to fgatir")
                
            fixed = ants.image_read(self.loc_fgatir)
            moving = ants.image_read(self.loc_t1_qsmSpace)
            moving_mask = ants.image_read(self.loc_qsm_brainmask)

            # use affine because ants has a habit of doing better 'not getting stuck' with affine
            result = ants.registration(fixed, moving, "Affine", 
                                    moving_mask=moving_mask, 
                                    mask_all_stages=True, 
                                    verbose=True)

            t1_aligned_to_fgatir:ants.ants_image.ANTsImage = result["warpedmovout"]

            ants.image_write(t1_aligned_to_fgatir, self.loc_t1_fgatirSpace)

            os.rename(result["fwdtransforms"][0], self.loc_t1ToFgatir_mat)


    def RegisterToFGATIR(self, im, loc_qsm_fgatirSpace) -> SimpleITK.Image:
        if os.path.exists(loc_qsm_fgatirSpace):
            print("found:", loc_qsm_fgatirSpace, " - Not regenerated")
            return
        
        print("Registering to fgatir")

        # Align the T1 to fgatir
        # This should work well.     
        print("T1 --> FGATIR")
        self.RegisterT1ToFGATIR()

        # The above T1 is often already aligned to the QSM
        # but this initial regisration isn't always perfect
        # so use that initial registration to initiate a
        # registration with the fgatir and recompute
        mag = self.GetQSMMag()
        #self.RegisterToFGATIR(mag, self.loc_mag_fgatirSpace)
        print("QSM --> FGATIR")
        self.RegisterQSMMagToFGATIR(mag)

        transform = ants.read_transform(self.loc_magToFgatir_mat)


        moving = self.ITKToAntsIm(im)
        fixed = ants.image_read(self.loc_fgatir)

        qsm_aligned_to_fgatir = ants.apply_ants_transform_to_image(transform, moving, fixed)

        ants.image_write(qsm_aligned_to_fgatir, loc_qsm_fgatirSpace)


    def GenerateDicoms(self):

        RunExecutable(r"CreateDicom.exe", 
                      [os.path.join(self.dir_fgatir_dicoms,"1.3.6.1.4.1.20319.107589589478606857824982201572271859121.dcm"),
                      self.loc_qsm_fgatirSpace,
                      self.dir_out_dicoms,
                      "QSM-Aligned-To-FGATIR"])


    # def Denoise(self, im: SimpleITK.Image) -> SimpleITK.Image:
    #     print("Denoising")
    #     return SimpleITK.PatchBasedDenoising(im)


    def SaveResult(self, im: SimpleITK.Image):
        print("Saving to ", self.loc_qsm_fgatirSpace)
        SimpleITK.WriteImage(im, self.loc_qsm_fgatirSpace, useCompression=self.loc_qsm_fgatirSpace[-3:]==".gz")


def parse_args():
    p = argparse.ArgumentParser(description="Process input and output directories.")
    p.add_argument("input_dir", help="Path to input directory")
    p.add_argument("output_dir", help="Path to output directory")

    if len(sys.argv) == 1:
        p.print_help()
        sys.exit(1)
    return p.parse_args()


def check_cmd(cmd):
    '''Checks a command can be found'''
    if not shutil.which(cmd, mode=os.F_OK | os.X_OK):
        print(f"Error: '{cmd}' not found in PATH. Did you run install?")
        sys.exit(1)


def check_inputs_and_env(args):
    '''Checks user arguments are OK and needed resources can be found'''
    if not os.path.isdir(args.input_dir):
        print(f"Error: input directory '{args.input_dir}' does not exist.")
        sys.exit(1)
    if not os.path.isdir(args.output_dir):
        print(f"Error: output directory '{args.output_dir}' does not exist.")
        sys.exit(1)

    check_cmd("dcm2niix")
    check_cmd("CreateDicom")


if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("Use -h or --help for usage.")
        sys.exit(1)

    args = parse_args()
    check_inputs_and_env(args)
    QSMPostProcessor(args.input_dir, args.output_dir, "sub-mysubj_Chimap.nii").Process()
