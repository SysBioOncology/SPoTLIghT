// # ------------------------------------------------------ #
// # ---- Compute predictions and bottlenecks features ---- #
// # ------------------------------------------------------ #

process PREDICT_BOTTLENECK_OUT {
    label 'mem_64G'
    label 'time_4h'
    label 'extract_histo_patho_features'

    input:
    val bot_out_filename
    val pred_out_filename
    path tf_records
    val model_name
    val checkpoint_path

    output:
    path "${bot_out_filename}.txt", emit: bot_txt
    path "${pred_out_filename}.txt", emit: pred_txt
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    """
    bottleneck_predict.py ${args} \\
        --nf_process_id ${task.process} \\
        --num_classes=42 \
        --bot_out ${bot_out_filename}.txt \
        --pred_out ${pred_out_filename}.txt \
        --model_name ${model_name} \
        --checkpoint_path ${checkpoint_path} \
        --file_dir \$PWD/
    


    """

    stub:
    """
    touch ${bot_out_filename}.txt
    touch ${pred_out_filename}.txt
    touch versions.yml
    """
}
