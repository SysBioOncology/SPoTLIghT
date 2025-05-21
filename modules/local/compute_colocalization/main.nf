process COMPUTE_COLOCALIZATION {
    label 'compute_spatial_features'
    label 'spatial_network_features'

    input:
    tuple path(tile_quantification_path), path(cell_types), path(graphs_path)

    val abundance_threshold
    val slide_type
    val out_prefix

    output:
    path "${prefix}_features_coloc_fraction_wide.csv", emit: csv
    path "${prefix}_features_coloc_fraction.csv"
    path "${prefix}_graphs.pkl", optional: true
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''

    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    graphs_path_arg = graphs_path ? "--graphs_path ${graphs_path}" : ""
    cell_types_arg = cell_types.name != "EMPTY" ? "--cell_types ${cell_types}" : ""
    """
    compute_colocalization.py ${args} \\
        --nf-process-id ${task.process} \\
        --tile_quantification_path ${tile_quantification_path} \\
        --abundance_threshold ${abundance_threshold} \\
        --n_cores ${task.cpus} \\
        --prefix ${prefix} ${graphs_path_arg} ${cell_types_arg}
    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_features_coloc_fraction_wide.csv"
    touch "${prefix}_features_coloc_fraction.csv"
    touch "${prefix}_graphs.pkl"
    touch "versions.yml"

    """
}
