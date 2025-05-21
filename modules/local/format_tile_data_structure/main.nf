process FORMAT_TILE_DATA_STRUCTURE {
    label 'process_single'
    label "extract_histo_patho_features"

    input:
    path all_tiles, stageAs: "tiles/*"
    path image_dir
    path clinical_file_path
    val is_tcga

    output:
    path "file_info_train.txt", emit: txt
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''

    def is_tcga_to_int = is_tcga ? "--is_tcga" : ""

    """
    format_tile_data_structure.py \
        ${args} \\
        --nf-process-id ${task.process} \\
        --tiles_folder tiles \
        --slides_folder ${image_dir} \
        --clin_path ${clinical_file_path} \
        ${is_tcga_to_int}
    """

    stub:
    """
    touch "file_info_train.txt"
    touch "versions.yml"

    """
}
