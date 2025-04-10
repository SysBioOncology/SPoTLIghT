// include { GENERATE_GRAPHS                          } from '../../../modules/local/generate_graphs/main.nf'
include { COMPUTE_CONNECTEDNESS                    } from '../../../modules/local/compute_connectedness/main.nf'
include { COMPUTE_COLOCALIZATION                   } from '../../../modules/local/compute_colocalization/main.nf'
include { COMPUTE_NODE_DEGREE_WITH_ES              } from '../../../modules/local/compute_node_degree_with_es/main.nf'
include { COMPUTE_N_SHORTEST_PATHS_WITH_MAX_LENGTH } from '../../../modules/local/compute_nshortest_with_max_length/main.nf'
include { COMBINE_NETWORK_FEATURES                 } from '../../../modules/local/combine_network_features/main.nf'
//
// Subworkflow with functionality specific to the SysBioOncology/spotlight_docker pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


workflow COMPUTE_GRAPH_BASED_FEATURES {
    take:
    tile_level_cell_type_quantification
    cell_types
    graphs

    main:
    ch_input = tile_level_cell_type_quantification.combine(cell_types).combine(graphs)
    ch_versions = Channel.empty()
    COMPUTE_CONNECTEDNESS(
        ch_input,
        params.abundance_threshold,
        params.slide_type,
        params.out_prefix,
    )
    ch_versions = ch_versions.mix(COMPUTE_CONNECTEDNESS.out.versions)

    COMPUTE_COLOCALIZATION(
        ch_input,
        params.abundance_threshold,
        params.slide_type,
        params.out_prefix,
    )
    ch_versions = ch_versions.mix(COMPUTE_COLOCALIZATION.out.versions)

    COMPUTE_NODE_DEGREE_WITH_ES(
        ch_input,
        params.shapiro_alpha,
        params.slide_type,
        params.out_prefix,
    )

    ch_versions = ch_versions.mix(COMPUTE_NODE_DEGREE_WITH_ES.out.versions)

    COMPUTE_N_SHORTEST_PATHS_WITH_MAX_LENGTH(
        ch_input,
        params.cutoff_path_length,
        params.slide_type,
        params.out_prefix,
    )
    ch_versions = ch_versions.mix(COMPUTE_N_SHORTEST_PATHS_WITH_MAX_LENGTH.out.versions)

    COMBINE_NETWORK_FEATURES(
        COMPUTE_CONNECTEDNESS.out.csv.combine(
            COMPUTE_N_SHORTEST_PATHS_WITH_MAX_LENGTH.out.csv
        ).combine(
            COMPUTE_COLOCALIZATION.out.csv
        ),
        params.slide_type,
        params.out_prefix,
    )
    ch_versions = ch_versions.mix(COMBINE_NETWORK_FEATURES.out.versions)

    emit:
    csv      = COMBINE_NETWORK_FEATURES.out.csv
    versions = ch_versions
}
