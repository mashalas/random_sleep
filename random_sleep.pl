#!/usr/bin/perl

use strict;

my $REQUIRED_PARAMETERS_COUNT = 2;

sub help()
{
  print "random_sleep.pl <min_duration[measure]> <max_duration[measure]> [v|verbose]\n";
  print "\tmin_duration, max_duration - minimal and maximal sleep interval\n";
  print "\tmeasure - units of measure for min/max-intervals: s or none=seconds, m=minutes, h=hours, d=days, w=weeks\n";
  print "\tv|verbose - verbose mode; \"verbose\" - more verbosive than \"v\".\n";
  print "\n";
}

#--------------------------------Является ли строка целым числом----------------------------
sub is_int_number($)
{
my $s = shift;

  return 1 if ($s =~ /^[-+]?\d+$/);
  return 0;
}

#-------------------------------------Округление до целого----------------------------------
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

#-----------------------Случайное целое число в заданных пределах (включая концы)---------------
sub get_random_int($$)
{
my $min_value = shift;
my $max_value = shift;
my $result;

  return $min_value if ($min_value == $max_value); # оба числа границ совпадают
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

#-------------------------------------Вернуть длину строки--------------------------------------
sub strlen
{
my $s = shift;
my $count = 0;
  
  while ($s =~ /./g) {
    $count++;
  }
  return $count;
}

#------------Добавить заданный символ в начале строки до получения заданной длины строки-----------
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

#------------------------Текущие дата/время в формате yyyy-mm-dd hh:mm:ss--------------------------
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

#------------------Вернуть переданные два параметра поменянными местами------------------
sub swap_with_return
{
  my $var0 = shift;
  my $var1 = shift;
  return ($var1, $var0);
}

#-----Поменять местами значения в переданных в функцию переменных (ничего не возвращается)-----
sub swap
{
  my $ref0 = \$_[0];
  my $ref1 = \$_[1];
  my $val0 = $_[0];
  my $val1 = $_[1];
  $$ref0 = $val1;
  $$ref1 = $val0;
}

#---------Скорректировать очерёдность параметров (verbose может быть первым, вторым или последним)---------
sub correct_verbosity_argument_placement($$$)
{
  my $a = shift;
  my $b = shift;
  my $c = shift;
  my ($min_duration, $max_duration, $verbose);

  if ($c ne "") {
    # передано 3 параметра
    if ($a =~ /^-?v$/i || $a =~ /^-{0,2}verbose$/i) {
      # в первом параметре флаг v/verbose
      $min_duration = $b;
      $max_duration = $c;
      $verbose = $a;
    }
    elsif ($b =~ /^-?v$/i || $b =~ /^-{0,2}verbose$/i) {
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
my $seconds_duration = -1; # если неверный формат (переданный параметр не является числом с одним из суффиксов smhd соответствующих second/minute/hour/day, то функция возвратит -1
my ($value, $measure);
my $measure_size = 1;

  if ($raw_duration =~ /^(\d+)([smhdw]?)$/i) {
    # указана единица измерения
    $value = $1;
    $value *= 1;
    $measure = $2;
    $measure = lc($measure);
    #print "empty measure\n" if ($measure eq "");
    #print "[$value] [$measure]\n";
    $measure_size = 60     if ($measure eq "m"); # минуты
    $measure_size = 3600   if ($measure eq "h"); # часы
    $measure_size = 86400  if ($measure eq "d"); # дни
    $measure_size = 604800 if ($measure eq "w"); # недели
    $seconds_duration = $value * $measure_size;
  }
  return ($seconds_duration, $measure_size);
}

sub get_measure_name
{
my $measure_size = shift;
  
  return "minute" if ($measure_size == 60);
  return "hour"   if ($measure_size == 3600);
  return "day"    if ($measure_size == 86400);
  return "week"   if ($measure_size == 604800);
  return "second";
}

#-----------------Пауза длительностью случайное количество секунд (в заданном интервале)------------
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
  # [-]v|verbose если не последним параметром, то учесть это
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
    # поменять порядок очерёдность минимальной и максимвльной продолжительности (сначала должна быть минимальная)
    swap($min_duration, $max_duration);
  }
  $measure_size = $min_duration_measure_size;
  $measure_size = $max_duration_measure_size if ($max_duration_measure_size < $min_duration_measure_size);
  $min_intervals_count = $min_duration / $measure_size;
  $max_intervals_count = $max_duration / $measure_size;
  $intervals_count = get_random_int($min_intervals_count, $max_intervals_count);
  #print "QQQ3 min_duration=$min_duration, max_duration=$max_duration, verbose=$verbose measure_size=$measure_size min_intervals_count=$min_intervals_count max_intervals_count=$max_intervals_count intervals_count=$intervals_count\n";

  if ($verbose eq "v" || $verbose eq "verbose") {
    #если подробный режим - вывести сколько интервалов ожидания по 1 единице измерения и сколько это всего займёт секунд
    my $total_sleep_duration_seconds = $intervals_count * $measure_size; # общая продолжительность сна в секундах
    my $wake_time = time() + $total_sleep_duration_seconds;
    my $wake_timestamp = get_timestamp($wake_time);

    if ($measure_size > 1) {
      # интервалы дольше 1 секунды (минута, час, день)
      my $measure_name = get_measure_name($measure_size);
      #$measure_name .= "s";
      print "sleep $intervals_count times by 1 $measure_name  (totaly $total_sleep_duration_seconds seconds)\n";
    }
    else {
      # интервалы - секунды
      print "sleep seconds: $total_sleep_duration_seconds\n";
    }
    print "wake at $wake_timestamp\n";
  }

  for (my $i=$intervals_count; $i>=1; $i--) {
    # цикл сна
    if ($verbose eq "verbose") {
      $s = "[" . get_timestamp() . "]";
      $s .= "\t" . "$i / $intervals_count";
      print "$s\n";
    }
    sleep($measure_size);
  }

  if ($verbose eq "verbose") {
    # ввести время, когда закончили сон, если включен очень расширенный режим
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
