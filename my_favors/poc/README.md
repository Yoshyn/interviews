# MyFavors - Rails technical test



This test is part of the hiring process of MyFavors for a Ruby on Rails backend developer position. The goal of this test is to find a professional for a haircut booking at home. It's intended to get done in 3 to 5 hours, depending on your experience.



Don't worry if you don't finish, just go as far as you can ! The program may be a bit ambitious for this time frame.





## About the data.json file



This file contains the data you will need for this test. It has 3 root objects: `prestations` (the prestations a client can book), `pros` (the registered professionals) and `bookings` (a list of bookings to be matched with a professional).



Some attributes of these objects may need an explanation: `prestation#duration` is the duration of the prestation in minutes, `pro#max_kilometers` is the maximum distance (in kilometers) for a professional between its address and a booking address (as the crow flies), `pro#prestations` are the prestations that a pro can handle, `pro#appointments` are the appointments already scheduled in a pro agenda.





## Goal



The goal is to find the available professional(s) for a booking, following the steps below:



1. DB creation : build the appropriate DB and models for the data in `data.json`



2. Write a task to fill the DB with the data from `data.json`



3. Pros selection for a particular booking:



 * select the pros who can handle all the requested prestations

 * select the pros "not too far" (booking location closer than pro max kilometers, as the crow flies)

 * select the pros "open" at the requested appointement (booking timeframe within opening hours)

 * select the pros available at the requested appointement (no scheduled appointment overlapping the requested appointement)

 * select the pros matching all the previous requirements



  The final result may be a function returning for a booking an array like:



  `[{ pro_name: "Nathalie", handle_prestations: false, not_too_far: true,  open: false, available: true, selected: false }, ... ]`



4. Create a basic booking form (no need for design/UX) and select the available pros after a form submission



 * hint: the "address" field can handle only the city if it is easier for the geolocation





## Review



What we'll look at when reviewing your code :



* results (does the code work as expected ?)

* DB schema and models

* code syntax, code style

* naming (are models/functions/variables properly named ?)

* Git history (are commits atomic ? are commit messages clear and useful ?)

* dependencies (are third-party libraries well chosen ?)



What we **won't** look at :



* design and everything front-end related

* documentation (we love doc, but don't waste time on that for this test)



What we **would love** to see :



* one or two tests

* lint tooling



## Requirements



* Your code has to be versioned with Git

* Of course, third party libraries (gem packages) can be used



## Submission



Send us a zip version of your code (with `.git` folder included of course !), or push your project on the Git platform of your choice (Github, Bitbucket, whatever) in a private repo and share this repo with us.



## Candidate questions :

* Is a pro available direclty after a reservation ? Quid of the travel time ?

* Managing prestation of a booking with 2 differents pro