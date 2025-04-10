process POST_PROCESS_FEATURES {
    label 'process_medium'
    label "extract_histo_patho_features"

    input:
    path bot_train_file
    val slide_type
    val is_tcga

    output:
    path out_prefix, emit: txt_parquet
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''

    def is_tcga_arg = is_tcga ? "--is_tcga" : ""
    out_prefix = determine_out_prefix(slide_type)
    """
    post_process_features.py ${args} \\
        --nf-process-id ${task.process} \\
        --bot_train_file ${bot_train_file} \
        --slide_type ${slide_type} \
        ${is_tcga_arg}
    """

    stub:
    out_prefix = determine_out_prefix(slide_type)
    """
    touch ${out_prefix}
    touch "versions.yml"

    """
}
def determine_out_prefix(slide_type) {
    def res = ""
    if (slide_type == "FF") {
        res = "features.txt"
    }
    else if (slide_type == "FFPE") {
        res = "features-*.parquet"
    }
    else {
        res = "*"
    }

    return res
}
