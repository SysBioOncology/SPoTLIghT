#!/usr/local/bin/_entrypoint.sh Rscript
# Unload all previously loaded packages + remove previous environment
rm(list = ls(all = TRUE))


pacman::p_load(GaitiLabUtils, immunedeconv, install = FALSE)
pacman::p_load(glue, data.table, tidyverse, stringr, install = FALSE)

parser <- setup_default_argparser(
    description = "Compute cell fractions with immunedeconv using tpm from bulkRNAseq data",
    default_output_dir = "."
)
parser$add_argument(
    "--tpm_path",
    type = "character",
    default = NULL,
    help = "Full path of input file incl. extension"
)
parser$add_argument(
    "--tool",
    type = "character",
    default = "quantiseq",
    help = "Tool to use for quantification (default=quantiseq)"
)
parser$add_argument(
    "--probesets",
    type = "character",
    default = "assets/mcp_counter/probesets.txt",
    help = "Path to probesets.txt"
)
parser$add_argument(
    "--genes",
    type = "character",
    default = "assets/mcp_counter/genes.txt",
    help = "Path to genes.txt"
)
# TODO to be replaced later with built-in function in GaitiLabUtils
parser$add_argument(
    "--nf-process-id",
    dest = "nf_process_id",
    type = "character",
    help = "Task ID from Nextflow, only needed in Nextflow pipeline",
    default = NULL
)

params <- parser$parse_args()

# # Set up logging
logr <- init_logging(log_level = params$log_level)

log_info("Create output directory...")
GaitiLabUtils::create_dir(params$output_dir)

log_info(getwd())
log_info(list.files(getwd()))
# immunedeconv offers the following methods:
# - quantiseq
# - mcp_counter
# - xcell
# - epic

log_info("Load tpm data")
tpm <- data.table::fread(
    params$tpm_path,
    check.names = FALSE,
    sep = "\t",
    header = TRUE,
) %>%
    data.frame(row.names = 1) %>%
    data.matrix()

create_dir(params$output_dir)

## 1) quanTIseq
if (params$tool == "quantiseq") {
    log_info("Running quanTIseq...")
    tpm_quantiseq <- tpm
    rownames(tpm_quantiseq) <- toupper(rownames(tpm_quantiseq))
    cell_fractions <- immunedeconv::deconvolute(
        tpm_quantiseq,
        "quantiseq",
        tumor = TRUE,
        arrays = FALSE,
        scale_mrna = TRUE
    ) %>%
        column_to_rownames("cell_type")

    write.csv(
        cell_fractions,
        file.path(params$output_dir, "quantiseq.csv"),
        row.names = TRUE
    )
} else if (params$tool == "mcp_counter") {
    ## 2) MCP Counter
    log_info("Running MCP Counter...")
    user_probesets <- read.table(
        params$probesets,
        sep = "\t",
        stringsAsFactors = FALSE,
        colClasses = "character"
    )
    user_genesets <- read.table(
        params$genes,
        sep = "\t",
        stringsAsFactors = FALSE,
        header = TRUE,
        colClasses = "character",
        check.names = FALSE
    )

    cell_fractions <- immunedeconv::deconvolute(
        tpm,
        "mcp_counter",
        probesets = user_probesets,
        genes = user_genesets
    ) %>%
        column_to_rownames("cell_type")

    write.csv(
        cell_fractions,
        file.path(params$output_dir, "mcp_counter.csv"),
        row.names = TRUE
    )
} else if (params$tool == "xcell") {
    ## 3) XCell
    log_info("Running XCell...")
    cell_fractions <- immunedeconv::deconvolute(tpm, "xcell") %>%
        column_to_rownames("cell_type")

    write.csv(
        cell_fractions,
        file.path(params$output_dir, "xcell.csv"),
        row.names = TRUE
    )
} else if (params$tool == "epic") {
    ## 4) EPIC
    log_info("Running EPIC...")
    cell_fractions <- immunedeconv::deconvolute_epic(
        tpm,
        tumor = TRUE,
        scale_mrna = TRUE
    )

    write.csv(
        cell_fractions,
        file.path(params$output_dir, "epic.csv"),
        row.names = TRUE
    )
} else {
    log_info(
        "No valid tool given, please choose: 'quantiseq', 'mcp', 'xcell' or 'epic'..."
    )
}

log_info("Finished!")

# log_info("Session Info")
# log_object(sessionInfo())


if (!is.null(params$nf_process_id)) {
    write_versions_yml(
        c(pacman::p_loaded(), "immunedeconv"),
        task_id =params$nf_process_id,
        outdir = params$output_dir
    )
}

