//
// Subworkflow with functionality specific to the SysBioOncology/SPoTLIghT pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include {   CREATE_CLINICAL_FILE  } from '../../../modules/local/createclinicalfile.nf'
include {   CREATE_LIST_AVAIL_SLIDES } from '../../../modules/local/createlistavailableslides.nf'
include {   TILE_SLIDE } from '../../../modules/local/tileslide.nf'
include {   FORMAT_TILE_DATA_STRUCTURE  } from '../../../modules/local/formattiledatastructure.nf'
include {   PREPROCESSING_SLIDES } from '../../../modules/local/preprocessingslides.nf'
include {   PREDICT_BOTTLENECK_OUT  } from '../../../modules/local/predictbottleneckout.nf'
include {   POST_PROCESSING_FEATURES    } from '../../../modules/local/postprocessingfeatures.nf'
include {   POST_PROCESSING_PREDICTIONS } from '../../../modules/local/postprocessingpredictions.nf'

workflow EXTRACT_HISTOPATHO_FEATURES {
    take:
        clinical_files_input
        path_codebook
        cancer_type
        is_tumor
        out_prefix
        tumor_purity_threshold
        is_tcga
        image_dir
        gradient_mag_filter
        n_shards
        bot_out_filename
        pred_out_filename
        model_name
        checkpoint_path
        slide_type
        path_tissue_classes

    main:
    // Only required for 'creating a clinical file'
    class_name = is_tcga 
    ? (is_tumor ? "${cancer_type}_T" : "${cancer_type}_N")
    : cancer_type

    CREATE_CLINICAL_FILE(
        clinical_files_input        = clinical_files_input,
        class_name                  = class_name,
        out_prefix                  = out_prefix,
        path_codebook               = path_codebook,
        tumor_purity_threshold      = tumor_purity_threshold,
        is_tcga                     = is_tcga,
        image_dir                   = image_dir,
        slide_type                  = slide_type
    )
    CREATE_LIST_AVAIL_SLIDES(
        clinical_file_path          = CREATE_CLINICAL_FILE.out.txt,
        image_dir                   = image_dir
    )

    avail_img_to_process = CREATE_LIST_AVAIL_SLIDES.out.csv \
                                    | splitCsv(header:true) \
                                    | map { row -> tuple(row.slide_id, row.slide_filename, file("${image_dir}/${row.slide_filename}")) }
    TILE_SLIDE (
        avail_img_to_process    = avail_img_to_process,
        gradient_mag_filter     = gradient_mag_filter,
    )

    FORMAT_TILE_DATA_STRUCTURE(
        all_tiles               = TILE_SLIDE.out.jpg.collect(),
        clinical_file_path      = CREATE_CLINICAL_FILE.out.txt,
        image_dir               = image_dir,
        is_tcga                 = is_tcga
    )

    PREPROCESSING_SLIDES(
        file_info_train         = FORMAT_TILE_DATA_STRUCTURE.out.txt,
        n_shards                = n_shards
    )

    PREDICT_BOTTLENECK_OUT(
        bot_out_filename        = bot_out_filename,
        pred_out_filename       = pred_out_filename,
        tf_records              = PREPROCESSING_SLIDES.out.tfrecords.collect(),
        model_name              = model_name,
        checkpoint_path         = checkpoint_path
    )

    POST_PROCESSING_FEATURES(
        bot_train_file          = PREDICT_BOTTLENECK_OUT.out.bot_txt,
        slide_type              = slide_type,
        is_tcga                 = is_tcga
    )

    POST_PROCESSING_PREDICTIONS(
        path_codebook           = path_codebook,
        path_tissue_classes     = path_tissue_classes,
        pred_train_file         = PREDICT_BOTTLENECK_OUT.out.pred_txt,
        cancer_type             = cancer_type,
        slide_type              = slide_type
    )

    emit:
    clinical_file   = CREATE_CLINICAL_FILE.out.txt
    features        = POST_PROCESSING_FEATURES.out.txt_parquet
    predictions     = POST_PROCESSING_PREDICTIONS.out.txt_parquet
}
