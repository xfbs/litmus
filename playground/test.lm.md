# Litmus test


Let's create a new file:

```ruby file:src/file.cr type:template
<%= header %>

# function definitions
<%= function %>

<%= footer %>
```

```ruby file:src/file.cr type:header
require "file"
```

```ruby file:src/file.cr type:function tag:add-something
def add(a, b)
    a + b
end
```
