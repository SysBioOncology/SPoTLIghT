process CREATE_CLINICAL_FILE {
    label 'process_single'
    label "extract_histo_patho_features"

    input:
    path clinical_files_input
    path path_codebook
    path template_txt
    path image_dir
    val class_name
    val out_prefix
    val tumor_purity_threshold
    val is_tcga
    val slide_type

    output:
    path "${out_prefix}.txt", emit: txt
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    out_prefix = task.ext.prefix ? task.ext.prefix : out_prefix
    def VERSION = '0.9.1'
    // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    if (is_tcga && slide_type == "FF") {
        """
        create_clinical_file.py ${args} \\
            --nf-process-id ${task.process} \\
            --class_name ${class_name} \\
            --clinical_files_input ${clinical_files_input} \\
            --tumor_purity_threshold ${tumor_purity_threshold} \\
            --path_codebook ${path_codebook}
        """
    }
    else {
        list_txt = "list_images.txt"
        """
        ls ${image_dir} | tee ${list_txt}
        awk -v a=81 -v b="${class_name}" -v c=41 'FNR==NR{print; next}{split(\$1, tmp, "."); OFS="\t"; print tmp[1], tmp[1], \$1, a, b, c}' ${template_txt} ${list_txt} > ${out_prefix}.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            ls: \$( ls --version | head -n 1 | awk '{print \$4}' )
            awk: \$(  awk --version | head -n 1 | awk '{print \$3 }' | sed 's/,//' )

        END_VERSIONS


        """
    }

    stub:
    """
    touch ${out_prefix}.txt
    touch "versions.yml"

    """
}
