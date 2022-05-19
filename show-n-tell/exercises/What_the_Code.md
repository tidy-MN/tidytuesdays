
  
# 🦊 What's the code say? 
  
```diff

!print("fox")
```

 
<br><br><br>


## 1. Pasting with `paste()`

```r
paste("I", "dog")
```

<details>
<summary> <b> Output </b></summary>
  
> "I dog" 
  
</details>
 
<br><br><br>
 
 
 ```r
paste("I", "am", "dog")
```

<details>
<summary> <b> Output </b></summary>
  
> "I am dog" 
  
</details>
 
<br><br><br>
 
 
```r
paste(c("I", "am"), "dog")
```

<details>
<summary> <b> Output </b></summary>
  
> "I dog" &emsp; "am dog"
  
</details>
<br><br><br>
 
 
```r
paste(c("I", "super"), c("am", "dog"))
```

<details>
<summary> <b> Output </b></summary>
  
> "I am"  &emsp;  "super dog"
  
</details>
<br><br><br>
 
 
 ## 2. `min()` & `max()`

```r
max(1,4,6)
```

<details>
<summary> <b> Output </b></summary>
  
> 6
</details>
<br><br><br>

```r
max(1,4,6, NA)
```

<details>
<summary> <b> Output </b></summary>
  
> NA
</details>
<br><br><br>

```r
max(NA, na.rm = TRUE)
```

<details>
<summary> <b> Output </b></summary>
  
> -Inf
</details>
<br><br><br>

```r
max("cat", 4,6)
```


<details>
<summary> <b> Output </b></summary>
  
> "cat"
</details>
<br><br><br>

```r
max("ant","cat","dog")
```

<details>
<summary> <b> Output </b></summary>
  
> "dog"
</details>
<br><br><br>

```r
max("ant","cat","dog", "Dog")
```

<details>
<summary> <b> Output </b></summary>
  
> "Dog"
</details>
<br><br><br>

```r
max("ant", "!!!cat!!!", "dog","Dog")
```

<details>
<summary> <b> Output </b></summary>
  
> "Dog"
</details>
<br><br><br>

