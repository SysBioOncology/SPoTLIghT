process COMPUTE_NODE_DEGREE_WITH_ES {
    label 'compute_spatial_features'
    label 'spatial_network_features'

    input:
    tuple path(tile_quantification_path), path(cell_types), path(graphs_path)

    val shapiro_alpha
    val slide_type
    val out_prefix

    output:
    path "${prefix}_features_ND_ES.csv", emit: csv
    path "${prefix}_features_ND_sims.csv"
    path "${prefix}_features_ND.csv"
    path "${prefix}_features_ND_sim_assignments.pkl"
    path "${prefix}_shapiro_tests.csv"
    path "${prefix}_graphs.pkl", optional: true
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''

    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    graphs_path_arg = graphs_path ? "--graphs_path ${graphs_path}" : ""
    cell_types_arg = cell_types.name != "EMPTY" ? "--cell_types ${cell_types}" : ""
    """
    compute_node_degree_with_es.py ${args} \\
        --nf-process-id ${task.process} \\
        --tile_quantification_path ${tile_quantification_path} \\
        --n_cores ${task.cpus} \\
        --shapiro_alpha ${shapiro_alpha} \\
        --prefix ${prefix} ${graphs_path_arg} ${cell_types_arg}
    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_features_ND_ES.csv"
    touch "${prefix}_features_ND_sims.csv"
    touch "${prefix}_features_ND.csv"
    touch "${prefix}_features_ND_sim_assignments.pkl"
    touch "${prefix}_shapiro_tests.csv"
    touch "${prefix}_graphs.pkl"
    touch "versions.yml"

    """
}
