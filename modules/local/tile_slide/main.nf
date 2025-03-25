process TILE_SLIDE {
    label 'process_medium'
    label 'extract_histo_patho_features'

    input:
    tuple val(meta), path(slide_path)
    val gradient_mag_filter

    output:
    tuple val(meta), path("${meta.slide_id}_*.jpg"), emit: jpg

    script:
    """
    create_tiles_from_slides.py \\
        --slide_path ${slide_path} \\
        --gradient_mag_filter ${gradient_mag_filter} \\
        --filename_slide ${meta.slide_filename}

    """

    stub:
    """
    touch ${meta.slide_id}_tile_1.jpg
    touch ${meta.slide_id}_tile_1.jpg

    """
}
