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

```sh
# Easiest route (internet access needed)
apptainer build spotlight.sif docker://joank23/spotlight
apptainer build immunedeconvr.sif docker://joank23/immunedeconvr

# Alternative route
# Usecase: if working on an HPC that does not have docker & internet access for building the image

# A) on you local desktop
# 1. save docker as tar or tar.gz (compressed)
docker pull joank23/spotlight
docker pull joank23/immunedeconvr

docker save joank23/spotlight > spotlight.tar
docker save joank23/immunedeconvr > immunedeconvr.tar

# 2. Move to HPC (optionally)
# 3. Build apptainer images (.sif) from docker (.tar) 
apptainer build spotlight.sif docker-archive:spotlight.tar
apptainer build immunedeconvr.sif docker-archive:immunedeconvr.tar

```

2. Download retrained models to extract the histopathological features, available from Fu et al., Nat Cancer, 2020
   1. Download from ([Retrained_Inception_v4](https://www.ebi.ac.uk/biostudies/bioimages/studies/S-BSST292))
   2. Unzip the folder
   3. Extract the files to a folder called `Retrained_Inception_v4`.

> IMPORTANT: Please rename your images file names, so they only include "-", to follow the same sample coding used by the TCGA.

## TCGA SKCM dataset

### FF slides

> Please note, the models used were built using the FF slides, therefore this is only to demonstrate how one would run the pipeline (modules mentioned above) with FF slides. 

1. Download **tissue slides** from the [GDC Data Portal](https://portal.gdc.cancer.gov/projects/TCGA-SKCM).
2. Adapt the param file [example_workflow_params.yml](../assets/example_workflow_params.yml)
   1. Set `slide_type='FF'` and `is_tcga=true`. 
   2. Set remaining parameters as indicated in the yml
3. Adapt Nexflow configuration file accordingly, example see [nf-custom.config](../nf-custom.config)
4. Run pipeline as follows:

```bash
# Assuming you're in the cloned/forked GitHub repo
nextflow run SysBioOncology/SPoTLIghT -profile apptainer -c <path-to-nf-config> -params-file <path-to-params-yml> --outdir "output-tcga-skcm-ff"
```

> Note you can change `--outdir` and you can add additional profiles (-profile).

## FFPE slides

1. Download **diagnostic slides** from the [GDC Data Portal](https://portal.gdc.cancer.gov/projects/TCGA-SKCM).
2. Adapt the param file [example_workflow_params.yml](../assets/example_workflow_params.yml), 
   1. Set `image_dir`, `slide_type="FFPE"` and `is_tcga=true`. 
   2. Set remaining parameters as indicated in the yml
3. Adapt Nexflow configuration file accordingly, example see [nf-custom.config](../nf-custom.config)
4. Run pipeline as follows:

```bash
# Assuming you're in the cloned/forked GitHub repo
nextflow run SysBioOncology/SPoTLIghT -profile apptainer -c <path-to-nf-config> -params-file <path-to-params-yml> --outdir "output-tcga-skcm-ffpe"
```

> Note you can change `--outdir` and you can add additional profiles (-profile).

## CPTAC melanoma cohort

1. Download H&E images (FFPE) and clinical data [here](https://www.cancerimagingarchive.net/collection/cptac-cm/).
2. Adapt the param file [example_workflow_params.yml](../assets/example_workflow_params.yml), 
   1. Set `slide_type="FFPE"` and `is_tcga=false`. 
   2. Set remaining parameters as indicated in the yml
3. Adapt Nexflow configuration file accordingly, example see [nf-custom.config](../nf-custom.config)
4. Run pipeline as follows:

```bash
# Assuming you're in the cloned/forked GitHub repo
nextflow run SysBioOncology/SPoTLIghT -profile apptainer -c <path-to-nf-config> -params-file <path-to-params-yml> --outdir "output-cptac"
```
> Note you can change `--outdir` and you can add additional profiles (-profile). 

## Xenium melanoma datasets from 10x Genomics

1. Download the two H&E datasets (FFPE) here:
   1. [Human SKCM data with standard skin gene expression panel with add-on panel](https://www.10xgenomics.com/datasets/human-skin-preview-data-xenium-human-skin-gene-expression-panel-add-on-1-standard)
   2. [Human SKCM data with standard skin gene expression panel](https://www.10xgenomics.com/datasets/human-skin-preview-data-xenium-human-skin-gene-expression-panel-1-standard).
1. Adapt the param file [example_workflow_params.yml](../assets/example_workflow_params.yml)
   1. Set `slide_type="FFPE"` and `is_tcga=false`.
   2. Set remaining parameters as indicated in the yml
2. Adapt Nexflow configuration file accordingly, example see [nf-custom.config](../nf-custom.config)
3. Run pipeline as follows:

```bash
# Assuming you're in the cloned/forked GitHub repo
nextflow run SysBioOncology/SPoTLIghT -profile apptainer -c <path-to-nf-config> -params-file <path-to-params-yml> --outdir "output-xenium"
```

> Note you can change `--outdir` and you can add additional profiles (-profile). 