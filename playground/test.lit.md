# Litmus test


Let's create a new file:

```ruby @src/file.cr #header
#header
```

```ruby @src/file.cr #header #requires
#header #required
```

```ruby @src/file.cr #header #defines
#header #defines
```

```ruby @src/file.cr #header
#header
```

```ruby @src/file.cr #header #requires
#header #requires
```

```ruby @src/file.cr #function #add-something
#function #add-something
```

```ruby @src/file.cr #header #fixes !after#defines
#header #fixes !after#defines
```

```ruby @src/file.cr #header #require-fixes !before#requires
#header #require-fixes !before#requires
```

```ruby @src/file.cr #header !replace !after#requires !before#fixes
#header !replace
```

oops.
