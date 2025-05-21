process CLUSTERING_SCHC_SIMULTANEOUS {
    label 'spatial_clustering_features'
    label 'process_medium'
    label 'compute_spatial_features'

    input:
    tuple path(tile_quantification_path), path(cell_types), path(graphs_path)
    val slide_type
    val out_prefix

    output:
    tuple path("${prefix}_all_schc_tiles_raw.csv"), path("${prefix}_all_schc_clusters_labeled.csv"), emit: csv
    path "${prefix}_graphs.pkl", optional: true
    path "${prefix}_all_schc_tiles.csv"
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    graphs_path_arg = graphs_path ? "--graphs_path ${graphs_path}" : ""
    cell_types_arg = cell_types.name != "EMPTY" ? "--cell_types ${cell_types}" : ""
    """
    clustering_schc_simultaneous.py ${args} \\
        --nf-process-id ${task.process} \\
        --tile_quantification_path ${tile_quantification_path} \\
        --n_cores ${task.cpus} \\
        --prefix ${prefix} ${graphs_path_arg} ${cell_types_arg}
    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_all_schc_tiles_raw.csv"
    touch "${prefix}_all_schc_clusters_labeled.csv"
    touch "${prefix}_all_schc_tiles.csv"
    touch "${prefix}_graphs.pkl"
    touch  "versions.yml"
    """
}
