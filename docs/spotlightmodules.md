# SPoTLIghT Modules

The SPoTLIghT pipeline consists of several modules: 

- [SPoTLIghT Modules](#spotlight-modules)
  - [Extracting histopathological features (`extracthistopatho`)](#extracting-histopathological-features-extracthistopatho)
  - [Deconvolution of bulkRNAseq data (`deconvbulk`).](#deconvolution-of-bulkrnaseq-data-deconvbulk)
  - [Building a multi-task cell type model to predict cell type abundances on a tile-level (`buildmodel`).](#building-a-multi-task-cell-type-model-to-predict-cell-type-abundances-on-a-tile-level-buildmodel)
    - [Required files](#required-files)
    - [Parameters](#parameters)
  - [Predicting tile-level cell type abundances using the multi-task models (`predicttiles`)](#predicting-tile-level-cell-type-abundances-using-the-multi-task-models-predicttiles)
  - [Compute spatial features using the tile-level cell type abundances (`computespatial`)](#compute-spatial-features-using-the-tile-level-cell-type-abundances-computespatial)

In brackets, the abbreviations to use for running the modules of interest

If you want to run all modules, you can set the `spotlight_modules` parameter as follows:

```{yml}
spotlight_modules: "extracthistopatho, deconvbulk, buildmodel, predicttiles, computespatial"
```

> When running only a subset of modules, set the parameters required for those modules!

## Extracting histopathological features (`extracthistopatho`)

Input files:

* `clinical_file_out_file` : 
* `image_dir` : Directory with H&E images.
* `path_codebook` : Path to [codebook.txt](https://github.com/gerstung-lab/PC-CHiP/blob/b5ff01b56dbad9a5880529cdcf5e799e912534a2/inception/codebook.txt)
* `checkpoint_path`: checkpoints of DL model, see the Tensorflow repository [tensorflow/models](https://github.com/tensorflow/models/tree/master/research/slim#Pretrained). Checkpoint used in manuscript can be downloaded via this [link](https://www.ebi.ac.uk/biostudies/files/S-BSST292/Retrained_Inception_v4.zip) and can be found here: https://www.ebi.ac.uk/biostudies/bioimages/studies/S-BSST292. Of note, the path should point to the **directory** with the checkpoint files. 
* `path_tissue_classes`: Path to [tissue_classes.csv](../assets/tissue_classes.csv), which is provided.

* `is_tcga`: indicate whether the dataset is from the TCGA.
* `tumor_purity_threshold` : Minimum tumor purity for a slide to be kept (default=80)
* `gradient_mag_filter` : Minimum gradient magnitude, used for filtering non-informative and/or blurry tiles (default=10)
* `n_shards` : number of shards for creating TFrecords (default=320)
* `bot_out_filename` : Filename for extracted histopathological features (default="bot_train")
* `pred_out_filename` : Filename for predictions (default="pred_train")
* `model_name` : Name of model used, ensure this corresponds to the model of the checkpoints (default="inception_v4")

## Deconvolution of bulkRNAseq data (`deconvbulk`).

* `gene_exp_path`: Path to gene expression file (`.txt`)
* `is_tpm`: Indicate whether given `gene_exp_path` is TPM normalized (default=false)

* `quantiseq_path`: Path to results quanTIseq (`.csv`) 
* `epic_path`: Path to results EPIC (`.csv`) 
* `mcp_counter_path`: Path to results MCP counter (`.csv`) 
* `xcell_path`: Path to results xCELL (`.csv`) 

> The above four files are optional, by default all tools will be run. If results for one or more tools have been generated already, please set the paths. 

## Building a multi-task cell type model to predict cell type abundances on a tile-level (`buildmodel`).

### Required files

Download the signatures/published scores, see table below.

| Parameter                  | Reference                                                 | Additional info                                                                                                                                                |
| -------------------------- | --------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `absolute_tumor_purity_path` | https://gdc.cancer.gov/about-data/publications/panimmune  | Download the 'Score for 160 Genes Signatures in Tumor Samples' or use [direct link]( https://api.gdc.cancer.gov/data/80a82092-161d-4615-9d96-e858f113618d)        |
| `estimate_scores_path` | https://bioinformatics.mdanderson.org/estimate/index.html | Download the relevant file for the cancer type of interest, use the RNA-seqV2 column on the page.                                                                                                    |
| `gibbons_scores_path` | https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5503821/     | Download the 'Supp Datafile S1.' or use the (direct link)[https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5503821/bin/NIHMS840944-supplement-Supp_Datafile_S1.xlsx] |
| `thorsson_scores_path` | https://gdc.cancer.gov/about-data/publications/panimmune  | Download the 'ABSOLUTE purity/ploidy file', or use [direct link](https://api.gdc.cancer.gov/data/4f277128-f793-4354-a13d-30cc7fe9f6b5)                           |

### Parameters

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

## Predicting tile-level cell type abundances using the multi-task models (`predicttiles`)

* `celltype_models_path`: Path to directory with the models for each cell type, where each cell type has to have its own folder. For an example of the structure see provided models [assets/TF_models/SKCM_FF](../assets/TF_models/SKCM_FF)  (default="assets/TF_models/SKCM_FF")
`prediction_mode` : (default="test")

## Compute spatial features using the tile-level cell type abundances (`computespatial`)

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
