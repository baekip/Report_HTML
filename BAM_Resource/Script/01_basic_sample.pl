#!/bin/perl

use strict;
use warnings;

if ( 1 != @ARGV ) {
    printUsage();
}

my %info;
my $in_config = $ARGV[0];
read_config ($in_config, \%info);

my $project_path = $info{project_path};
my $result_path = "$project_path/result/";
my $html_report_path = "$result_path/61_html_report/";
mkdir_dir($html_report_path);

my $total_rmd_file = "$html_report_path/html_report.Rmd";
check_file($total_rmd_file);

open my $fh_html, '>>', $total_rmd_file or die;

print $fh_html "\# Basic sample metrics\n";
print $fh_html "A quick summary of sample metrics to identify outliers. Offtargets will be set to 0 for non-targeted experiments, and table cells are color-coded to indivate deviation from the mean for a given metric. Note that this may bne expected depending on the experimental setup.\n\n";
print $fh_html "\`\`\`{r table, results=\'asis\'}\n";
print $fh_html "stat = read.table(file.path(path_results,\"rawdata\",\"Sequencing_Statistics_Result.xls\"), header=T, sep=\"\\t\", check.names=F, colClasses=list(\"sample\"=\"character\"))\n";
print $fh_html "rownames(stat) = stat\$SampleID\n\n";

print $fh_html "\# Define metrics to display and fix missing\n";
print $fh_html "metrics = c(\"SampleID\",\"Index\",\"TotalReads\",\"TotalBases\",\"GC_Count\",\"GC_Rate\",\"N_ZeroReads\",\"N_ZeroReadsRate\",\"N5_LessReads\",\"N5_LessReadsRate\",\"N_Count\",\"N_Rate\",\"Q30_MoreBases\",\"Q30_MoreBasesRate\",\"Q20_MoreBases\",\"Q20_MoreBasesRate\")\n";

print $fh_html "missing = setdiff (metrics, colnames(stat))\n";
print $fh_html "if (length(missing) \>0 ){ for (col in missing){stat[,col]=0}}\n";

close $fh_html;

#-----------------------------
sub check_file {
    my $file = shift;
    if (!-f $file){
        die "ERROR! not found <$file>\n";
    }
}

sub mkdir_dir {
    my $dir_name = shift;
    if (!-d $dir_name) {
        my $cmd_dir = "mkdir -p $dir_name";
        system ($cmd_dir);
    }
}

sub read_config {
    my ($config, $ref_hash) = @_;
    open my $fh, '<:encoding(UTF-8)', $config or die;
    while (my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        if (length($row) == 0) {next;}
        my ($key, $value) = split /\=/, $row;
        $key = trim ($key);
        $value = trim ($value);
        $ref_hash->{$key}=$value;
    }close $fh;
}

sub trim {
    my @result = @_;
    foreach (@result){
        s/^\s+//g;
        s/\s+$//g;
    }
    return wantarray ? @result:$result[0];
}

sub printUsage {
    print "Usage: perl $0 <in.config> \n";
    print "Example: perl $0 wes_config_human.txt \n";
    exit;
}
