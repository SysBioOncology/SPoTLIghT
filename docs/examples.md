# Use-case examples SKCM datasets

How to extract spatial features from the publicly available H&E datasets used in the paper using the built [SKCM models](../assets/TF_models) based on the TCGA SKCM fresh-frozen slides.


Examples:
- [Use-case examples SKCM datasets](#use-case-examples-skcm-datasets)
  - [TCGA SKCM dataset](#tcga-skcm-dataset)
    - [FF slides](#ff-slides)
  - [FFPE slides](#ffpe-slides)
  - [CPTAC melanoma cohort](#cptac-melanoma-cohort)
  - [Xenium melanoma datasets from 10x Genomics](#xenium-melanoma-datasets-from-10x-genomics)

Spotlight modules used in the examples:

* Extracting histopathological features (`extracthistopatho`)
* Predicting tile-level cell type abundances using the multi-task models (`predicttiles`)
* Compute spatial features using the tile-level cell type abundances (`computespatial`)

**Set up (required)**

1. Create apptainer/singularity containers from Docker images:

```bash
# 1. save docker as tar or tar.gz (compressed)
docker save joank23/spotlight -o spotlight.tar.gz
# 2. build apptainer (.sif) from docker (.tar)
apptainer build spotlight.sif docker-archive:spotlight.tar.gz

# 1. save docker as tar or tar.gz (compressed)
docker save joank23/immunedeconvr -o immunedeconvr.tar.gz
# 2. build apptainer (.sif) from docker (.tar)
apptainer build immunedeconvr.sif docker-archive:immunedeconvr.tar.gz

```

2. Download retrained models to extract the histopathological features, available from Fu et al., Nat Cancer, 2020 ([Retrained_Inception_v4](https://www.ebi.ac.uk/biostudies/bioimages/studies/S-BSST292)). Once you unzip the folder, extract the files to the `data/checkpoint/Retrained_Inception_v4/` folder.

> IMPORTANT: Please rename your images file names, so they only include "-", to follow the same sample coding used by the TCGA.

## TCGA SKCM dataset

### FF slides

> Please note, the models used were built using the FF slides, therefore this is only to demonstrate how one would run the pipeline (modules mentioned above) with FF slides. 

1. Download **tissue slides** from the [GDC Data Portal](https://portal.gdc.cancer.gov/projects/TCGA-SKCM).
2. Adapt the param file [nf-params-examples.yml](../assets/examples/nf-params-examples.yml), i.e. set `image_dir` and `slide_type`. All other parameters are default and do not have to be changed (see default parameters [here](../nextflow.config)). 
3. Adapt Nexflow configuration file accordingly, example see [nf-custom.config](../nf-custom.config)
4. Run pipeline as follows: 

```bash
# Assuming you're in the cloned/forked GitHub repo
nextflow run ${PWD} -profile apptainer -c "nf-custom.config" -params-file assets/examples/nf-params-examples.yml -outdir "output-tcga-skcm-ff"
```
> Note you can change `-outdir` and you can add additional profiles (-profile).


## FFPE slides

1. Download **diagnostic slides** from the [GDC Data Portal](https://portal.gdc.cancer.gov/projects/TCGA-SKCM).
2. Adapt the param file [nf-params-examples.yml](../assets/examples/nf-params-examples.yml), i.e. set `image_dir` and `slide_type="FFPE"`. All other parameters are default and do not have to be changed (see default parameters [here](../nextflow.config)).
3. Adapt Nexflow configuration file accordingly, example see [nf-custom.config](../nf-custom.config)
4. Run pipeline as follows: 

```bash
# Assuming you're in the cloned/forked GitHub repo
nextflow run ${PWD} -profile apptainer -c "nf-custom.config" -params-file assets/examples/nf-params-examples.yml -outdir "output-tcga-skcm-ffpe"
```
> Note you can change `-outdir` and you can add additional profiles (-profile).

## CPTAC melanoma cohort

1. Download H&E images (FFPE) and clinical data [here](https://www.cancerimagingarchive.net/collection/cptac-cm/).
2. Adapt the param file [nf-params-examples.yml](../assets/examples/nf-params-examples.yml), i.e. set `image_dir` and `slide_type="FFPE"`. All other parameters are default and do not have to be changed (see default parameters [here](../nextflow.config)). 
3. Adapt Nexflow configuration file accordingly, example see [nf-custom.config](../nf-custom.config)
4. Run pipeline as follows: 

```bash
# Assuming you're in the cloned/forked GitHub repo
nextflow run ${PWD} -profile apptainer -c "nf-custom.config" -params-file assets/examples/nf-params-examples.yml -outdir "output-cptac"
```
> Note you can change `-outdir` and you can add additional profiles (-profile). 


## Xenium melanoma datasets from 10x Genomics

1. Download the two H&E datasets (FFPE) here: [Human SKCM data with standard skin gene expression panel with add-on panel](
https://www.10xgenomics.com/datasets/human-skin-preview-data-xenium-human-skin-gene-expression-panel-add-on-1-standard)
and [Human SKCM data with standard skin gene expression panel](https://www.10xgenomics.com/datasets/human-skin-preview-data-xenium-human-skin-gene-expression-panel-1-standard
).
2. Adapt the param file [nf-params-examples.yml](../assets/examples/nf-params-examples.yml),i.e. set `image_dir` and `slide_type="FFPE"`. All other parameters are default and do not have to be changed (see default parameters [here](../nextflow.config)). 
3. Adapt Nexflow configuration file accordingly, example see [nf-custom.config](../nf-custom.config)
4. Run pipeline as follows: 

```bash
# Assuming you're in the cloned/forked GitHub repo
nextflow run ${PWD} -profile apptainer -c "nf-custom.config" -params-file assets/examples/nf-params-examples.yml -outdir "output-xenium"
```

> Note you can change `-outdir` and you can add additional profiles (-profile). 
