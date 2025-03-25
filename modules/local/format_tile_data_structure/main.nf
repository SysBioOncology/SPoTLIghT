process FORMAT_TILE_DATA_STRUCTURE {
    label 'process_single'
    label "extract_histo_patho_features"

    input:
    tuple val(meta), path(all_tiles)
    path clinical_file_path
    val is_tcga

    output:
    path "file_info_train.txt", emit: txt

    script:
    is_tcga_to_int = is_tcga ? 1 : 0
    """
    format_tile_data_structure.py \
        --tiles_folder \${PWD} \
        --is_tcga ${is_tcga_to_int} \
        --clin_path ${clinical_file_path}
    """

    stub:
    """
    touch "file_info_train.txt"
    """
}
