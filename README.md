# Anemone
A super simple background job starter and monitor for Rails.

## Usage

```ruby
worker = Worker.new name: "MyWorker"
worker.save
worker.run do
  # A complex job that might even raise an exception
end # returns immediately

# later ...

worker.reload.status
w.status # either 'running', 'error', or 'done'
reason = w.message if w.status == 'error' # if the job raised an exception
```

From the front end in javascript you can do

```javascript
worker = new AnemoneWorker(123); // 123 is the id of the worker, possibly obtained
                                 // when one of your controllers returned a worker id
                                 // via an ajax call
worker.retrieve(); // => { id: ..., status: ..., message: ..., created_at: ..., updated_at: ... }
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'anemone'
```

And then execute:
```bash
$ bundle install
```

Anemone also needs to make a table in your database. To do this, run
```bash
rake anenome:setup
```

To use the javascript interface, you'll also need to add

```javascript
//= require anemone
```

to app/assets/javascripts/application.js

## Contributing
Feel free to submit a pull request.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
