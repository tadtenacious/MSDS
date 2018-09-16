# Installing Hadoop and Apache Spark
## And Running Hadoop MapReduce with Python

---

We followed with instructions [to install hadoop here.](https://www.digitalocean.com/community/tutorials/how-to-install-hadoop-in-stand-alone-mode-on-ubuntu-16-04)

I used Hadoop 3.1.1, and had to alter the example command that was in
the tutorial.


The search term for the grep example was not in the example files, so I searched for "hadoop" instead.
```console
/usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.1.1.jar grep ~/input ~/grep_example 'hadoop'
```
The output from this was:
```console
hadoop 10
```
---
Next, we worked through the instructions to [Write an Hadoop MapReduce Program in Python.](https://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/)

The linked tutorial used python 2. I chose to use python 3. The example files claimed to by utf-8, but I had to change the encoding to latin-1. So instead of looping over standard input, I had to import the `io` library and add the following line:
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
