include { CREATE_CLINICAL_FILE       } from '../../../modules/local/create_clinical_file/main.nf'
include { CREATE_LIST_AVAIL_SLIDES   } from '../../../modules/local/create_list_avail_slides/main.nf'
include { TILE_SLIDE                 } from '../../../modules/local/tile_slide/main.nf'
include { FORMAT_TILE_DATA_STRUCTURE } from '../../../modules/local/format_tile_data_structure/main.nf'
include { PREPROCESSING_SLIDES       } from '../../../modules/local/pre_processing/main.nf'
include { PREDICT_BOTTLENECK_OUT     } from '../../../modules/local/predict_bottleneck_out/main.nf'
include { POST_PROCESS_FEATURES      } from '../../../modules/local/post_process_features/main.nf'
include { POST_PROCESS_PREDICTIONS   } from '../../../modules/local/post_process_predictions/main.nf'
//
// Subworkflow with functionality specific to the SysBioOncology/SPoTLIghT pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


workflow EXTRACT_HISTOPATHO_FEATURES {
    main:
    ch_versions = Channel.empty()
    // Only required for 'creating a clinical file'
    class_name = params.is_tcga
        ? (params.is_tumor ? "${params.cancer_type}_T" : "${params.cancer_type}_N")
        : params.cancer_type

    ch_clinical_files_input = params.clinical_files_input ? Channel.fromPath(params.clinical_files_input) : Channel.empty()
    ch_image_dir = params.image_dir ? Channel.fromPath("${params.image_dir}", type: 'dir') : Channel.empty()
    ch_images = params.image_dir ? Channel.fromPath("${params.image_dir}/*", type: 'file') : Channel.empty()
    ch_checkpoint_path = params.checkpoint_path ? Channel.fromPath(params.checkpoint_path) : Channel.empty()
    ch_codebook = params.path_codebook ? Channel.fromPath(params.path_codebook) : Channel.empty()
    ch_tissue_classes = params.path_tissue_classes ? Channel.fromPath(params.path_tissue_classes) : Channel.empty()

    ch_images = ch_images.map { image -> [[slide_id: image.simpleName, slide_filename: image.name], image] }
    ch_template_txt = Channel.fromPath("${projectDir}/assets/tmp_clinical_file.txt")

    CREATE_CLINICAL_FILE(
        ch_clinical_files_input.ifEmpty(file("empty")),
        ch_codebook,
        ch_template_txt,
        ch_image_dir,
        class_name,
        params.out_prefix,
        params.tumor_purity_threshold,
        params.is_tcga,
        params.slide_type,
    )
    ch_versions = ch_versions.mix(CREATE_CLINICAL_FILE.out.versions)

    CREATE_LIST_AVAIL_SLIDES(
        CREATE_CLINICAL_FILE.out.txt,
        ch_image_dir,
    )
    ch_versions = ch_versions.mix(CREATE_LIST_AVAIL_SLIDES.out.versions)

    ch_avail_img_to_process = CREATE_LIST_AVAIL_SLIDES.out.csv
        | splitCsv(header: true)
        | map { row -> [[slide_id: row.slide_id, slide_filename: row.slide_filename]] }
    ch_avail_img_to_process = ch_avail_img_to_process.join(ch_images)

    TILE_SLIDE(
        ch_avail_img_to_process,
        params.gradient_mag_filter,
    )
    ch_tiles = TILE_SLIDE.out.jpg.collect()
    ch_versions = ch_versions.mix(TILE_SLIDE.out.versions)

    FORMAT_TILE_DATA_STRUCTURE(
        ch_tiles,
        ch_image_dir,
        CREATE_CLINICAL_FILE.out.txt,
        params.is_tcga,
    )
    ch_versions = ch_versions.mix(FORMAT_TILE_DATA_STRUCTURE.out.versions)

    PREPROCESSING_SLIDES(
        FORMAT_TILE_DATA_STRUCTURE.out.txt,
        ch_tiles,
        params.n_shards,
    )
    ch_versions = ch_versions.mix(PREPROCESSING_SLIDES.out.versions)


    PREDICT_BOTTLENECK_OUT(
        params.bot_out_filename,
        params.pred_out_filename,
        PREPROCESSING_SLIDES.out.tfrecords.collect(),
        params.model_name,
        ch_checkpoint_path,
    )
    ch_versions = ch_versions.mix(PREDICT_BOTTLENECK_OUT.out.versions)


    POST_PROCESS_FEATURES(
        PREDICT_BOTTLENECK_OUT.out.bot_txt,
        params.slide_type,
        params.is_tcga,
    )
    ch_versions = ch_versions.mix(POST_PROCESS_FEATURES.out.versions)


    POST_PROCESS_PREDICTIONS(
        ch_codebook,
        ch_tissue_classes,
        PREDICT_BOTTLENECK_OUT.out.pred_txt,
        params.cancer_type,
        params.slide_type,
    )
    ch_versions = ch_versions.mix(POST_PROCESS_PREDICTIONS.out.versions)

    emit:
    clinical_file = CREATE_CLINICAL_FILE.out.txt
    features      = POST_PROCESS_FEATURES.out.txt_parquet
    predictions   = POST_PROCESS_PREDICTIONS.out.txt_parquet
    versions      = ch_versions
}
