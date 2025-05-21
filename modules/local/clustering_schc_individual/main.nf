process CLUSTERING_SCHC_INDIVIDUAL {
    label 'compute_spatial_features'
    label 'spatial_clustering_features'
    label 'process_medium'

    input:
    tuple path(tile_quantification_path), path(cell_types), path(graphs)
    val slide_type
    val out_prefix

    output:
    tuple path("${prefix}_indiv_schc_tiles_raw.csv"), path("${prefix}_indiv_schc_clusters_labeled.csv"), emit: csv
    path "${prefix}_graphs.pkl", optional: true
    path "${prefix}_indiv_schc_tiles.csv"
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''

    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    graphs_path_arg = graphs ? "--graphs_path ${graphs}" : ""
    cell_types_arg = cell_types.name != "EMPTY" ? "--cell_types ${cell_types}" : ""
    """
    clustering_schc_individual.py ${args} \\
        --nf-process-id ${task.process} \\
        --tile_quantification_path ${tile_quantification_path} \\
        --n_cores ${task.cpus} \\
        --prefix ${prefix} ${graphs_path_arg} ${cell_types_arg}
    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_indiv_schc_tiles_raw.csv"
    touch "${prefix}_indiv_schc_clusters_labeled.csv"
    touch "${prefix}_graphs.pkl"
    touch "${prefix}_indiv_schc_tiles.csv"
    touch "versions.yml"
    """
}
