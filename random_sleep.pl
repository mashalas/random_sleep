
use strict;

my $REQUIRED_PARAMETERS_COUNT = 2;

sub help()
{
  print "random_sleep.pl <min_duration> <max_duration> [v|verbose]\n\n";
}

#--------------------------------�������� �� ������ ����� ������----------------------------
sub is_int_number($)
{
my $s = shift;

  return 1 if ($s =~ /^[-+]?\d+$/);
  return 0;
}

#-------------------------------------���������� �� ������----------------------------------
sub round_int($)
{
my $x = shift;
my $result;

  if ($x > 0) {
    $result = int($x + 0.5);
  }
  elsif ($x < 0) {
    $x = -$x;
    $result = int($x + 0.5);
    $result = -$result;
  }
  else {
    $result = $x;
  }
  return $result;
}

#-----------------------��������� ����� ����� � �������� �������� (������� �����)---------------
sub get_random_int($$)
{
my $min_value = shift;
my $max_value = shift;
my $result;

  return $min_value if ($min_value == $max_value); # ��� ����� ������ ���������
  $result = $min_value + ($max_value - $min_value)*rand();
  $result = round_int($result);
  return $result;
}

sub random_test()
{
my $N = 500;
my $lower_limit = -50;
my $upper_limit = -10;
my ($min_x, $max_x);
my $avg = 0.0;

  for (my $i=0; $i<$N; $i++) {
    my $x = get_random_int($lower_limit, $upper_limit);
    print "$x ";
    $avg += $x;
    if ($i == 0) {
      $min_x = $x;
      $max_x = $x;
    }
    else {
      $min_x = $x if ($x < $min_x);
      $max_x = $x if ($x > $max_x);
    }
  }
  $avg /= $N;
  print "\n";
  print "min_x=$min_x  max_=$max_x  avg=$avg\n";
}

#-------------------------------------������� ����� ������--------------------------------------
sub strlen
{
my $s = shift;
my $count = 0;
  
  while ($s =~ /./g) {
    $count++;
  }
  return $count;
}

#------------�������� �������� ������ � ������ ������ �� ��������� �������� ����� ������-----------
sub append_before_str($$$)
{
my $src_str = shift;
my $symb = shift;
my $target_length = shift;
my $result = $src_str;

  while (strlen($result) < $target_length) {
    $result = $symb . $result;
  }
  return $result;
}

#------------------------������� ����/����� � ������� yyyy-mm-dd hh:mm:ss--------------------------
sub get_timestamp
{
my $custom_time = shift;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);# = localtime();
my $result;

  if ($custom_time == undef) {
    $custom_time = time();
  }
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($custom_time);
  $result = 1900 + $year;
  $result .= "-" . append_before_str($mon, "0", 2);
  $result .= "-" . append_before_str($mday, "0", 2);
  $result .= " " . append_before_str($hour, "0", 2);
  $result .= ":" . append_before_str($min, "0", 2);
  $result .= ":" . append_before_str($sec, "0", 2);

  return $result;
}

#------------------������� ���������� ��� ��������� ����������� �������------------------
sub swap_with_return
{
  my $var0 = shift;
  my $var1 = shift;
  return ($var1, $var0);
}

#-----�������� ������� �������� � ���������� � ������� ���������� (������ �� ������������)-----
sub swap
{
  my $ref0 = \$_[0];
  my $ref1 = \$_[1];
  my $val0 = $_[0];
  my $val1 = $_[1];
  $$ref0 = $val1;
  $$ref1 = $val0;
}

#---------��������������� ���������� ���������� (verbose ����� ���� ������, ������ ��� ���������)---------
sub correct_verbosity_argument_placement($$$)
{
  my $a = shift;
  my $b = shift;
  my $c = shift;
  my ($min_duration, $max_duration, $verbose);

  if ($c ne "") {
    # �������� 3 ���������
    if ($a =~ /^-?v$/i || $a =~ /^-{0,2}verbose$/i) {
      # � ������ ��������� ���� v/verbose
      $min_duration = $b;
      $max_duration = $c;
      $verbose = $a;
    }
    elsif ($b =~ /^-?v$/i || $b =~ /^-{0,2}verbose$/i) {
      # �� ������ ��������� ���� v/verbose
      $min_duration = $a;
      $max_duration = $c;
      $verbose = $b;
    }
    else {
      $min_duration = $a;
      $max_duration = $b;
      $verbose = $c;
    }
  }
  else {
    $min_duration = $a;
    $max_duration = $b;
    $verbose = "";
  }
  if ($verbose ne "") {
    $verbose =~ s/^-+//;
    $verbose = lc($verbose);
  }
  return ($min_duration, $max_duration, $verbose);
}

sub correct_duration_order($$)
{
my $a = shift;
my $b = shift;
my ($min_duration, $max_duration);

  if ($a <= $b) {
    $min_duration = $a;
    $max_duration = $b;
  }
  else {
    $min_duration = $b;
    $max_duration = $a;
  }
  return ($min_duration, $max_duration);
}

sub get_duration_seconds($)
{
my $raw_duration = shift;
my $seconds_duration = -1; # ���� �������� ������ (���������� �������� �� �������� ������ � ����� �� ��������� smhd ��������������� second/minute/hour/day, �� ������� ��������� -1
my ($value, $measure);
my $measure_size = 1;

  if ($raw_duration =~ /^(\d+)([smhd]?)$/i) {
    # ������� ������� ���������
    $value = $1;
    $value *= 1;
    $measure = $2;
    $measure = lc($measure);
    #print "empty measure\n" if ($measure eq "");
    #print "[$value] [$measure]\n";
    $measure_size = 60    if ($measure eq "m"); # ������
    $measure_size = 3600  if ($measure eq "h"); # ����
    $measure_size = 86400 if ($measure eq "d"); # ���
    $seconds_duration = $value * $measure_size;
  }
  return ($seconds_duration, $measure_size);
}

sub get_measure_name
{
my $measure_size = shift;
  
  return "minute" if ($measure_size == 60);
  return "hour" if ($measure_size == 3600);
  return "day" if ($measure_size == 86400);
  return "second";
}

#-----------------����� ������������� ��������� ���������� ������ (� �������� ���������)------------
sub random_sleep
{
my $ERROR_wrong_format_for_min_duration = -1;
my $ERROR_wrong_format_for_max_duration = -2;
my $NO_ERROR = 0;
my $min_duration = shift;
my $max_duration = shift;
my $verbose = shift;
my $duration;
my $s;
my ($min_duration_measure_size, $max_duration_measure_size, $measure_size);
my $atom_sleep;
my ($min_intervals_count, $max_intervals_count, $intervals_count);

  #print "QQQ1 $min_duration, $max_duration, $verbose\n";
  # [-]v|verbose ���� �� ��������� ����������, �� ������ ���
  ($min_duration, $max_duration, $verbose) = correct_verbosity_argument_placement($min_duration, $max_duration, $verbose);
  #print "QQQ2 $min_duration, $max_duration, $verbose\n";
  
  ($min_duration, $min_duration_measure_size) = get_duration_seconds($min_duration);
  if ($min_duration < 0) {
    print "ERROR: wrong format for min_duration.\n";
    return $ERROR_wrong_format_for_min_duration;
  }

  ($max_duration, $max_duration_measure_size) = get_duration_seconds($max_duration);
  if ($max_duration < 0) {
    print "ERROR: wrong format for max_duration.\n";
    return $ERROR_wrong_format_for_max_duration;
  }

  #($min_duration, $max_duration) = correct_duration_order($min_duration, $max_duration);
  if ($min_duration > $max_duration) {
    # �������� ������� ���������� ����������� � ������������ ����������������� (������� ������ ���� �����������)
    swap($min_duration, $max_duration);
  }
  $measure_size = $min_duration_measure_size;
  $measure_size = $max_duration_measure_size if ($max_duration_measure_size < $min_duration_measure_size);
  $min_intervals_count = $min_duration / $measure_size;
  $max_intervals_count = $max_duration / $measure_size;
  $intervals_count = get_random_int($min_intervals_count, $max_intervals_count);
  #print "QQQ3 min_duration=$min_duration, max_duration=$max_duration, verbose=$verbose measure_size=$measure_size min_intervals_count=$min_intervals_count max_intervals_count=$max_intervals_count intervals_count=$intervals_count\n";

  if ($verbose eq "v" || $verbose eq "verbose") {
    #���� ��������� ����� - ������� ������� ���������� �������� �� 1 ������� ��������� � ������� ��� ����� ����� ������
    my $total_sleep_duration_seconds = $intervals_count * $measure_size; # ����� ����������������� ��� � ��������
    my $wake_time = time() + $total_sleep_duration_seconds;
    my $wake_timestamp = get_timestamp($wake_time);

    if ($measure_size > 1) {
      # ��������� ������ 1 ������� (������, ���, ����)
      my $measure_name = get_measure_name($measure_size);
      $measure_name .= "s";
      print "sleep $intervals_count times by 1 $measure_name  (totaly $total_sleep_duration_seconds seconds)\n";
    }
    else {
      # ��������� - �������
      print "sleep seconds: $total_sleep_duration_seconds\n";
    }
    print "wake at $wake_timestamp\n";
  }

  for (my $i=$intervals_count; $i>=1; $i--) {
    # ���� ���
    if ($verbose eq "verbose") {
      $s = "[" . get_timestamp() . "]";
      $s .= "\t" . "$i / $intervals_count";
      print "$s\n";
    }
    sleep($measure_size);
  }

  if ($verbose eq "verbose") {
    # ������ �����, ����� ��������� ���, ���� ������� ����� ����������� �����
    $s = "[" . get_timestamp() . "]";
    $s .= "\t" . "complete";
    print "$s\n";
  }

  return $NO_ERROR;
}

#-----------------------------------------main--------------------------------------
#print is_int_number($ARGV[0]);
#print $#ARGV;
#for (my $i=-21; $i<=35; $i++) {
#  my $x = $i / 10.999;
#  my $y = round_int($x);
#  print "$i) $x $y\n";
#my $a = get_random_int($ARGV[0], $ARGV[1]); print "$a\n";
#}
#my $s = append_before_str("qwe", "_", 5); print "$s\n";
#my $s = get_timestamp(); print "$s\n";
#exit(0);

#my $a = time();
#my $b = $a + 5;
#my $c = localtime();
#my $d = localtime($b);
#my $s1 = get_timestamp();
#my $s2 = get_timestamp($b);
#print "$a $b $c $d $s1 $s2\n";
#exit(0);

if ($#ARGV == -1) {
  # ��� ����������
  help();
  exit(0);
}
if ($#ARGV < $REQUIRED_PARAMETERS_COUNT-1) {
  # ������������ ����������
  print "ERROR: not enought parameters.\n";
  help();
  exit(1);
}
my $err_code = random_sleep($ARGV[0], $ARGV[1], $ARGV[2]);
exit($err_code);
