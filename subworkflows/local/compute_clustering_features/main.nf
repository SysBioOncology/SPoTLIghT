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


    CLUSTERING_SCHC_SIMULTANEOUS(
        tile_level_cell_type_quantification,
        cell_types,
        graphs,
        params.slide_type,
        params.out_prefix,
    )

    CLUSTERING_SCHC_INDIVIDUAL(
        tile_level_cell_type_quantification,
        cell_types,
        graphs,
        params.slide_type,
        params.out_prefix,
    )

    COMPUTE_NCLUSTERS(
        CLUSTERING_SCHC_SIMULTANEOUS.out.csv,
        cell_types,
        params.slide_type,
        params.out_prefix,
    )

    COMPUTE_FRAC_HIGH(
        CLUSTERING_SCHC_INDIVIDUAL.out.csv,
        params.slide_type,
        params.out_prefix,
    )

    COMPUTE_PROXIMITY_FROM_SIMULTANEOUS_SCHC(
        CLUSTERING_SCHC_SIMULTANEOUS.out.csv,
        cell_types,
        params.n_clusters,
        params.max_dist,
        params.max_n_tiles_threshold,
        params.tile_size,
        params.overlap,
        params.slide_type,
        params.out_prefix,
    )


    COMPUTE_PROXIMITY_FROM_INDIV_SCHC_WITHIN(
        CLUSTERING_SCHC_INDIVIDUAL.out.csv,
        cell_types,
        params.n_clusters,
        params.max_dist,
        params.max_n_tiles_threshold,
        params.tile_size,
        params.overlap,
        params.slide_type,
        params.out_prefix,
    )


    COMPUTE_PROXIMITY_FROM_INDIV_SCHC_BETWEEN(
        CLUSTERING_SCHC_INDIVIDUAL.out.csv,
        cell_types,
        params.n_clusters,
        params.max_dist,
        params.max_n_tiles_threshold,
        params.tile_size,
        params.overlap,
        params.slide_type,
        params.out_prefix,
    )

    COMPUTE_PROXIMITY_FROM_INDIV_SCHC_COMBINE(
        COMPUTE_PROXIMITY_FROM_INDIV_SCHC_BETWEEN.out.csv,
        COMPUTE_PROXIMITY_FROM_INDIV_SCHC_WITHIN.out.csv,
        params.slide_type,
        params.out_prefix,
    )


    COMBINE_CLUSTERING_FEATURES(
        COMPUTE_FRAC_HIGH.out.csv,
        COMPUTE_NCLUSTERS.out.csv,
        COMPUTE_PROXIMITY_FROM_SIMULTANEOUS_SCHC.out.csv,
        COMPUTE_PROXIMITY_FROM_INDIV_SCHC_COMBINE.out.csv,
        params.slide_type,
        params.out_prefix,
    )

    emit:
    csv = COMBINE_CLUSTERING_FEATURES.out.csv
}
