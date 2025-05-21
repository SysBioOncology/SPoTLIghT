process COMPUTE_FRAC_HIGH {
    label 'spatial_clustering_features'
    label 'compute_spatial_features'

    input:
    tuple path(tiles), path(tiles_labeled)
    val slide_type
    val out_prefix

    output:
    path "${prefix}_frac_high_wide.csv", emit: csv
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''

    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    compute_frac_high.py ${args} \\
        --nf-process-id ${task.process} \\
        --slide_indiv_clusters_labeled ${tiles_labeled} \\
        --prefix ${prefix}
    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_frac_high_wide.csv"
    touch "versions.yml"

    """
}
