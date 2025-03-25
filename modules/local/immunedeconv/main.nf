process IMMUNEDECONV {
    label 'rcontainer'

    input:
    tuple val(tool), path(tpm_path), path(mcp_probesets), path(mcp_genes)

    output:
    tuple val(tool), path("${tool}.csv"), emit: csv

    script:
    """
    immunedeconv.R \\
        --tpm_path ${tpm_path} \\
        --tool ${tool} \\
        --probesets ${mcp_probesets} \\
        --genes ${mcp_genes}
    """

    stub:
    """
    touch "${tool}.csv"
    """
}
