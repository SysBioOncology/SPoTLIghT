process IMMUNEDECONV {
    tag "${tool}"
    label 'rcontainer'

    input:
    tuple val(tool), path(tpm_path), path(mcp_probesets), path(mcp_genes)

    output:
    tuple val(tool), path("${tool}.csv"), emit: csv
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    """
    immunedeconv.R ${args} \\
        --nf-process-id ${task.process} \\
        --tpm_path ${tpm_path} \\
        --tool ${tool} \\
        --probesets ${mcp_probesets} \\
        --genes ${mcp_genes}
    """

    stub:
    """
    touch "${tool}.csv"
    touch "versions.yml"

    """
}
