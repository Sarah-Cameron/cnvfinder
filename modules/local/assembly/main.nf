process ASSEMBLY {
    tag "Downloading assembly ${assembly_id}"
    publishDir params.assemblies, mode: 'copy', pattern: '*.fa'
    maxForks 2

    input:
    tuple val(meta), val(assembly_id)

    output:
    tuple val(meta), val(assembly_id), path("*.fa"), emit: assembly
    path "versions.yml", emit: versions

    script:
    """
    wget https://allthebacteria-assemblies.s3.eu-west-2.amazonaws.com/${assembly_id}.fa.gz
    gunzip ${assembly_id}.fa.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(wget --version | head -n 1 | sed 's/GNU Wget //')
    END_VERSIONS
    """
}
