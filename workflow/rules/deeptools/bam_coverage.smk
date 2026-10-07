def get_input_bam(wildcards):
    sample = wildcards.sample
    decision = checkpoints.check_duplication_rate.get(sample=sample).output.txt
    with open(decision) as fh:
        infix = ".md" if fh.read().strip() == "remove" else ""
    return f"bowtie2/{sample}/{sample}.sorted{infix}.filtered.bam"


rule bam_coverage:
    input:
        bam=get_input_bam,
    output:
        bedgraph="deeptools/{sample}/{sample}.bedgraph",
    log:
        "logs/{sample}/bam_coverage.log",
    conda:
        "../../envs/deeptools.yaml"
    threads: 1
    params:
        mode_normalization=config["mode_normalization"],
        size_bin=1,
        size_genome=SIZES_GENOME[config["genome"]],
    shell:
        """
        bamCoverage \\
            --numberOfProcessors {threads} \\
            --bam {input.bam} \\
            --outFileFormat bedgraph \\
            --outFileName {output.bedgraph} \\
            --binSize {params.size_bin} \\
            --normalizeUsing {params.mode_normalization} \\
            --effectiveGenomeSize {params.size_genome} \\
            --skipNAs \\
            --extendReads \\
            1>{log} 2>&1
        """
