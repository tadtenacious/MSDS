# Problems Working with Larger Data on Google Compute Engine Micro Instance
---
### Getting the data
For class, we also had the option to attempt to use a small subset of the Gutenberg English book dataset [located here.](https://web.eecs.umich.edu/~lahiri/gutenberg_dataset.html) Unfortunately the file is hosted on Google Drive. So a simple `wget` would not suffice. Some classmates tried downloading the file locally and used scp, and others tried using the google in browser ssh tool, but the upload times in both cases were painfully slow. Then a classmate found a comment in [this gist](https://gist.github.com/iamtekeste/3cdfd0366ebfd2c0d805#gistcomment-2359248) that solved our problem. It involves adding a function to `~/.bash_aliases` to download the file. So our command was:
```console
$ gdrive_download 0B2Mzhc7popBga2RkcWZNcjlRTGM Gutenberg.zip
```
Then I extracted the zipfile into a new directory, `all_guten`.

---
### Trouble Shooting
Now that I had downloaded and extracted all 3,000+ text file for over 1Gb of data, I used the hadoop streaming command:
```
bin/hadoop jar share/hadoop/tools/lib/hadoop-streaming-3.1.1.jar \
-mapper ~/mapper.py \
-reducer ~/reducer.py \
-input ~/all_guten/* \
-output ~/guten_count
```

The first issue I encountered was:
```
Exception in thread "main" java.lang.IllegalArgumentException: java.net.UR
ISyntaxException: Relative path in absolute URI:
```

There was a colon in a file name. There is a simple fix for this from the terminal:
```console
$ find -name "*:*" -type f | rename 's/:/_/g'
```
But after running the hadoop command again, there were other characters in file names that caused the same error. I ended up having to fix `[`,`]`,`,`. I also fixed spaces and semicolons. Then after running the command again, there was a new error:
```
java.io.IOException: Cannot run program "/home/user_name/mapper.py": error=7, Argument list too long
```
I found the solution to this error in the [hadoop docs](https://hadoop.apache.org/docs/current/hadoop-streaming/HadoopStreaming.html#What_do_I_do_if_I_get_a_error_Argument_list_too_long) (It is at the very bottom of the page.). You have to add `-D stream.jobconf.truncate.limit=20000` to the streaming command. You also cannot tack this on to the end of the command. It must be the first argument. So now the hadoop streaming command is:

```
bin/hadoop jar share/hadoop/tools/lib/hadoop-streaming-3.1.1.jar \
-D stream.jobconf.truncate.limit=20000 \
-mapper ~/mapper.py \
-reducer ~/reducer.py \
-input ~/all_guten/* \
-output ~/guten_count
```  
Now there was a new error during mapping: `java.lang.OutOfMemoryError: Java heap space`

After finding [this stackoverflow answer](https://stackoverflow.com/questions/35742794/java-heap-space-error-while-executing-mapreduce?noredirect=1&lq=1), I added a few lines to the mapred-site.xml configureation in `/usr/local/hadoop/etc/hadoop`:
```xml
<property>
    <name>mapreduce.map.java.opts</name>
    <value>Xmx4096m</value>
</property>
<property>
    <name>mapreduce.reduce.java.opts</name>
    <value>Xmx4096m</value>
</property>
```
However, the same error was thrown, but this time in the reduce portion. It was at this point I decided to throw in the towel. Hadoop is for spreading out large data across multiple machines. Here, we are using a single micro-instance to run hadoop on a group of files that are too large for the machine to handle.

---
### Giving (Py)Spark a Shot

In the `Walkthrough.md`, I installed Apache Spark to read the csv file I created for the word counts of 3 files to find the most frequently used word. This time, I wanted see if Spark could do the mapreduce across all 3,000+ files. Spark comes with pyspark (python 2.7), and I write python, so it seemed like the best way to go. You could do this without regular expressions, and you could do this in less lines of code. I chose to do this at the console, and with Spark being in my path, from the user home directory, `$ pyspark`. Then I entered the following code:

```python
>>> import re
>>> rdd = sc.textFile('all_guten/*')
>>> lines = rdd.flatMap(lambda line: re.findall(r'[A-Za-z]+',line))
>>> counts = lines.map(lambda word: (word.lower(),1)).reduceByKey(lambda a
, b: a+b)
>>> counts.coalesce(1).saveAsTextFile('spark_guten_count.csv')
```                                        
After importing the `re` module, the second line reads in every file in the directory into a Spark [Resilient Distributed Dataset (RDD)](https://spark.apache.org/docs/latest/rdd-programming-guide.html#resilient-distributed-datasets-rdds). According to the docs, it *"is a fault-tolerant collection of elements that can be operated on in parallel."* Not that doing anything in parallel could help us here (a single machine with a single core). `flatMap` maps a function to an input like `map` but it needs to return a sequence, so it flattens a lists of lists into one. Then the normal map reduce comes into play. You will notice at this point that reading in the file, using `flatMap`, `map`, and then `reduceByKey` don't take much time at all. That's because data transformations in Spark are lazily evaluated. Results aren't computed until an actual value needs to be returned by the program[[docs]](https://spark.apache.org/docs/latest/rdd-programming-guide.html#rdd-operations). So `flatMap` and `map` return RDDs, which are lazy. You will notice that on a tiny machine like the one used here, saving the RDD will take forever and will probably hang your cpu. If you remove the `.coalesce(1)` You can get the program to complete, but your results will be spread out across many files, one for every input file of your RDD. In my case, 3,035 files. Again, [according to the docs](https://spark.apache.org/docs/latest/rdd-programming-guide.html#external-datasets), you will have one partition for every "block" in your dataset. A block being the HDFS default block of 128MB. It is important to note for future reference that you cannot have fewer partitions than blocks, but you can have *more* partitions than blocks. Anyway, I cut the job at about 20 minutes in. The cpu had been hanging for a while.

---
### The Obvious Not Big Data solution
Write a python script to loop through the directory, for every file, loop through the lines, and use a python dictionary to track the word frequency. In this repo and directory, it's `word_count.py`. I added some logic to keep track of the execution time. From the console:
```console
$ python3 word_count.py > guten_log
$ cat guten_log
Started at 2018-09-19 16:09:06.862628
Completed at 2018-09-19 16:12:32.964940
Completed in 0:03:26.102312
```

And there you have it, python script runs in about three and half minutes. Obviously, if you have a big data problem, you can use technology like Hadoop or Spark, but you are still going to need the appropriate hardware too.
