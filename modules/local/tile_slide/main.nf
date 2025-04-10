process TILE_SLIDE {
    label 'process_medium'
    label 'extract_histo_patho_features'
    tag "${meta.slide_id}"

    input:
    tuple val(meta), path(slide_path)
    val gradient_mag_filter

    output:
    path "${meta.slide_id}_*.jpg", emit: jpg
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    """
    create_tiles_from_slides.py ${args} \\
        --nf-process-id ${task.process} \\
        --slide_path ${slide_path} \\
        --gradient_mag_filter ${gradient_mag_filter} \\
        --filename_slide ${meta.slide_filename}

    """

    stub:
    """
    touch ${meta.slide_id}_tile_1.jpg
    touch ${meta.slide_id}_tile_1.jpg
    touch "versions.yml"

    """
}
