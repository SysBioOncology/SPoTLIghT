process COMPUTE_PROXIMITY_FROM_INDIV_SCHC_COMBINE {
    label 'spatial_clustering_features'
    label 'compute_spatial_features'

    input:
    tuple path(prox_between), path(prox_within)
    val slide_type
    val out_prefix

    output:
    path "${prefix}_features_clust_indiv_schc_prox.csv", emit: csv
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''

    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    compute_proximity_from_indiv_schc_combine.py ${args} \\
        --nf-process-id ${task.process} \\
        --prox_between ${prox_between} \\
        --prox_within ${prox_within} \\
        --prefix ${prefix}
    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_features_clust_indiv_schc_prox.csv"
    touch "versions.yml"

    """
}
