process PREDICT_TILE_LEVEL_CELL_TYPE_ABUNDANCE {
    label 'processing_low'
    label 'tf_learning_celltyp_quant'
    tag "${cell_type}"

    input:
    tuple val(cell_type), path(celltype_models), path(features_input), path(var_names_path)
    val prediction_mode
    val n_outerfolds
    val slide_type
    val is_model_dir

    output:
    path "${prediction_mode}_${cell_type}_tile_predictions_zscores.csv", emit: csv
    path "versions.yml", emit: versions

    script:
    def is_model_dir_args = is_model_dir ? "--is_model_dir" : ""
    def args = task.ext.args ?: ''


    """
    predict_tile_level_celltype_abundance.py ${args} \\
        --nf-process-id ${task.process} \\
        --models_dir \$PWD \
        --cell_type ${cell_type} \
        --prediction_mode ${prediction_mode} \
        --var_names_path ${var_names_path} \
        --slide_type ${slide_type} \
        --n_outerfolds ${n_outerfolds} \
        --features_input ${features_input} ${is_model_dir_args}
    """

    stub:
    """
    touch "${prediction_mode}_${cell_type}_tile_predictions_zscores.csv"
    touch "versions.yml"

    """
}
