### Compile in command line ###
In order to compile the code we have to use the iverilog command:
```
$ iverilog DMA_regfile.v
```


If we want to store the executable in a particular file, we use the -o filename flag:
```
$ iverilog -o DMA_reg_exec DMA_regfile.v
```

**Note**: I use `DMA_regfile.v` in the commands from the time is the one that we need. For general and more detailed documentations visit the  [icarus verilog page](http://iverilog.icarus.com/).

---

### Execute in command line ###
After compile finishes, an executable has been created; a.out. We execute it using the vvp command:
```
$ vvp a.out
```

In the case we use the -o filename flag in compile, then we execute it with the filename:
```
$ vvp DMA_reg_exec
```