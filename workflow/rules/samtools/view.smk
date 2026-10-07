def get_percent_duplication(metrics):
    with open(metrics) as fh:
        rows = [
            line.rstrip("\n").split("\t")
            for line in fh
            if line.strip() and not line.startswith("#")
        ]
    return float(dict(zip(rows[0], rows[1]))["PERCENT_DUPLICATION"])


checkpoint check_duplication_rate:
    input:
        metrics=f"bowtie2/{{sample}}/{{sample}}.sorted.md.metrics.txt",
    output:
        txt=f"bowtie2/{{sample}}/{{sample}}.duplication_decision.txt",
    log:
        log="logs/{sample}/check_duplication_rate.log",
    params:
        max_rate=config["max_rate_duplication"],
    run:
        rate = get_percent_duplication(input.metrics)
        remove = rate > params.max_rate
        decision = "remove" if remove else "keep"
        with open(output.txt, "w") as fh:
            fh.write(f"{decision}\n")
        with open(log.log, "w") as fh:
            fh.write(
                f"PERCENT_DUPLICATION={rate} max_rate={params.max_rate} decision={decision}\n"
            )


rule samtools_view:
    input:
        bam=f"bowtie2/{{sample}}/{{sample}}.sorted.bam",
        bai=f"bowtie2/{{sample}}/{{sample}}.sorted.bam.csi",
        bed="ref/include.bed",
    output:
        bam=protected(f"bowtie2/{{sample}}/{{sample}}.sorted.filtered.bam"),
        bai=protected(f"bowtie2/{{sample}}/{{sample}}.sorted.filtered.bam.csi"),
    log:
        "logs/{sample}/samtools_view.log",
    threads: 1
    params:
        exclude_flags="UNMAP,SECONDARY,SUPPLEMENTARY",
    shell:
        """
        samtools view \\
            -@ {threads} \\
            -b \\
            -L {input.bed} \\
            -M \\
            -f PAIRED \\
            -F {params.exclude_flags} \\
            -q 30 \\
            --write-index \\
            -o {output.bam} \\
            {input.bam} \\
            1>{log} 2>&1
        """


use rule samtools_view as samtools_view_md with:
    input:
        bam=f"bowtie2/{{sample}}/{{sample}}.sorted.md.bam",
        bai=f"bowtie2/{{sample}}/{{sample}}.sorted.md.bam.bai",
        bed="ref/include.bed",
    output:
        bam=protected(f"bowtie2/{{sample}}/{{sample}}.sorted.md.filtered.bam"),
        bai=protected(f"bowtie2/{{sample}}/{{sample}}.sorted.md.filtered.bam.csi"),
    log:
        "logs/{sample}/samtools_view_md.log",
    params:
        exclude_flags="UNMAP,DUP,SECONDARY,SUPPLEMENTARY",
