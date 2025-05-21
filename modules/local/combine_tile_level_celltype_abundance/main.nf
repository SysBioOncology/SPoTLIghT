process COMBINE_TILE_LEVEL_CELLTYPE_ABUNDANCE {
    label 'processing_low'
    label 'tf_learning_celltyp_quant'

    input:
    tuple path(tile_level_celltype_predictions, stageAs: "tile_level_predictions/*"), path(features_input), path(var_names_path)
    val prediction_mode
    val n_outerfolds
    val slide_type

    output:
    path "${prediction_mode}_tile_predictions_proba.csv", emit: proba_csv
    path "${prediction_mode}_tile_predictions_zscores.csv", emit: zscores_csv
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''

    """
    combine_tile_level_celltype_abundance.py ${args} \\
        --nf-process-id ${task.process} \\
        --tile_predictions_input_dir tile_level_predictions \\
        --prediction_mode ${prediction_mode} \\
        --var_names_path ${var_names_path} \\
        --slide_type ${slide_type} \\
        --n_outerfolds ${n_outerfolds} \\
        --features_input ${features_input}
    """

    stub:
    """
    touch "${prediction_mode}_tile_predictions_zscores.csv"
    touch "${prediction_mode}_tile_predictions_proba.csv"
    touch "versions.yml"


    """
}
