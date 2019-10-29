[![DOI](https://zenodo.org/badge/160351501.svg)](https://zenodo.org/badge/latestdoi/160351501)

# NARPS_CPPL
Code for the CPPL participation to NARPS

Some of the MRIQC and fMRIprep output was integrated to this repository in the folder `/inputs` to make it standalone.

## Running the analysis

See further down for more info about docker and containers.

You can specify to the container where your code and data are when you call it.
- the folder that will be mapped onto `code` must contain this repository
- the folder that will be mapped onto `data` must contain the NARPS data (the folder that contains both the BIDS raw dataset and the fMRIprep derivatives)
- the folder that will be mapped onto `output` can be any folder you wish. The container will simply create a `/derivatives/spm12` folder in it to put the data.

Below are the commands examples we used to run this analysis

### Start the docker image
Run the following to start the octave-SPM docker image. The equivalent docker image has been uploaded to [docker hub](https://cloud.docker.com/repository/docker/remigau/cppl-narps/general) for better reproducibility as docker images are not tagged on the SPM docker hub repository.

```
docker run -it --rm \
--entrypoint /bin/sh \
-v /Data/NARPS:/data:ro \
-v /Data/NARPS/NARPS_CPPL:/code/ \
-v /Data/NARPS:/output \
spmcentral/spm:octave-latest

```


This will start octave and move you to the correct directory:
```
octave
cd /code
```

### Copy and unzipping data
Type in the following command to copy the relevant files and unzip them:
`step_1_copy_and_unzip_files`


### Smoothing the data
Type in the following command to copy the relevant files and unzip them:
`step_2_smooth_func_files.m`


### Running the subject level GLM
Type in the following command to copy the relevant files and unzip them:
`step_3_run_first_level.m`


### Quality control
Several scripts were created to vizualize participants' reactions times, or fMRIprep and MRIQC outputs.

For example:

All the `quality_control*.m` scripts.

`make_figures_RT.m` collects subject RT and plots how they are distributed across gain and loss on average at the group level and for each subject. It also checks overall distributions of RT for each subjects and missed responses.

`make_figures_accept_reject.m` collects subject responses (1 = weak accept ; 2 = strong accept ; -1 = weak reject ; -2 = strong reject) and plots how they are distributed across gain and loss on average at the group level and for each subject



### Running the group level GLM
Type in the following command to copy the relevant files and unzip them:
`step_4_run_second_level.m`

Subjects kicked out:
- 56: switched behavioral response
- 16, 30, 88, 100: too much movement on a single run
- 18, 22, 110, 116: too much movement overall
- 31: "noisy" anatomical scan

For the moment, this is hard-coded (don't 8 me!) in the rm_subjects.m function.

The group level analysis will be found in the `/derivatives/spm12/group/GLM*` folder.

Each group or between group analysis are in different subfolders.

The following folders contain the relevant group level GLMs:
- `ttest_gamble_trialxgain_sup_baseline` : positive parametric effect of gain
- `ttest_gamble_trialxloss_inf_baseline` : negative parametric effect of loss
- `ttest_gamble_trialxloss_sup_baseline` : positive parametric effect of loss

There is only one contrast of interest per group analysis.


### Making ROIs from neurosynth
The script `create_ROIs.m` will create the ROIs used to test each hypothesis.


### pTFCE enhancement of the final results.
Each of the 9 contrasts corresponding to the 9 hypothesis tested were enhanced using the [pTFCE toolbox](https://github.com/spisakt/pTFCE/releases/tag/v0.1.3). This was run on windows 10 with matlab 2018b as we could not incorporate it into the docker.


### Final inference
Display the results for each hypothesis using the SPM GUI and the right ROI as inclusive mask to look for any activate voxel. This most likely will require matlab.
