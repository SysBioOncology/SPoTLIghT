process COMBINE_ALL_SPATIAL_FEATURES {
    label 'spatial_features'
    label 'process_single'

    input:
    tuple path(graph_features), path(clustering_features)
    path metadata_path
    val is_tcga
    val merge_var
    val sheet_name
    val slide_type
    val out_prefix

    output:
    path "${prefix}_all_features_combined.csv", emit: csv
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    is_tcga_to_int = is_tcga ? "--is_tcga" : ""
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    metadata_arg = metadata_path.name != "EMPTY" ? "--metadata_path ${metadata_path}" : ""
    sheet_name_arg = sheet_name != "EMPTY" ? "--sheet_name ${sheet_name}" : ""
    """

    combine_all_spatial_features.py ${args} \\
        --nf-process-id ${task.process} \\
        --graph_features ${graph_features} \\
        --clustering_features ${clustering_features} \\
        ${is_tcga_to_int} \\
        --merge_var ${merge_var} \\
        --prefix ${prefix} \\
        ${metadata_arg} ${sheet_name_arg}


    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_all_features_combined.csv"
    touch "versions.yml"

    """
}
