process COMBINE_NETWORK_FEATURES {
    label 'spatial_features'
    label 'process_single'

    input:
    tuple path(all_largest_cc_sizes_wide), path(shortest_paths_wide), path(colocalization_wide)
    val slide_type
    val out_prefix

    output:
    path "${prefix}_all_graph_features.csv", emit: csv
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''

    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    combine_network_features.py ${args} \\
        --nf-process-id ${task.process} \\
        --all_largest_cc_sizes_wide ${all_largest_cc_sizes_wide} \\
        --shortest_paths_wide ${shortest_paths_wide} \\
        --colocalization_wide ${colocalization_wide} \\
        --prefix ${prefix}
    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_all_graph_features.csv"
    touch "versions.yml"

    """
}
