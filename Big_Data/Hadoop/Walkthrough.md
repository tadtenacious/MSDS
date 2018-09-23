# Installing Hadoop and Apache Spark
## And Running Hadoop MapReduce with Python

---
Our class set up Ubuntu 16.04 virtual machines on the Google Clound Platform. We followed with instructions [to install hadoop here.](https://www.digitalocean.com/community/tutorials/how-to-install-hadoop-in-stand-alone-mode-on-ubuntu-16-04)

I used Hadoop 3.1.1, and had to alter the example command that was in
the tutorial.


The search term for the grep example was not in the example files, so I searched for "hadoop" instead.
```console
$ /usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.1.jar grep ~/input ~/grep_example 'hadoop'
```
The output from this was:
```console
hadoop 10
```
---
Next, we worked through the instructions to [Write an Hadoop MapReduce Program in Python.](https://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/)


### Mapper

The linked tutorial used python 2. I chose to use python 3. The example files claimed to be utf-8, but I had to change the encoding to latin-1. So instead of looping over standard input, I had to import the `io` library and add the following line:
```python
input_stream = io.TextIOWrapper(sys.stdin.buffer, encoding='latin-1')
```
This changed the initial for loop to:
```python
#for line in sys.stdin:
for line in input_stream:
    line = line.strip()
  ```
  The tutorial also merely split each line along white space. I opted to use the python regular expression library to pull out words instead of the endless combinations of characters that might show up in free text. Then I took the lowercase version of the word and printed the result to the console with a semicolon delimeter instead of tab. (Don't forget to change the shebang!)
```python
  words = re.findall(r'[A-Za-z]+',line)
  for word in words:
      print('{};{}'.format(current_word, current_count))
```
---
### Reducer

I did not have to change the code from the tutorial for the reducer by much. I had to use the `io` library again, and I continued the use of a `;` delimiter instead of `\t`. Again, change the shebang line to point to python3.

---
### Testing the python files

Straight from the linked tutorial, at the command line:
```console
$ echo "foo foo quux labs foo bar quux" | ~/mapper.py | sort -k1,1 | ~/reducer.py
bar;1
foo;3
labs;1
quux;2
```
---
### Running Python on hadoop

Having followed slightly different instructions to install Hadoop from the python-hadoop tutorial we have been following, the paths had to be changed, and the `dfs` command was deprecated for `fs` (`dfs` will still run with a deprecation warning). Ultimately:
```console
contrib/streaming/hadoop-*streaming*.jar
```
had to be changed to:
```console
/usr/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-VersionNumber.jar
```

The full command ended up being:
```console
$ bin/hadoop jar /usr/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.1.1.jar -mapper ~/new_mapper.py -reducer ~/new_reducer.py -input ~/gutenberg/* -output ~/gutenberg_wc
```

To check the results:
```console
$ head ~/gutenberg_wc/*
==> gutenberg_wc/part-00000 <==
a;12564
aa;2
ab;6
abacho;2
abacus;8
abandon;12
abandoned;7
abandoning;4
abandonment;1
abandons;4

==> gutenberg_wc/_SUCCESS <==
```

At this point a classmate asked me to now find the most common word among the texts. Having aggregated all of the words and their counts, I thought this would be a fun opportunity to use Apache Spark. But not really having done anything with Scala, I decided to save myself a potential headache and added headers to the file.
```console
$ cd ~/gutenberg_wc
$ echo "Word;Count" > data.csv
$ cat part-00000 >> data.csv
$ head -5 data.csv
Word;Count
a;12564
aa;2
ab;6
abacho;2
```
---
### Apache Spark

I followed most of the instructions to install [Apache Spark here.](https://www.tutorialkart.com/apache-spark/install-latest-apache-spark-on-ubuntu-16/)

You can skip over the java installation and changing the path to java. But I found the `SPARK_HOME` and `PATH` variables to be set incorrectly. Instead use([I found the solution here](https://stackoverflow.com/questions/35620687/unable-to-run-spark-shell-from-bin)):
```bash
export SPARK_HOME=/usr/lib/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
```
Then you can source `~/.bashrc` and try running the spark-shell. Running the spark-shell should give you something like this:

```console
$ spark-shell
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.3.1
      /_/

scala>
```
From here, it's really just two commands from the shell to find the most commonly used word among the 3 text files.
```console
scala> val df = spark.read.format("csv").option("sep",";").option("inferSchema","true").option("header","true").load("~/gutenberg_wc/data.csv")

scala> df.orderBy(desc("Count")).limit(1).show()
+----+-------+
|Word|  Count|
+----+-------+
| the|55316.0|
+----+-------+
```
Not much of a surprise here if you have done any sort of NLP. Normally we would have removed stop-words before conducting our analysis. Still not knowing scala, I chose to write some SQL to query the dataframe to get around these prepositions and pronouns.
```console
scala> df.createOrReplaceTempView("words")
scala> spark.sql("SELECT * FROM words WHERE Word NOT IN ('the','of','and','in','to','a','is','it','that','which','as','on','by','be','this','are','with','from','at','will','for','not','or','you','have','no','they','but','its','s','i') ORDER BY Count DESC").show(3)
+-----+------+
| Word| Count|
+-----+------+
|light|1920.0|
|   if|1915.0|
|  one|1874.0|
+-----+------+
only showing top 3 rows
scala> :quit
```
And there you have it. Light is probably the most common non stop-word among the 3 text files. Next steps would be doing the map reduce portion in Spark, or actually trying to learn scala. But I think I would like to do something with a larger dataset on clustered machines that use Pyspark or SparkR/Sparklyr, tools I am much more comfortable with using.
