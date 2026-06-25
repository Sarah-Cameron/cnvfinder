

include { BWA } from '../../../modules/local/bwa/main'
include { BAM } from '../../../modules/local/bam/main'

workflow MAP_READS {

    take:
    reads_ch     // channel: [ val(meta), val(assembly_id), path(read1), path(read2) ]
    config_ch    // channel: [ val(meta), val(assembly_id), path(config) ]

    main:
    // join reads and config on meta.id and assembly_id
    BWA(reads_ch)
    BAM(BWA.out.sam.join(config_ch, by: [0,1]))

    emit:
    pytor = BAM.out.results
    versions = Channel.empty()
     .mix(BWA.out.versions)
     .mix(BAM.out.versions)
}
