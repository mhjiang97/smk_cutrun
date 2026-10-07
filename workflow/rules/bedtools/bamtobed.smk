def get_input_bam(wildcards):
    sample = wildcards.sample
    decision = checkpoints.check_duplication_rate.get(sample=sample).output.txt
    with open(decision) as fh:
        infix = ".md" if fh.read().strip() == "remove" else ""
    return f"bowtie2/{sample}/{sample}.sorted{infix}.filtered.bam"


rule bedtools_bamtobed:
    input:
        bam=get_input_bam,
    output:
        bedpe="bedtools/{sample}/{sample}.bedpe",
    log:
        "logs/{sample}/bamtobed.log",
    conda:
        "../../envs/bedtools.yaml"
    shell:
        """
        bedtools bamtobed \\
            -bedpe \\
            -i {input.bam} \\
            1>{output.bedpe} 2>{log}
        """


rule clean_bedpe:
    input:
        bedpe="bedtools/{sample}/{sample}.bedpe",
    output:
        bedpe="bedtools/{sample}/{sample}.clean.bedpe",
    log:
        "logs/{sample}/clean_bedpe.log",
    conda:
        "../../envs/bedtools.yaml"
    shell:
        """
        awk '$1==$4 && $6-$2 < 1000 {{print $0}}' {input.bedpe} \\
            1>{output.bedpe} 2>{log}
        """
