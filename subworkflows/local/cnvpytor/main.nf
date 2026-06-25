

include { CNVPREDICT } from '../../../modules/local/cnvpytor/main'

workflow CALL_CNVS {

    take:
    pytor_ch     // channel: [ val(meta), val(assembly_id), path(depth), path(txt), path(pytor) ]
    config_ch    // channel: [ val(meta), val(assembly_id), path(config) ]

    main:
    cnv_input = pytor_ch.map { meta, assembly_id, depth, txt, pytor ->
                    [ meta, assembly_id, pytor ] }
                .join(config_ch, by: [0, 1])

    CNVPREDICT(cnv_input)

    emit:
    versions = Channel.empty()
        .mix(CNVPREDICT.out.versions)
}
