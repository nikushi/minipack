# Plugins

**EXPERIMENTAL:** Extensions that use Minipack plugin API.

Minipack will load plugins installed in gems or $LOAD_PATH. Plugins must be named `minipack_plugin.rb` and placed at the root of your gem.

## Make your own plugin

The first step is to follow the conventional file name, we will check that our plugin is loaded correctly:

```
$ cat lib/minipack_plugin.rb
puts 'hello from my plugin!'

$ bin/rails stats
hello from my plugin!
...
```

## Hooks

Right now, no hooks supported. When you consider the hooks feature. Please give me a feedback!
