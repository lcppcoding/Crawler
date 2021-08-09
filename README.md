# TEST SOLUTION

This is the solution to a test proposed as part of a job selection process. The task was to fetch 
and persist data from two government agencies web pages. The index page should display the headlines
and allow us to filter them, with pagination.

The crawler runs in the background. You can close the page
or navigate through the results as they come in. Initial fetch could last up to 10 min. A third test on a
different machine resulted in error due to the incredible shell script used to run migrations and kill rogue
pid files. Stopping and restarting the container should do the trick. My bad.

## SETUP
You can run this in three different ways. First step is always the same: clone this repo
```shell
git clone git@github.com:lcppcoding/dsb_news.git
cd dsb_news
```

------------
### From prebuilt images
Run the compose file based on prebuilt image
```shell
cd built
docker-compose up
```
Or in detached mode
```shell
cd built
docker-compose up -d
```

-------------
### From image built from dockerfile
```shell
docker-compose up
```
Same final option '-d' available

--------------
### If using docker
Use
```shell
docker-compose stop
```
To stop container

---------------
### Finally, you can just run the rails application directly. Ruby version is 3.0.2 and DB is Postgresql
```shell
git checkout no_docker
bundle install
rails db:create
rails db:migrate
rails s
```