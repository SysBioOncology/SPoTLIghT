include { CREATE_TPM_MATRIX           } from '../../../modules/local/create_tpm_matrix/main.nf'
include { IMMUNEDECONV as QUANTISEQ   } from '../../../modules/local/immunedeconv/main.nf'
include { IMMUNEDECONV as EPIC        } from '../../../modules/local/immunedeconv/main.nf'
include { IMMUNEDECONV as XCELL       } from '../../../modules/local/immunedeconv/main.nf'
include { IMMUNEDECONV as MCP_COUNTER } from '../../../modules/local/immunedeconv/main.nf'
include { IMMUNEDECONV                } from '../../../modules/local/immunedeconv/main.nf'

//
// Subworkflow with functionality specific to the SysBioOncology/SPoTLIghT pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/



workflow DECONVOLUTE_BULKRNASEQ {
    main:

    ch_versions = Channel.empty()
    ch_epic = Channel.of(["epic", params.epic_path ? file(params.epic_path) : "empty"])
    ch_quantiseq = Channel.of(["quantiseq", params.quantiseq_path ? file(params.quantiseq_path) : "empty"])
    ch_mcp_counter = Channel.of(["mcp_counter", params.mcp_counter_path ? file(params.mcp_counter_path) : "empty"])
    ch_xcell = Channel.of(["xcell", params.xcell_path ? file(params.xcell_path) : "empty"])
    // Combine channels
    ch_deconv = ch_epic.concat(ch_quantiseq, ch_mcp_counter, ch_xcell)

    ch_tpm = params.is_tpm ? Channel.fromPath(params.gene_exp_path) : Channel.empty()

    // Helper files
    ch_mcp_probesets = Channel.fromPath(params.mcp_probesets)
    ch_mcp_genes = Channel.fromPath(params.mcp_genes)

    ch_tpm.ifEmpty(file(params.gene_exp_path)) | CREATE_TPM_MATRIX
    ch_tpm = CREATE_TPM_MATRIX.out.txt.collect()
    ch_versions = ch_versions.mix(CREATE_TPM_MATRIX.out.versions)

    ch_immune_deconv = ch_deconv
        .combine(ch_tpm)
        .branch { tool, deconv_path, tpm_path ->
            invalid: deconv_path == "empty"
            return [tool, tpm_path]
            valid: true
            return [tool, deconv_path]
        }

    IMMUNEDECONV(
        ch_immune_deconv.invalid.combine(ch_mcp_probesets).combine(ch_mcp_genes)
    )

    ch_versions = ch_versions.mix(IMMUNEDECONV.out.versions)

    emit:
    tpm           = ch_tpm
    immune_deconv = IMMUNEDECONV.out.csv.mix(ch_immune_deconv.valid)
    versions      = ch_versions
}
