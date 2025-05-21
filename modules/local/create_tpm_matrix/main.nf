process CREATE_TPM_MATRIX {
    label 'rcontainer'

    input:
    path gene_exp_path

    output:
    path "tpm.txt", emit: txt
    path "versions.yml", emit: versions

    when:
    (task.ext.when || task.ext.when == null) && (gene_exp_path.name != "NO_FILE")

    script:
    def args = task.ext.args ?: ''
    """

    create_tpm_matrix.R \\
    --gene_exp_path ${gene_exp_path} ${args} \\
    --nf-process-id ${task.process}
    """

    stub:
    """
    touch tpm.txt
    touch "versions.yml"

    """
}
