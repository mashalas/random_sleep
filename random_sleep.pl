
use strict;

my $REQUIRED_PARAMETERS_COUNT = 2;

sub help()
{
  print "random_sleep.pl <min_duration> <max_duration> [v|verbose]\n\n";
}

#--------------------------------явл€етс€ ли строка целым числом----------------------------
sub is_int_number($)
{
my $s = shift;

  return 1 if ($s =~ /^[-+]?\d+$/);
  return 0;
}

#-------------------------------------ќкругление до целого----------------------------------
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

#-----------------------—лучайное целое число в заданных пределах (включа€ концы)---------------
sub get_random_int($$)
{
my $min_value = shift;
my $max_value = shift;
my $result;

  $result = $min_value + ($max_value - $min_value)*rand();
  $result = round_int($result);
  return $result;
}

#-------------------------------------¬ернуть длину строки--------------------------------------
sub strlen
{
my $s = shift;
my $count = 0;
  
  while ($s =~ /./g) {
    $count++;
  }
  return $count;
}

#------------ƒобавить заданный символ в начале строки до получени€ заданной длины строки-----------
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

#------------------------“екущие дата/врем€ в формате yyyy-mm-dd hh:mm:ss--------------------------
sub get_current_timestamp()
{
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
my $result;

  $result = 1900 + $year;
  $result .= "-" . append_before_str($mon, "0", 2);
  $result .= "-" . append_before_str($mday, "0", 2);
  $result .= " " . append_before_str($hour, "0", 2);
  $result .= ":" . append_before_str($min, "0", 2);
  $result .= ":" . append_before_str($sec, "0", 2);

  return $result;
}

#------------------¬ернуть переданные два параметра помен€нными местами------------------
sub swap_with_return
{
  my $var0 = shift;
  my $var1 = shift;
  return ($var1, $var0);
}

#-----ѕомен€ть местами значени€ в переданных в функцию переменных (ничего не возвращаетс€)-----
sub swap
{
  my $ref0 = \$_[0];
  my $ref1 = \$_[1];
  my $val0 = $_[0];
  my $val1 = $_[1];
  $$ref0 = $val1;
  $$ref1 = $val0;
}

#—корректировать очерЄдность параметров (verbose может быть первым, вторым или последним)
sub correct_arguments_order($$$)
{
  my $a = shift;
  my $b = shift;
  my $c = shift;
  my ($min_duration, $max_duration, $verbose);

  if ($c ne "") {
    # передано 3 параметра
    if ($a =~ /^-?v$/i || $a =~ /^-?verbose/i) {
      # в первом параметре флаг v/verbose
      $min_duration = $b;
      $max_duration = $c;
      $verbose = $a;
    }
    elsif ($b =~ /^-?v$/i || $b =~ /^-?verbose/i) {
      # во втором параметре флаг v/verbose
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
    $verbose =~ s/^-//;
    $verbose = lc($verbose);
  }
  return ($min_duration, $max_duration, $verbose);
}

#-----------------ѕауза длительностью случайное количество секунд (в заданном интервале)------------
sub random_sleep
{
my $min_duration = shift;
my $max_duration = shift;
my $verbose = shift;
my $duration;
my $s;

  #print "!!!1 $min_duration, $max_duration, $verbose\n";
  ($min_duration, $max_duration, $verbose) = correct_arguments_order($min_duration, $max_duration, $verbose);
  #print "!!!2 $min_duration, $max_duration, $verbose\n";

  if (is_int_number($min_duration) == 0) {
    print "ERROR: \"min_duration\" is not integer.\n";
    return 2;
  }
  if (is_int_number($max_duration) == 0) {
    print "ERROR: \"max_duration\" is not integer.\n";
    return 3;
  }

  $min_duration *= 1;
  $max_duration *= 1;

  if ($min_duration < 0) {
    print "ERROR: \"min_duration\" can not be negative.\n";
    return 4;
  }
  if ($max_duration < 0) {
    print "ERROR: \"max_duration\" can not be negative.\n";
    return 5;
  }
  
  if ($min_duration > $max_duration) {
    print "ERROR: \"min_duration\" is greater than \"max_duration\"\n";
    return 6;
  }
  elsif ($min_duration == $max_duration) {
    $duration = $min_duration;
  }
  else {
    $duration = get_random_int($min_duration, $max_duration);
  }

  if ($verbose eq "verbose") {
    print "sleep duration = $duration\n";
    for (my $i=$duration; $i>=1; $i--) {
      $s = "[" . get_current_timestamp() . "]";
      $s .= "\t" . "$i / $duration";
      print "$s\n";
      sleep(1);
    }
    print "\n";
  }
  elsif ($verbose eq "v") {
    #print "sleep duration = $duration\n" if ($verbose == "v");
    print "sleep duration = $duration\n";
    sleep($duration);
  }
  else {
    sleep($duration);
  }
  return 0;
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
#my $s = get_current_timestamp(); print "$s\n";
#exit(0);

if ($#ARGV == -1) {
  # нет параметров
  help();
  exit(0);
}
if ($#ARGV < $REQUIRED_PARAMETERS_COUNT-1) {
  # недостаточно параметров
  print "ERROR: not enought parameters.\n";
  help();
  exit(1);
}
my $err_code = random_sleep($ARGV[0], $ARGV[1], $ARGV[2]);
exit($err_code);
