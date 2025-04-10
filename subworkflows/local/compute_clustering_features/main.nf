include { CLUSTERING_SCHC_SIMULTANEOUS              } from '../../../modules/local/clustering_schc_simultaneous/main.nf'
include { CLUSTERING_SCHC_INDIVIDUAL                } from '../../../modules/local/clustering_schc_individual/main.nf'
include { COMPUTE_NCLUSTERS                         } from '../../../modules/local/compute_nclusters/main.nf'
include { COMPUTE_FRAC_HIGH                         } from '../../../modules/local/compute_frac_high/main.nf'
include { COMPUTE_PROXIMITY_FROM_SIMULTANEOUS_SCHC  } from '../../../modules/local/compute_proximity_from_simultaneous_schc/main.nf'
include { COMPUTE_PROXIMITY_FROM_INDIV_SCHC_WITHIN  } from '../../../modules/local/compute_proximity_from_indiv_schc_within/main.nf'
include { COMPUTE_PROXIMITY_FROM_INDIV_SCHC_BETWEEN } from '../../../modules/local/compute_proximity_from_indiv_schc_between/main.nf'
include { COMPUTE_PROXIMITY_FROM_INDIV_SCHC_COMBINE } from '../../../modules/local/compute_proximity_from_indiv_schc_combine/main.nf'
include { COMBINE_CLUSTERING_FEATURES               } from '../../../modules/local/combine_clustering_features/main.nf'
//
// Subworkflow with functionality specific to the SysBioOncology/spotlight_docker pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


workflow COMPUTE_CLUSTERING_FEATURES {
    take:
    tile_level_cell_type_quantification
    cell_types
    graphs

    main:
    ch_max_dist = params.max_dist ? Channel.value(params.max_dist) : Channel.of("EMPTY")
    ch_schc_simultaneous = Channel.empty()
    ch_schc_indiv = Channel.empty()
    ch_versions = Channel.empty()

    // Clustering
    ch_cluster_input = tile_level_cell_type_quantification.combine(cell_types).combine(graphs)

    CLUSTERING_SCHC_SIMULTANEOUS(
        ch_cluster_input,
        params.slide_type,
        params.out_prefix,
    )
    ch_schc_simultaneous = CLUSTERING_SCHC_SIMULTANEOUS.out.csv
    ch_simul_prox_input = ch_schc_simultaneous.combine(ch_max_dist).combine(cell_types)
    ch_versions = ch_versions.mix(CLUSTERING_SCHC_SIMULTANEOUS.out.versions)
    CLUSTERING_SCHC_INDIVIDUAL(
        ch_cluster_input,
        params.slide_type,
        params.out_prefix,
    )
    ch_schc_indiv = CLUSTERING_SCHC_INDIVIDUAL.out.csv
    ch_indiv_prox_input = ch_schc_indiv.combine(ch_max_dist).combine(cell_types)
    ch_versions = ch_versions.mix(CLUSTERING_SCHC_INDIVIDUAL.out.versions)
    // Features based on SIMULTANEOUS clustering
    COMPUTE_NCLUSTERS(
        ch_schc_simultaneous.combine(cell_types),
        params.slide_type,
        params.out_prefix,
    )
    ch_versions = ch_versions.mix(COMPUTE_NCLUSTERS.out.versions)

    COMPUTE_PROXIMITY_FROM_SIMULTANEOUS_SCHC(
        ch_simul_prox_input,
        params.n_clusters,
        params.max_n_tiles_threshold,
        params.tile_size,
        params.overlap,
        params.slide_type,
        params.out_prefix,
    )
    ch_versions = ch_versions.mix(COMPUTE_PROXIMITY_FROM_SIMULTANEOUS_SCHC.out.versions)

    COMPUTE_FRAC_HIGH(
        ch_schc_indiv,
        params.slide_type,
        params.out_prefix,
    )
    ch_versions = ch_versions.mix(COMPUTE_FRAC_HIGH.out.versions)

    COMPUTE_PROXIMITY_FROM_INDIV_SCHC_WITHIN(
        ch_indiv_prox_input,
        params.n_clusters,
        params.max_n_tiles_threshold,
        params.tile_size,
        params.overlap,
        params.slide_type,
        params.out_prefix,
    )
    ch_indiv_prox_within = COMPUTE_PROXIMITY_FROM_INDIV_SCHC_WITHIN.out.csv
    ch_versions = ch_versions.mix(COMPUTE_PROXIMITY_FROM_INDIV_SCHC_WITHIN.out.versions)

    // Proximity features
    COMPUTE_PROXIMITY_FROM_INDIV_SCHC_BETWEEN(
        ch_indiv_prox_input,
        params.n_clusters,
        params.max_n_tiles_threshold,
        params.tile_size,
        params.overlap,
        params.slide_type,
        params.out_prefix,
    )
    ch_indiv_prox_between = COMPUTE_PROXIMITY_FROM_INDIV_SCHC_BETWEEN.out.csv
    ch_versions = ch_versions.mix(COMPUTE_PROXIMITY_FROM_INDIV_SCHC_BETWEEN.out.versions)
    COMPUTE_PROXIMITY_FROM_INDIV_SCHC_COMBINE(
        ch_indiv_prox_between.combine(ch_indiv_prox_within),
        params.slide_type,
        params.out_prefix,
    )
    ch_versions = ch_versions.mix(COMPUTE_PROXIMITY_FROM_INDIV_SCHC_COMBINE.out.versions)

    ch_combine_input = COMPUTE_FRAC_HIGH.out.csv.combine(COMPUTE_NCLUSTERS.out.csv).combine(COMPUTE_PROXIMITY_FROM_SIMULTANEOUS_SCHC.out.csv).combine(COMPUTE_PROXIMITY_FROM_INDIV_SCHC_COMBINE.out.csv)
    COMBINE_CLUSTERING_FEATURES(
        ch_combine_input,
        params.slide_type,
        params.out_prefix,
    )

    ch_versions = ch_versions.mix(COMBINE_CLUSTERING_FEATURES.out.versions)

    emit:
    csv      = COMBINE_CLUSTERING_FEATURES.out.csv
    versions = ch_versions
}
