# Litmus test


Let's create a new file:

```ruby @src/file.cr #header !hide
#header !hide
```

```ruby @src/file.cr #header #requires !hide
#header #required !hide
```

```ruby @src/file.cr #header #defines !hide
#header #defines !hide
```

```ruby @src/file.cr #header !hide
#header !hide
```

```ruby @src/file.cr #header #requires !hide
#header #requires !hide
```

```ruby @src/file.cr #function #add-something !hide
#function #add-something !hide
```

```ruby @src/file.cr #header #fixes !after#defines !hide
#header #fixes !after#defines !hide
```

```ruby @src/file.cr #header #require-fixes !before#requires !hide
#header #require-fixes !before#requires !hide
```

```ruby @src/file.cr #header !replace !after#requires !before#fixes !hide
#header !replace !hide
```

```ruby @src/file.cr #header !after#requires
hello #header
```

```ruby @src/file.cr !replace
oops.
```
