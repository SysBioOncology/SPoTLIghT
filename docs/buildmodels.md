# Building the cell type models using TCGA datasets

Guide on how to build cell type models using TCGA datasets with FF slides. Here, all spotlight modules are used (see [spotlight modules](spotlightmodules.md)).

## Set up containers

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

## Guide

1. Download metadata/clinical data, i.e. "biospecimen -> TSV", unzip and keep slide.tsv, then rename `slide.tsv` to `clinical_file_TCGA_{cancer_type_abbrev}` such as `clinical_file_TCGA_SKCM.tsv` and copy to `/data`. Example dataset TCGA-SKCM can be downloaded [here](https://portal.gdc.cancer.gov/projects/TCGA-SKCM).
2. Download TCGA bulkRNAseq data via the [Firehose Tool](https://gdac.broadinstitute.org) from the BROAD Institute, the files required are: "illuminahiseq_rnaseqv2-RSEM_genes" and unzip the downloaded file (.tar.gz)
3. Download **tissue slides** from the [GDC Data Portal](https://portal.gdc.cancer.gov/projects) and store in a folder.
4. Download the signatures/published scores in the table below.
5. Adapt the parameters file [example_buildmodel_params.yml](../assets/example_buildmodel_params.yml).
6. Adapt Nexflow configuration file accordingly, example see [nf-custom.config](../nf-custom.config)

| Parameter                    | Reference                                                   | Additional info                                                                                                                                                  |
| ---------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `absolute_tumor_purity_path` | <https://gdc.cancer.gov/about-data/publications/panimmune>  | Download the 'Score for 160 Genes Signatures in Tumor Samples' or use [direct link]( https://api.gdc.cancer.gov/data/80a82092-161d-4615-9d96-e858f113618d)       |
| `estimate_scores_path`       | <https://bioinformatics.mdanderson.org/estimate/index.html> | Download the relevant file for the cancer type of interest, use the RNA-seqV2 column on the page.                                                                |
| `gibbons_scores_path`        | <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5503821/>     | Download the 'Supp Datafile S1.' or use the [direct link](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5503821/bin/NIHMS840944-supplement-Supp_Datafile_S1.xlsx) |
| `thorsson_scores_path`       | <https://gdc.cancer.gov/about-data/publications/panimmune>  | Download the 'ABSOLUTE purity/ploidy file', or use [direct link](https://api.gdc.cancer.gov/data/4f277128-f793-4354-a13d-30cc7fe9f6b5)                           |


```bash
# Assuming you're in the cloned/forked GitHub repo
nextflow run ${PWD} -profile apptainer -c "nf-custom.config" -params-file assets/examples/nf-params-buildmodel.yml -outdir "output-tcga-model"
```

> Please rename your images file names, so they only include "-", to follow the same sample coding used by the TCGA.

> NOTE: there are additional parameters that can be changed, [nf-params-buildmodel.yml](../assets/examples/nf-params-buildmodel.yml) includes the minimal parameters that need to be set. For the other parameters please check [spotlightmodules](spotlightmodules.md).