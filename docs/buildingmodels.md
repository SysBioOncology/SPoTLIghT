# Building the cell type models using TCGA datasets

Guide on how to build cell type models using TCGA datasets with FF slides. Here, all spotlight modules are used (see [spotlight modules](spotlightmodules.md)).

## Set up containers

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
## Guide
1. Download metadata/clinical data, i.e. "biospecimen -> TSV", unzip and keep slide.tsv, then rename `slide.tsv` to `clinical_file_TCGA_{cancer_type_abbrev}` such as `clinical_file_TCGA_SKCM.tsv` and copy to `/data`. Example dataset TCGA-SKCM can be downloaded [here](https://portal.gdc.cancer.gov/projects/TCGA-SKCM).
2. Download TCGA bulkRNAseq data via the [Firehose Tool](https://gdac.broadinstitute.org) from the BROAD Institute, the files required are: "illuminahiseq_rnaseqv2-RSEM_genes" and unzip the downloaded file (.tar.gz)
4. Download **tissue slides** from the [GDC Data Portal](https://portal.gdc.cancer.gov/projects) and store in a folder.
5. Download retrained models to extract the histopathological features, available from Fu et al., Nat Cancer, 2020 ([Retrained_Inception_v4](https://www.ebi.ac.uk/biostudies/bioimages/studies/S-BSST292)). Once you unzip the folder, extract the files to the `data/checkpoint/Retrained_Inception_v4/` folder.
6. Download the signatures/published scores in the table provided [here](spotlightmodules.md#building-a-multi-task-cell-type-model-to-predict-cell-type-abundances-on-a-tile-level-buildmodel).
7. Adapt the parameters file [nf-params-buildmodel.yml](../assets/examples/nf-params-buildmodel.yml).
8. Adapt Nexflow configuration file accordingly, example see [nf-custom.config](../nf-custom.config)

```bash
# Assuming you're in the cloned/forked GitHub repo
nextflow run ${PWD} -profile apptainer -c "nf-custom.config" -params-file assets/examples/nf-params-buildmodel.yml -outdir "output-tcga-model"
```

> Please rename your images file names, so they only include "-", to follow the same sample coding used by the TCGA.

> NOTE: there are additional parameters that can be changed, [nf-params-buildmodel.yml](../assets/examples/nf-params-buildmodel.yml) includes the minimal parameters that need to be set. For the other parameters please check [spotlightmodules](spotlightmodules.md).