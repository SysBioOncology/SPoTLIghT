process GENERATE_GRAPHS {
    // Add label for time and memory
    label 'spatial_features'
    label 'compute_spatial_features'

    input:
    path tile_quantification_path
    val out_prefix
    val slide_type

    output:
    path "${prefix}_graphs.pkl", emit: pkl
    path "versions.yml", emit: versions

    script:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    def args = task.ext.args ?: ''

    """
    generate_graphs.py ${args} \\
        --nf-process-id ${task.process} \\
        --tile_quantification_path ${tile_quantification_path} \\
        --n_cores ${task.cpus} \\
        --prefix ${prefix} \\
        --slide_type ${slide_type}
    """

    stub:
    prefix = out_prefix != "EMPTY" ? "${out_prefix}${slide_type}" : "${slide_type}"
    """
    touch "${prefix}_graphs.pkl"
    touch "versions.yml"

    """
}
