/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { paramsSummaryMap                        } from 'plugin/nf-schema'
include { softwareVersionsToYAML                  } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText                  } from '../subworkflows/local/utils_nfcore_spotlight_pipeline'
include { EXTRACT_HISTOPATHO_FEATURES             } from '../subworkflows/local/extract_histopatho_features/main.nf'
include { COMPUTE_SPATIAL_FEATURES                } from '../subworkflows/local/compute_spatial_features/main.nf'
include { PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCES } from '../subworkflows/local/predict_tile_level_celltype_abundances/main.nf'
include { CREATE_TPM_MATRIX                       } from '../modules/local/create_tpm_matrix/main.nf'
include { DECONVOLUTE_BULKRNASEQ                  } from '../subworkflows/local/deconvolute_bulkRNAseq/main.nf'
include { BUILD_MULTITASK_CELLTYPE_MODELS         } from '../subworkflows/local/build_multitask_celltype_models/main.nf'



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow SPOTLIGHT {
    take:
    ch_samplesheet // channel: samplesheet read in from --input

    main:
    ch_versions = Channel.empty()

    ch_var_names = params.var_names_path ? Channel.fromPath(params.var_names_path) : Channel.empty()
    ch_celltype_models = params.celltype_models_path ? Channel.fromPath(params.celltype_models_path) : Channel.empty()
    // Get spotlight modules to run
    def spotlight_modules = params.spotlight_modules ? params.spotlight_modules.split(',').collect { it.trim().toLowerCase() } : []

    if (spotlight_modules.contains("extracthistopatho")) {
        EXTRACT_HISTOPATHO_FEATURES()
        ch_bottleneck_features = EXTRACT_HISTOPATHO_FEATURES.out.features
        ch_clinical_file = EXTRACT_HISTOPATHO_FEATURES.out.clinical_file
    }

    if (spotlight_modules.contains("deconvbulk") | spotlight_modules.contains("buildmodel")) {
        // In case 'buildmodel', then check whether there are missing files for the deconvolution tools if so then deconvolute for those
        DECONVOLUTE_BULKRNASEQ()
        ch_immune_deconv = DECONVOLUTE_BULKRNASEQ.out.immune_deconv
        ch_tpm = DECONVOLUTE_BULKRNASEQ.out.tpm
    }

    if (spotlight_modules.contains("buildmodel")) {
        BUILD_MULTITASK_CELLTYPE_MODELS(
            ch_clinical_file,
            ch_tpm,
            ch_bottleneck_features,
            ch_immune_deconv,
        )

        ch_var_names = BUILD_MULTITASK_CELLTYPE_MODELS.out.var_names
        ch_celltype_models = BUILD_MULTITASK_CELLTYPE_MODELS.out.models
    }

    if (spotlight_modules.contains('predicttiles')) {

        PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCES(
            ch_bottleneck_features,
            ch_celltype_models,
            ch_var_names,
        )
        ch_tile_level_celltype_predictions = PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCES.out.proba
    }

    if (spotlight_modules.contains('computespatial')) {
        COMPUTE_SPATIAL_FEATURES(
            ch_tile_level_celltype_predictions,
            params.out_prefix,
            params.slide_type,
        )
    }

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'spotlight_software_' + 'versions.yml',
            sort: true,
            newLine: true,
        )
        .set { ch_collated_versions }

    emit:
    versions = ch_versions // channel: [ path(versions.yml) ]
}
