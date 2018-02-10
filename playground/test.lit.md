# Litmus test


Let's create a new file:

```ruby @src/file.cr #template
<%= header %>

# function definitions
<%= function %>

<%= footer %>
```

```ruby @src/file.cr #header
require "file"
```

```ruby @src/file.cr #function #add-something
def add(a, b)
    a + b
end
```
