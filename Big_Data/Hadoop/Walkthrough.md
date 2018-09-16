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
