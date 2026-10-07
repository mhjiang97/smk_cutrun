rule mark_duplicates:
    input:
        bam=f"bowtie2/{{sample}}/{{sample}}.sorted.bam",
        fasta=config["fasta"],
    output:
        bam=protected(f"bowtie2/{{sample}}/{{sample}}.sorted.md.bam"),
        bai=temp(f"bowtie2/{{sample}}/{{sample}}.sorted.md.bai"),
        bai_renamed=protected(f"bowtie2/{{sample}}/{{sample}}.sorted.md.bam.bai"),
        metrics=f"bowtie2/{{sample}}/{{sample}}.sorted.md.metrics.txt",
    log:
        "logs/{sample}/mark_duplicates.log",
    conda:
        "../../envs/gatk.yaml"
    resources:
        tmpdir=lambda wildcards: f"bowtie2/{wildcards.sample}",
    shell:
        """
        exec 1>{log} 2>&1

        gatk MarkDuplicates \\
            --java-options \"-Xmx{resources.mem_mb}M -XX:-UsePerfData\" \\
            --INPUT {input.bam} \\
            --OUTPUT {output.bam} \\
            --METRICS_FILE {output.metrics} \\
            --REMOVE_DUPLICATES false \\
            --CREATE_INDEX true \\
            --ASSUME_SORT_ORDER coordinate \\
            --REFERENCE_SEQUENCE {input.fasta} \\
            --TMP_DIR {resources.tmpdir}

        cp {output.bai} {output.bai_renamed}
        touch {output.bai_renamed}
        """
