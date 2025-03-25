include { GENERATE_GRAPHS                          } from '../../../modules/local/generate_graphs/generategraphs.nf'
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

    GENERATE_GRAPHS(
        tile_level_cell_type_quantification,
        params.out_prefix,
        params.slide_type,
    )

    COMPUTE_CONNECTEDNESS(
        tile_level_cell_type_quantification,
        cell_types,
        graphs,
        params.abundance_threshold,
        params.slide_type,
        params.out_prefix,
    )

    COMPUTE_COLOCALIZATION(
        tile_level_cell_type_quantification,
        cell_types,
        graphs,
        params.abundance_threshold,
        params.slide_type,
        params.out_prefix,
    )

    COMPUTE_NODE_DEGREE_WITH_ES(
        tile_level_cell_type_quantification,
        params.cell_types,
        graphs,
        params.shapiro_alpha,
        params.slide_type,
        params.out_prefix,
    )

    COMPUTE_N_SHORTEST_PATHS_WITH_MAX_LENGTH(
        tile_level_cell_type_quantification,
        cell_types,
        graphs,
        params.cutoff_path_length,
        params.slide_type,
        params.out_prefix,
    )

    COMBINE_NETWORK_FEATURES(
        COMPUTE_CONNECTEDNESS.out.csv,
        COMPUTE_N_SHORTEST_PATHS_WITH_MAX_LENGTH.out.csv,
        COMPUTE_COLOCALIZATION.out.csv,
        params.slide_type,
        params.out_prefix,
    )

    emit:
    csv = COMBINE_NETWORK_FEATURES.out.csv
}
