//
// Subworkflow with functionality specific to the SysBioOncology/spotlight_docker pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


include { COMPUTE_GRAPH_BASED_FEATURES } from '../compute_graph_based_features/main.nf'
include { COMPUTE_CLUSTERING_FEATURES  } from '../compute_clustering_features/main.nf'
include { GENERATE_GRAPHS              } from '../../../modules/local/generate_graphs/generategraphs.nf'
include { COMBINE_ALL_SPATIAL_FEATURES } from '../../../modules/local/combine_all_spatial_features/main.nf'

workflow COMPUTE_SPATIAL_FEATURES {
    take:
    tile_level_cell_type_quantification
    cell_types
    metadata_path

    main:


    GENERATE_GRAPHS(
        tile_level_cell_type_quantification,
        params.out_prefix,
        params.slide_type,
    )
    graphs = GENERATE_GRAPHS.out.pkl


    COMPUTE_GRAPH_BASED_FEATURES(tile_level_cell_type_quantification, cell_types, graphs)

    COMPUTE_CLUSTERING_FEATURES(
        tile_level_cell_type_quantification,
        cell_types,
        graphs,
    )
    COMBINE_ALL_SPATIAL_FEATURES(
        COMPUTE_GRAPH_BASED_FEATURES.out.csv,
        COMPUTE_CLUSTERING_FEATURES.out.csv,
        metadata_path,
        params.is_tcga,
        params.merge_var,
        params.sheet_name,
        params.slide_type,
        params.out_prefix,
    )
}
