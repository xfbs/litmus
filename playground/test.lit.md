# Litmus test


Let's create a new file:

```ruby @src/file.cr #header
require "file" # header
```

```ruby @src/file.cr #header #requires
require "abc" # header requires
require "def" # header requires
```

```ruby @src/file.cr #header #defines
define "abd" # header defines
```

```ruby @src/file.cr #header
# auxillary comment - header
```

```ruby @src/file.cr #header #requires
require "geh" # header requires
```

```ruby @src/file.cr #function #add-something
def add(a, b)
    a + b
end
```
