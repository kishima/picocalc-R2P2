# PicoRuby.wasm

PicoRuby.wasm is a PicoRuby port to WebAssembly.

## Usage

```html
<!DOCTYPE html>
<html>
  <head><meta charset="utf-8"></head>
  <body>
    <h1>DOM manipulation</h1>
    <button id="button">Click me!</button>
    <h2 id="container"></h2>
    <script type="text/ruby">
      require 'js'
      JS.document.getElementById('button').addEventListener('click') do |event|
        event.preventDefault
        JS.document.getElementById('container').innerText = 'Hello, PicoRuby!'
      end
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@picoruby/wasm-wasi@latest/dist/init.iife.js"></script>
  </body>
</html>
```

You can also read Ruby scripts from a file:

```html
    <script type="text/ruby" src="your_script.rb"></script>
```

### Fetching

```ruby
require 'js'
logo = JS.document.getElementById('logo')
JS.global.fetch('some.svg') do |response|
  if response.status.to_poro == 200
    logo.innerHTML = response.to_binary # to_binary blocks until the Promise is resolved
  end
end
```

picoruby.wasm doesn't support async/await so to make the binary small.

As of now, GET method is only supported. We'll wait for your PRs!

### JS::Object#to_poro method

As of now, `JS::Object` class doesn't have methods like `to_i` and `to_s`.

Instead, `to_poro`[^1] method converts a JS object to a Ruby object, fallbacking to a JS::Object when not doable.

[^1]: *poro* stands for *Plain Old Ruby Object*.

Other than `JS::Object#to_poro`, you can use `JS::Object#to_binary` to get a binary data from an arrayBuffer.

### Multi tasks

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
  </head>
  <body>
    <h1>Multi tasks</h1>
    <div>Open the console and see the output</div>
    <script type="text/ruby">
      while !(aho_task = Task.get('aho_task'))
        # Waiting for aho_task...
        sleep 0.1
      end
      i = 0
      while true
        i += 1
        if i % 3 == 0 || i.to_s.include?('3')
          aho_task.resume
        else
          puts "From main_task: #{i}"
        end
        sleep 1
      end
    </script>
    
    <script type="text/ruby">
      aho_task = Task.current
      aho_task.name = 'aho_task'
      aho_task.suspend
      while true
        puts "From aho_task: Aho!"
        aho_task.suspend
      end
    </script>

    <script src="https://cdn.jsdelivr.net/npm/@picoruby/wasm-wasi@latest/dist/init.iife.js"></script>
  </body>
</html>
```

## Ristriction due to the imlementation

Inside callbacks of `addEventListener`, you can't refer to variables outside the block:

```ruby
require 'js'
button = JS.document.getElementById('button')
button.addEventListener('click') do |event|
  event.target.innerText = 'Clicked!'
  # OK
  button.innerText = 'Clicked!'
  # => NameError: undefined local variable or method
end
```

The restriction above is only for the `addEventListener`.
You can refer to variables outside the block in general:

```ruby
lvar = 'Hello, PicoRuby!'
3.times do
  puts lvar
end
#=> Hello, PicoRuby! (3 times)
```

## Contributing

Fork [https://github.com/picoruby/picoruby](https://github.com/picoruby/picoruby), patch, and send a pull request.

### Build

```sh
git clone https://github.com/picoruby/picoruby
cd picoruby
MRUBY_CONFIG=wasm rake
```

Then, you can start a local server:

```sh
rake wasm:server
```

### Files that you may want to dig into

- `picoruby/mrbgems/picoruby-wasm/*`
- `picoruby/build_config/wasm.rb`

## License

MIT License

2024 (c) HASUMI Hitoshi a.k.a. [@hasumikin](https://twitter.com/hasumikin)
