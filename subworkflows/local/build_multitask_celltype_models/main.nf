include { PREPROCESSING_MULTITASK_MODEL_TARGET_FEATURES } from '../../../modules/local/preprocessing_multitask_model_target_features/main.nf'
include { BUILD_MULTITASK_CELLTYPE_MODEL                } from '../../../modules/local/build_multitask_celltype_model/main.nf'
// //
// // Subworkflow with functionality specific to the SysBioOncology/SPoTLIghT pipeline
// //

// /*
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//     IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// */





workflow BUILD_MULTITASK_CELLTYPE_MODELS {
    take:
    bottleneck_features
    clinical_file_path
    tpm
    immune_deconv_files

    main:

    ch_thorsson_scores = Channel.fromPath(params.thorsson_scores_path)
    ch_estimate_scores = Channel.fromPath(params.estimate_scores_path)
    ch_absolute_tumor_purity = Channel.fromPath(params.absolute_tumor_purity_path)
    ch_gibbons_scores = Channel.fromPath(params.gibbons_scores_path)
    ch_mfp_gene_signatures = Channel.fromPath(params.mfp_gene_signatures_path)

    ch_model_cell_types = Channel.of(params.model_cell_types.split(","))
    ch_versions = Channel.empty()

    ch_target_features = params.target_features_path ? Channel.fromPath(params.target_features_path) : Channel.empty()

    // Split into separate branches (expected 1 file per tool)
    ch_immune_deconv_files = immune_deconv_files.branch { tool, filepath ->
        quantiseq: tool == "quantiseq"
        return filepath
        mcp_counter: tool == "mcp_counter"
        return filepath
        xcell: tool == "xcell"
        return filepath
        epic: tool == "epic"
        return filepath
    }

    PREPROCESSING_MULTITASK_MODEL_TARGET_FEATURES(
        clinical_file_path,
        tpm,
        ch_thorsson_scores,
        ch_estimate_scores,
        ch_absolute_tumor_purity,
        ch_gibbons_scores,
        ch_mfp_gene_signatures,
        ch_immune_deconv_files.mcp_counter,
        ch_immune_deconv_files.quantiseq,
        ch_immune_deconv_files.xcell,
        ch_immune_deconv_files.epic,
    )
    // Close channels
    ch_var_names = PREPROCESSING_MULTITASK_MODEL_TARGET_FEATURES.out.pkl.collect()
    ch_target_features = PREPROCESSING_MULTITASK_MODEL_TARGET_FEATURES.out.csv.collect()
    ch_versions = ch_versions.mix(PREPROCESSING_MULTITASK_MODEL_TARGET_FEATURES.out.versions)


    BUILD_MULTITASK_CELLTYPE_MODEL(
        ch_model_cell_types.combine(bottleneck_features),
        ch_var_names,
        ch_target_features,
        params.alpha_min,
        params.alpha_max,
        params.n_steps,
        params.n_outerfolds,
        params.n_innerfolds,
        params.n_tiles,
        params.split_level,
        params.slide_type,
    )
    ch_versions = ch_versions.mix(BUILD_MULTITASK_CELLTYPE_MODEL.out.versions)
    ch_models = BUILD_MULTITASK_CELLTYPE_MODEL.out.pkl.map { it ->
        [it[0].getParent().name, it]
    }

    emit:
    var_names = ch_var_names
    models    = ch_models
    versions  = ch_versions
}
