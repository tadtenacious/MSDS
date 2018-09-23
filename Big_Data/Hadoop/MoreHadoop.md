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
Now there was a new error: `java.lang.OutOfMemoryError: Java heap space`
