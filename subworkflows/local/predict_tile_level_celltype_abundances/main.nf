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
    ch_cell_types_path = params.cell_types_path ? Channel.fromPath(params.cell_types_path) : Channel.empty()


    PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCE(
        features_input,
        celltype_models,
        var_names_path,
        params.prediction_mode,
        ch_cell_types_path,
        params.n_outerfolds,
        params.slide_type,
        params.is_model_dir,
    )
    ch_tile_level_celltype_predictions = PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCE.out.csv.collect()


    COMBINE_TILE_LEVEL_CELLTYPE_ABUNDANCE(
        features_input,
        ch_tile_level_celltype_predictions,
        var_names_path,
        params.prediction_mode,
        ch_cell_types_path,
        params.n_outerfolds,
        params.slide_type,
    )

    ch_target_features = COMBINE_TILE_LEVEL_CELLTYPE_ABUNDANCE.out.proba_csv.collect()

    emit:
    proba = ch_target_features
}
