process COMPUTE_NCLUSTERS {
    label 'spatial_clustering_features'
    label 'compute_spatial_features'

    input:
    tuple path(tiles), path(tiles_labeled), path(cell_types)

    val slide_type
    val out_prefix

    output:
    path "${prefix}_nclusters_wide.csv", emit: csv
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    cell_types_arg = cell_types.name != "EMPTY" ? "--cell_types ${cell_types}" : ""
    """
    compute_nclusters.py ${args} \\
        --nf-process-id ${task.process} \\
        --all_slide_clusters_characterized ${tiles_labeled} \\
        --prefix ${prefix} ${cell_types_arg}
    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_nclusters_wide.csv"
    touch "versions.yml"

    """
}
