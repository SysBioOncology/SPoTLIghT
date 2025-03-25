# eduatilab/spotlight: Usage

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Introduction

<!-- TODO nf-core: Add documentation about anything specific to running your pipeline. For general topics, please point to (and add to) the main nf-core website. -->

1. Extracting histopathological features (`extracthistopatho`).
2. Deconvolution of bulkRNAseq data (`deconvbulk`).
3. Building a multi-task cell type model to predict cell type abundances on a tile-level (`buildmodel`).
4. Predicting tile-level cell type abundances using the multi-task models (`predicttiles`).
5. Compute spatial features using the tile-level cell type abundances (`computespatial`).

In brackets, the abbreviations to use for running the modules of interest

If you want to run all modules, you can set the `spotlight_modules` parameter as follows:

```{yml}
spotlight_modules: "extracthistopatho, deconvbulk, buildmodel, predicttiles, computespatial"
```

> When running only a subset of modules, set the parameters required for those modules!

### Extracting histopathological features

Input files:

* `clinical_file_out_file` :
* `image_dir` : Directory with H&E images.
* `path_codebook` : Path to [codebook.txt](https://github.com/gerstung-lab/PC-CHiP/blob/b5ff01b56dbad9a5880529cdcf5e799e912534a2/inception/codebook.txt)
* `checkpoint_path`: checkpoints of DL model, see the Tensorflow repository [tensorflow/models](https://github.com/tensorflow/models/tree/master/research/slim#Pretrained). Checkpoint used in manuscript can be downloaded via this [link](https://www.ebi.ac.uk/biostudies/files/S-BSST292/Retrained_Inception_v4.zip) and can be found here: <https://www.ebi.ac.uk/biostudies/bioimages/studies/S-BSST292>. Of note, the path should point to the **directory** with the checkpoint files.
* `path_tissue_classes`: Path to [tissue_classes.csv](assets/tissue_classes.csv), which is provided.

* `tumor_purity_threshold` : Minimum tumor purity for a slide to be kept (default=80)
* `gradient_mag_filter` : Minimum gradient magnitude, used for filtering non-informative and/or blurry tiles (default=10)
* `n_shards` : number of shards for creating TFrecords (default=320)
* `bot_out_filename` : Filename for extracted histopathological features (default="bot_train")
* `pred_out_filename` : Filename for predictions (default="pred_train")
* `model_name` : Name of model used, ensure this corresponds to the model of the checkpoints (default="inception_v4")

### Deconvolution of bulkRNAseq data

* `gene_exp_path`: Path to gene expression file (`.txt`)
* `is_tpm`: Indicate whether given `gene_exp_path` is TPM normalized (default=false)

* `quantiseq_path`: Path to results quanTIseq (`.csv`)
* `epic_path`: Path to results EPIC (`.csv`)
* `mcp_counter_path`: Path to results MCP counter (`.csv`)
* `xcell_path`: Path to results xCELL (`.csv`)

> The above four files are optional, by default all tools will be run. If results for one or more tools have been generated already, please set the paths.

### Building a multi-task cell type model to predict cell type abundances on a tile-level

#### Set up

1. Download TCGA bulkRNAseq data via the [Firehose Tool](https://gdac.broadinstitute.org) from the BROAD Institute, the files required are: “illuminahiseq_rnaseqv2-RSEM_genes”.
2. Unzip the downloaded file (.tar.gz)
3. Download the signatures/published scores, see table below.

| Parameter                    | Reference                                                   | Additional info                                                                                                                                                  |
| ---------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `absolute_tumor_purity_path` | <https://gdc.cancer.gov/about-data/publications/panimmune>  | Download the 'Score for 160 Genes Signatures in Tumor Samples' or use [direct link]( https://api.gdc.cancer.gov/data/80a82092-161d-4615-9d96-e858f113618d)       |
| `estimate_scores_path`       | <https://bioinformatics.mdanderson.org/estimate/index.html> | Download the relevant file for the cancer type of interest, use the RNA-seqV2 column on the page.                                                                |
| `gibbons_scores_path`        | <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5503821/>     | Download the 'Supp Datafile S1.' or use the [direct link](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5503821/bin/NIHMS840944-supplement-Supp_Datafile_S1.xlsx) |
| `thorsson_scores_path`       | <https://gdc.cancer.gov/about-data/publications/panimmune>  | Download the 'ABSOLUTE purity/ploidy file', or use [direct link](https://api.gdc.cancer.gov/data/4f277128-f793-4354-a13d-30cc7fe9f6b5)                           |

4. Update the `nf-params.yml` for the following parameters: `thorsson_scores_path`,     `estimate_scores_path`,  `absolute_tumor_purity_path` and `gibbons_scores_path`.
5. Review other parameters relevant for this module in the same `yml` file. (see section below)
6. Run the pipeline, do not forget to include `buildmodel` in the `spotlight_modules` parameter.

#### Parameters

* `clinical_file_path`: Path to clinical file (`.csv`), at least have the following columns: 'sample_submitter_id' and 'slide_submitter_id'. If **module `extracthistopatho`** is run, setting this parameter is **optional**.

**Publicly available scores**

* `thorsson_scores_path`: "assets/local/Thorsson_Scores_160_Signatures.tsv"
* `estimate_scores_path`: "assets/local/ESTIMATE.xlsx"
* `absolute_tumor_purity_path`: "assets/local/TCGA_ABSOLUTE.txt"
* `gibbons_scores_path`: "assets/local/Gibbons.xlsx"
For more information please see the table in [modules/trainmultitaskmodel.md](./modules/trainmultitaskmodel.md)

* `bottleneck_features_path`: Path to extracted histopathological features, generated by **module `extracthistopatho`**
* `var_names_path`: "assets/task_selection_names.pkl"
* `target_features_path`: "assets/NO_FILE"
* `model_cell_types`: String of cell types for which a multi-task models has to be build (default="CAFs, Endothelial_cells, T_cells, tumor_purity").

> Please note, that models can only be build for the cell types mentioned in the default.

**Setup nested cross-validation**

* `alpha_min`: Min. value for grid, 10^alpha_min (default=-4)
* `alpha_max`: Max. value for grid, 10^alpha_max (default=-1)
* `n_steps`: Number of steps in grid (default=40)
* `n_outerfolds`: Number of outer folds (default=5)
* `n_innerfolds`: Number of inner folds(default=10)
* `n_tiles`: Number of tiles selected per slide (default=50)
* `split_level`: Variable to split data on (default="sample_submitter_id")

### Predicting tile-level cell type abundances using the multi-task models

* `celltype_models_path`: Path to directory with the models for each cell type, where each cell type has to have its own folder. For an example of the structure see provided models [assets/TF_models/SKCM_FF](../assets/TF_models/SKCM_FF)  (default="assets/TF_models/SKCM_FF")
`prediction_mode` : (default="test")

### Compute spatial features using the tile-level cell type abundances

* `out_prefix`: "dummy"

* `graphs_path`: Path to file (`.pkl`) with the graphs for all slides. Not required, if left default or if not set, this will be generated.
* `abundance_threshold` : Min. abundance (probability) for assigning cell type (default=0.5)
* `shapiro_alpha` : Significance level for shapiro test (normality) (default=0.05)
* `cutoff_path_length` : Max. path length (default=2)

* `n_clusters` : Number of clusters to generate (default = 8)
* `max_dist` : "dummy"
* `max_n_tiles_threshold` : 2
* `tile_size` : Size of tiles in pixels (default=512)
* `overlap` : Overlap of directly neighboring tiles (default=50)

* `metadata_path` : Path to file with metadata
* `merge_var` : Variable for merging metadata and spatial features, (default="slide_submitter_id")
* `sheet_name` : If `metadata_path` points to an Excel file, give the 'sheet_name' to read from.

## Samplesheet input

You will need to create a samplesheet with information about the samples you would like to analyse before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 3 columns, and a header row as shown in the examples below.

```bash
--input '[path to samplesheet file]'
```

### Multiple runs of the same sample

The `sample` identifiers have to be the same when you have re-sequenced the same sample more than once e.g. to increase sequencing depth. The pipeline will concatenate the raw reads before performing any downstream analysis. Below is an example for the same sample sequenced across 3 lanes:

```csv title="samplesheet.csv"
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
CONTROL_REP1,AEG588A1_S1_L003_R1_001.fastq.gz,AEG588A1_S1_L003_R2_001.fastq.gz
CONTROL_REP1,AEG588A1_S1_L004_R1_001.fastq.gz,AEG588A1_S1_L004_R2_001.fastq.gz
```

### Full samplesheet

The pipeline will auto-detect whether a sample is single- or paired-end using the information provided in the samplesheet. The samplesheet can have as many columns as you desire, however, there is a strict requirement for the first 3 columns to match those defined in the table below.

A final samplesheet file consisting of both single- and paired-end data may look something like the one below. This is for 6 samples, where `TREATMENT_REP3` has been sequenced twice.

```csv title="samplesheet.csv"
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
CONTROL_REP2,AEG588A2_S2_L002_R1_001.fastq.gz,AEG588A2_S2_L002_R2_001.fastq.gz
CONTROL_REP3,AEG588A3_S3_L002_R1_001.fastq.gz,AEG588A3_S3_L002_R2_001.fastq.gz
TREATMENT_REP1,AEG588A4_S4_L003_R1_001.fastq.gz,
TREATMENT_REP2,AEG588A5_S5_L003_R1_001.fastq.gz,
TREATMENT_REP3,AEG588A6_S6_L003_R1_001.fastq.gz,
TREATMENT_REP3,AEG588A6_S6_L004_R1_001.fastq.gz,
```

| Column    | Description                                                                                                                                                                            |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sample`  | Custom sample name. This entry will be identical for multiple sequencing libraries/runs from the same sample. Spaces in sample names are automatically converted to underscores (`_`). |
| `fastq_1` | Full path to FastQ file for Illumina short reads 1. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz".                                                             |
| `fastq_2` | Full path to FastQ file for Illumina short reads 2. File has to be gzipped and have the extension ".fastq.gz" or ".fq.gz".                                                             |

An [example samplesheet](../assets/samplesheet.csv) has been provided with the pipeline.

## Running the pipeline

The typical command for running the pipeline is as follows:

```bash
nextflow run eduatilab/spotlight --input ./samplesheet.csv --outdir ./results  -profile docker
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

If you wish to repeatedly use the same parameters for multiple runs, rather than specifying each flag in the command, you can specify these in a params file.

Pipeline settings can be provided in a `yaml` or `json` file via `-params-file <file>`.

> [!WARNING]
> Do not use `-c <file>` to specify parameters as this will result in errors. Custom config files specified with `-c` must only be used for [tuning process resource specifications](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources), other infrastructural tweaks (such as output directories), or module arguments (args).

The above pipeline run specified with a params file in yaml format:

```bash
nextflow run eduatilab/spotlight -profile docker -params-file params.yaml
```

with:

```yaml title="params.yaml"
input: './samplesheet.csv'
outdir: './results/'
<...>
```

You can also generate such `YAML`/`JSON` files via [nf-core/launch](https://nf-co.re/launch).

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```bash
nextflow pull eduatilab/spotlight
```

### Reproducibility

It is a good idea to specify the pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [eduatilab/spotlight releases page](https://github.com/eduatilab/spotlight/releases) and find the latest pipeline version - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`. Of course, you can switch to another version by changing the number after the `-r` flag.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future.

To further assist in reproducibility, you can use share and reuse [parameter files](#running-the-pipeline) to repeat pipeline runs with the same settings without having to write out a command with every single parameter.

> [!TIP]
> If you wish to share such profile (such as upload as supplementary material for academic publications), make sure to NOT include cluster specific paths to files, nor institutional specific profiles.

## Core Nextflow arguments

> [!NOTE]
> These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen)

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Apptainer, Conda) - see below.

> [!IMPORTANT]
> We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended, since it can lead to different results on different machines dependent on the computer environment.

* `docker`
  * A generic configuration profile to be used with [Docker](https://docker.com/)
* `singularity`
  * A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
* `podman`
  * A generic configuration profile to be used with [Podman](https://podman.io/)
* `shifter`
  * A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
* `charliecloud`
  * A generic configuration profile to be used with [Charliecloud](https://hpc.github.io/charliecloud/)
* `apptainer`
  * A generic configuration profile to be used with [Apptainer](https://apptainer.org/)
* `wave`
  * A generic configuration profile to enable [Wave](https://seqera.io/wave/) containers. Use together with one of the above (requires Nextflow `24.03.0-edge` or later).
* `conda`
  * A generic configuration profile to be used with [Conda](https://conda.io/docs/). Please only use Conda as a last resort i.e. when it's not possible to run the pipeline with Docker, Singularity, Podman, Shifter, Charliecloud, or Apptainer.

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

## Custom configuration

### Resource requests

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customise the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the pipeline steps, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher resources request (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

### Custom Containers

In some cases, you may wish to change the container or conda environment used by a pipeline steps for a particular tool. By default, nf-core pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However, in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/usage/configuration#updating-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, nf-core pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```
