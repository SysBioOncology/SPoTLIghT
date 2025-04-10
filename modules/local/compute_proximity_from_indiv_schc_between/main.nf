process COMPUTE_PROXIMITY_FROM_INDIV_SCHC_BETWEEN {
    label 'spatial_clustering_features'
    label 'compute_spatial_features'

    input:
    tuple path(tiles), path(tiles_labeled), val(max_dist), path(cell_types)
    val n_clusters
    val max_n_tiles_threshold
    val tile_size
    val overlap
    val slide_type
    val out_prefix

    output:
    path "${prefix}_features_clust_indiv_schc_prox_between.csv", emit: csv
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''

    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    cell_types_arg = cell_types.name != "EMPTY" ? "--cell_types ${cell_types}" : ""
    max_dist_arg = max_dist != "EMPTY" ? "--max_dist ${max_dist}" : ""
    """
    compute_proximity_from_indiv_schc_between.py ${args} \\
        --nf-process-id ${task.process} \\
        --slide_clusters ${tiles} \\
        --tiles_schc ${tiles_labeled} \\
        --n_cores ${task.cpus} \\
        --max_n_tiles_threshold ${max_n_tiles_threshold} \\
        --n_clusters ${n_clusters} \\
        --tile_size ${tile_size} \\
        --overlap ${overlap} \\
        --prefix ${prefix} ${cell_types_arg} ${max_dist_arg}
    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_features_clust_indiv_schc_prox_between.csv"
    touch "versions.yml"

    """
}
