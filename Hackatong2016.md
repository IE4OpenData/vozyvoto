# Some scripts from the Hack(at)ONG 2016

Most of the scripts for the Hack(at)ONG 2016 were done command-line
using perl one-liners, with the exception of the NER and the entity
linking (link.pl).

## Crawl

Download http://www.hcdn.gov.ar/secparl/dtaqui/ to reuniones.bin from
a Web broswer and put it into a subdirectory "crawl".

```
crawl$ grep reunion.asp reuniones.bin | perl -ne 's/\&amp;/\&/;s/\".*//; $c=chr(39); chomp; print "sleep 2s; wget ".$c."http://www1.hcdn.gov.ar/sesionesxml/$_".$c."\n"'> ./download.sh
$ bash ./download.sh
```

## Re-coding

```
$ mkdir utf8
$ cd crawl
crawl$ for i in reunion.asp\?p\=1 *; do iconv -f LATIN1 -t utf8 $i > ../utf8/$i; done
```

## Extract text

```
$ mkdir txt
$ cd utf8
utf8$ for i in reunion.asp\?p\=1*; do pandoc -f html -t plain $i > ../txt/$i; done
```

## Get attendee sheets

```
$ mkdir asistencia
$ grep asistencia.asp reuniones.bin | perl -ne 's/\&amp;/\&/;s/\".*//; $c=chr(39); chomp; print "sleep 2s; wget ".$c."http://www1.hcdn.gov.ar/sesionesxml/$_".$c."\n"' > download-asistencia.sh
$ cd asistencia
asistencia$ bash ../download-asistencia.sh
asistencia$ mkdir ../tablas_asistencia
asistencia$ for i in asistencia.asp\?per\=*; do cat $i| grep '<li>'|perl -pe 's/\<\/?li>//g;s/\<i>.*//'| iconv -f latin1 -t utf-8 > ../tablas_asistencia/$i; done
```

## Assign genders to attendee sheets

(in gender folder there should be files from https://github.com/IE4OpenData/generalizador)

```
$ mkdir tablas_asistencia_gender
$ cd gender
gender$ for i in ../tablas_asistencia/*; do j=${i##../tablas_asistencia/}; cat $i | perl -e 'use utf8; use open ":std", ":encoding(utf8)";open(M,"wiki-male.names");@m=<M>;chomp@m;%m=map{uc($_)=>1}@m;open(M,"wiki-male.names,ascii");@mm=<M>;chomp@mm;foreach(@mm){$m{uc($_)}=1};open(F,"wiki-female.names");@f=<F>;chomp@f;%f=map{uc($_)=>1}@f;open(F,"wiki-female.names,ascii");@ff=<F>;chomp@ff;foreach(@ff){$f{uc($_)}=1};while(<STDIN>){chomp;s/\s+$//;print; print "\t"; s/.*,//;@n=split(/\s+/,$_);$p=0;foreach$n(@n){if($m{uc($n)}){print"m";$p=1;last};if($f{uc($n)}){print"f";$p=1;last}};if(!$p){print"M"};print"\n"}' > ../tablas_asistencia_gender/$j; done
```

## Obtain dates for each session

```
$ cd utf8
utf8$ grep subtit * | perl -ne 'if(m/\d\d\/\d\d\/\d{4}/){s/reunion.asp\?p=//;s/\:.*tit\">/\t/;s/\<.*//;print}' > ../dates.tsv
```

## NER

Need to have Java 7 installed and Ant. The txt folder should be a
subfolder or edit build.xml run target to point to different folder.

```
$ ant build
$ ant run
$ mv output.csv ner.tsv
```

## Link

```
$ cat ner.tsv | perl ./link.pl  > final.tsv
$ cat final.tsv | sort -n|perl -ne '@a=m/([^\t]+)\t(.*)/;($y,$m,$d)=$a[0]=~m/(\d{4})(\d\d)(\d\d)/;print "$d/$m/$y\t$a[1]\n"'> final-sorted.tsv
```

## Bonus: extract keywords

Requires dates.tsv and txt folder.

```
$ perl ./extract_keywords.pl > keywords.tsv
```


