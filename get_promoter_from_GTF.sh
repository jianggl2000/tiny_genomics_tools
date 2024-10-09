# This awk script processes a GTF file to extract promoter regions for genes and outputs them in a tab-separated format.
# Promoter is defined as +1500 ~ -500 bp region. Change the numbers if you want a different region
# only promoters for protein coding genes were exported

GTF=/path/to/your/genome.gtf
upstream=1500
downstream=500

awk -v upstream=$upstream -v downstream=$downstream \
'BEGIN {
    OFS="\t"
    print "GeneID\tChr\tStart\tEnd\tStrand"
}

$3 == "gene" {
    split($0, a, "\t")
    chr = $1
    start = $4
    end = $5
    strand = $7
    
    split(a[9], attrs, ";")
    for (i in attrs) {
        if (attrs[i] ~ /gene_type/) {
            split(attrs[i], gene_type, " ")
            if (gene_type[2] ~ /protein_coding/)
                skip="FALSE"
        }
        if (attrs[i] ~ /gene_name/) {
            split(attrs[i], gene_name, " ")
            gsub(/"/, "", gene_name[2])
            break
        }
    }
    
    if (strand == "+") {
        promoter_start = start - upstream
        promoter_end = start + downstream
    } else if (strand == "-") {
        promoter_start = end - downstream
        promoter_end = end + upstream
    }
    
    if (promoter_start < 1) promoter_start = 1
    
    if(skip=="FALSE") print gene_name[2], chr, promoter_start, promoter_end, strand
}' $GTF | tee promoters.saf | \
  awk '{print $2,$3-1,$4,$1,".",$5}' | sed '1d' > promoters.bed

