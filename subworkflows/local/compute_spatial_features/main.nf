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
include { COMBINE_ALL_SPATIAL_FEATURES } from '../../../modules/local/combine_all_spatial_features/main.nf'
include { GENERATE_GRAPHS              } from '../../../modules/local/generate_graphs/main.nf'

workflow COMPUTE_SPATIAL_FEATURES {
    take:
    tile_level_cell_type_quantification

    main:
    ch_versions = Channel.empty()

    ch_cell_types = params.cell_types_path ? Channel.fromPath(params.cell_types_path) : Channel.of(file("EMPTY"))
    ch_metadata = params.metadata_path ? Channel.fromPath(params.metadata_path) : Channel.of(file("EMPTY"))
    ch_sheet_name = params.sheet_name ? Channel.of(params.sheet_name) : Channel.of("EMPTY")
    ch_out_prefix = params.out_prefix ? Channel.of(params.out_prefix) : Channel.of("EMPTY")
    def spatialfeatures = params.spatialfeatures ? params.spatialfeatures.split(',').collect { it.trim().toLowerCase() } : []

    ch_graph_based_features = params.graph_based_features ? Channel.fromPath(params.graph_based_features) : Channel.empty()
    ch_cluster_based_features = params.cluster_based_features ? Channel.fromPath(params.cluster_based_features) : Channel.empty()
    ch_graphs = params.graphs_path ? Channel.fromPath(params.graphs_path) : Channel.empty()

    if (spatialfeatures.contains("graph") | spatialfeatures.contains("cluster")) {
        GENERATE_GRAPHS(
            tile_level_cell_type_quantification,
            ch_out_prefix,
            params.slide_type,
        )
        ch_graphs = GENERATE_GRAPHS.out.pkl
        ch_versions = ch_versions.mix(GENERATE_GRAPHS.out.versions)
    }

    if (spatialfeatures.contains("graph")) {
        COMPUTE_GRAPH_BASED_FEATURES(tile_level_cell_type_quantification, ch_cell_types, ch_graphs)
        ch_graph_based_features = COMPUTE_GRAPH_BASED_FEATURES.out.csv
        ch_versions = ch_versions.mix(COMPUTE_GRAPH_BASED_FEATURES.out.versions)
    }

    if (spatialfeatures.contains("cluster")) {
        COMPUTE_CLUSTERING_FEATURES(
            tile_level_cell_type_quantification,
            ch_cell_types,
            ch_graphs,
        )
        ch_cluster_based_features = COMPUTE_CLUSTERING_FEATURES.out.csv
        ch_versions = ch_versions.mix(COMPUTE_CLUSTERING_FEATURES.out.versions)
    }

    if (spatialfeatures.contains("graph") & spatialfeatures.contains("cluster")) {
        COMBINE_ALL_SPATIAL_FEATURES(
            ch_graph_based_features.combine(ch_cluster_based_features),
            ch_metadata,
            params.is_tcga,
            params.merge_var,
            ch_sheet_name,
            params.slide_type,
            ch_out_prefix,
        )
        ch_versions = ch_versions.mix(COMBINE_ALL_SPATIAL_FEATURES.out.versions)
    }

    emit:
    versions = ch_versions
}
