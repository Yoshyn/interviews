# Backend challenge for drivy

This my solution for the following challenge : https://github.com/drivy/jobs/tree/master/backend

My main goal was to provide a scalable and not too complex codebase using only rails but without generating a rails project.

Each level can be launch separatly by the following command : `ruby main.rb`

To run the tests, run the following : `ruby ./tests.rb`

Additional informations : 
	
  * The level1 is clearly a POC. It only run tests. The fun part is the usage [this](https://edgeguides.rubyonrails.org/contributing_to_ruby_on_rails.html#creating-a-bug-report).
  
  * This is based on the assomption that data inside data/input.json are seeds and not a database by itself.
	
  * It take me around 6-8 hours to perform everything.
  
  * It's DRY but not enough KISS. Maybe too much meta-prog.

  * No work done on SQL optimisation & caching. On a real usage, it may be a concern.

## Feeling After : 

For the company, the challenge is good to check how a candidate works.
