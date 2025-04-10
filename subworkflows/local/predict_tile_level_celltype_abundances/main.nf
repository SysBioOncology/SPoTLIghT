include { COMBINE_TILE_LEVEL_CELLTYPE_ABUNDANCE  } from '../../../modules/local/combine_tile_level_celltype_abundance/main.nf'
include { PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCE } from '../../../modules/local/predict_tile_level_celltype_abundance/main.nf'
//
// Subworkflow with functionality specific to the SysBioOncology/spotlight_docker pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


workflow PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCES {
    take:
    features_input
    celltype_models
    var_names_path

    main:
    ch_versions = Channel.empty()
    PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCE(
        celltype_models.combine(features_input).combine(var_names_path),
        params.prediction_mode,
        params.n_outerfolds,
        params.slide_type,
        params.is_model_dir,
    )
    ch_tile_level_celltype_predictions = PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCE.out.csv.collect().map { csv -> [csv] }
    ch_versions = ch_versions.mix(PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCE.out.versions)


    COMBINE_TILE_LEVEL_CELLTYPE_ABUNDANCE(
        ch_tile_level_celltype_predictions.combine(features_input).combine(var_names_path),
        params.prediction_mode,
        params.n_outerfolds,
        params.slide_type,
    )

    ch_versions = ch_versions.mix(COMBINE_TILE_LEVEL_CELLTYPE_ABUNDANCE.out.versions)

    ch_target_features = COMBINE_TILE_LEVEL_CELLTYPE_ABUNDANCE.out.proba_csv.collect()

    emit:
    csv      = ch_target_features
    versions = ch_versions
}
