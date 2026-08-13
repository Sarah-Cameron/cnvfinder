

process CNVPREDICT {
    tag "Calling CNVs for ${meta.id}"
    publishDir params.calls_dir, mode: params.publish_dir_mode, pattern: '*.tsv'

    maxForks 10
    container 'quay.io/biocontainers/cnvpytor:1.3.1--pyhdfd78af_0'

    input:
    tuple val(meta), val(assembly_id), path(pytor), path(config)

    output:
    tuple val(meta), val(assembly_id), path("*.tsv"), emit: calls
    path "versions.yml", emit: versions

    script:
    """
    cnvpytor -conf ${config} -root ${pytor} -his ${params.bin_size}
    cnvpytor -conf ${config} -root ${pytor} -partition ${params.bin_size}
    cnvpytor -conf ${config} -root ${pytor} -call ${params.bin_size} \
        > ${meta.id}_${assembly_id}_calls.${params.bin_size}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cnvpytor: \$(cnvpytor --version 2>&1 | grep "CNVpytor" | sed 's/CNVpytor //')
    END_VERSIONS
    """
}
