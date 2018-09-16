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
Next, we worked through the instructions to [Write an Hadoop MapReduce Program in Python](https://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/)
