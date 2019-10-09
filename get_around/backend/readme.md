# Backend challenge for drivy

This my solution for the following challenge : https://github.com/drivy/jobs/tree/master/backend

Each level can be launch separatly by the following command : `ruby main.rb`

By default, this will run tests which is the interesting part of the exercises.

To generate the output run the following : `env PRODUCTION=true ruby ./main.rb`

Notice : 
	
  * The level1 is clearly a POC. It only run tests. The fun part is the usage [this](https://edgeguides.rubyonrails.org/contributing_to_ruby_on_rails.html#creating-a-bug-report).
  
  * This is based on the assomption that data inside data/input.json are seeds and not a database by itself.
	
  * It take me around 6-8 hours to perform everything.
  
  * It's DRY but enough KISS.
