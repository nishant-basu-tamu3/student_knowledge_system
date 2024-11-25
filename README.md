# Student Knowledge System

Deployed App : https://hive-sks-c9da748e2491.herokuapp.com

Code Climate Report : https://codeclimate.com/github/nishant-basu-tamu3/student_knowledge_system

## CSCE 606 2024 Fall - Team Hive
* [Team Working Agreement](documentation/Fall2024/Team_Working_Agreement.txt)
* Team Members
  * [Nishant Basu](mailto:nishant.basu3@tamu.edu)
  * [Aum Palande](mailto:aumpalande@tamu.edu)
  * [Ellika Mishra](mailto:ellikamishra@tamu.edu)
  * [Raunak Kharbanda](mailto:raunak@tamu.edu)
  * [Mukil Senthilkumar](mailto:mukilsenthil@tamu.edu)
  * [Susheel Vadakkekuruppath](mailto:susheelvk@tamu.edu)
  * [Prakhar Suryavansh](mailto:ps41@tamu.edu)

## Getting Started 
* Follow these steps for setting up the working environment locally on your system:
* be in your dev machine, e.g. a fresh VPS or container (recommend Ubuntu 20+ with >=2 GB RAM)
* fork this repository: [fork it](https://github.com/philipritchey/student_knowledge_system/fork)
* clone your fork: `git clone git@github.com:YOU/student_knowledge_system.git`
* `cd student_knowledge_system`
* install rbenv with ruby-build: `curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash`
* reload profile: `source ~/.bashrc`
* install ruby 3.1.3: `rbenv install 3.1.3`
* set ruby 3.1.3 as the local default version: `rbenv local 3.1.3`
* install bundler: `gem install bundler`
* configure bundler to skip production gems: `bundle config set --local without 'production'`
* install dependencies: `bundle install`
* setup the database: `rails db:migrate`
* prepare the test database: `rails db:test:prepare`
* run rspec tests: `rails spec`
* run cucumber tests: `rails cucumber`
* assert that all tests are passing.  if they are not, find out which are failing and fix them and/or contact the previous team for help in fixing them.  possibly, the failing tests are themselves invalid and can be safely skipped?
* install heroku cli: `curl https://cli-assets.heroku.com/install-ubuntu.sh | sh`
* login to heroku: `heroku login -i`
  * `username: <your username>`
  * `password: <your API key>`
    * [get your API key from your heroku account](https://dashboard.heroku.com/account)
* create an app on heroku: `heroku create [appname]`, where `[appname]` is an optional name for the app
### Deploy an Initial Version of app for getting domain:
* stage changes: git add .
* commit changes: git commit -m "initial heroku deployment"
* deploy to heroku: git push heroku master.
* At this point your app is not ready.
* "heroku info -s" in termninal to get app url

## AWS - for storage
* If using AWS s3 bucket then follow the following steps:
* [create an s3 bucket](https://s3.console.aws.amazon.com/s3/buckets)
  * create a unique email id on gmail for using it for oauth and aws.
  * Go to aws and create an account with this email id as root user. (Requires Debit/Credit Card)
  * Create a IAM User.https://www.youtube.com/watch?v=CjKhQoYeR4Q&t=430s
  * Create a Bucket and Policy using Policy Generator : https://www.youtube.com/watch?v=y4SfQoJpipo
  * Use these settings while creating Policy :
    * choose `s3` as the service
    * specify the actions allowed:
      * `ListBucket`
      * `PutObject`
      * `GetObject`
      * `DeleteObject`
  * take note of the access key id and secret access key : Go to dashboard and on top right click the dropdown on your name, click on security_credentials => create access key.
* in `config/storage.yml`, make sure `region` and `bucket` fields match your bucket's region and name

## Google Oauth: - For Google Login

  * [go to google cloud apis & services](https://console.cloud.google.com/apis) (Use the same email as before for consitency)
  * Create a new project - give name and no org name
  * Click on OAuth consent screen on left hand side. 
  * make the project internal
  * only fill in the required fields:
      * name: your app's name
      * email: your email
      * authorized domains: your apps domain, e.g. `appname.herokuapp.com`
      * developer contact info: your email
  * go to credentials, then click create credentials at the top and select oauth client id
    * application type: web application
    * name: your app's name
    * authorized redirect uris, add: `https://appname.herokuapp.com/auth/google_oauth2/callback`
    * take note of the client id and client secret

## Back to App
* Note : in the place of "..." add your data.
* remove encrypted credentials that you cannot decrypt: `rm -f config/credentials.yml.enc`
* create and edit new credentials: `EDITOR=nano rails credentials:edit`
  * add AWS access key and secret (the iam s3 user access key id and secret access key)
    ```
      aws:
        access_key_id: ...
        secret_access_key: ...
    ```
  * add google oauth client id and secret
    ```
      GOOGLE_CLIENT_ID: ...
      GOOGLE_CLIENT_SECRET: ...
    ```
  * save and exit: `ctrl+o`, `ctrl+x`
  * take note of the master key in the console ; config->master.key
* save master key to heroku as config var (for security): `heroku config:set RAILS_MASTER_KEY=...`

## Magic Link - Google
* configure email account for sending emails (e.g. one-time magic links)
  * use gmail (because why not?)
  * [create an app password](https://support.google.com/mail/answer/185833?hl=en)
* set sendmail config vars on heroku
  * `heroku config:set SENDMAIL_USERNAME=the email address you just created/configured`
  * `heroku config:set SENDMAIL_PASSWORD=the app password you just created`
  * `heroku config:set MAIL_HOST=https://appname.herokuapp.com`

* set sendmail config vars on local
  * `export SENDMAIL_USERNAME=the email address you just created/configured`
  * `export SENDMAIL_PASSWORD=the app password you just created (app password)`
  * `export MAIL_HOST="gmail.com"`
  * the link will be generated in console.

## Re-Deploy
* stage changes: `git add .`
* commit changes: `git commit -m "ready to push to heroku"`
* deploy to heroku: `git push heroku master`
* run migrations on heroku: `heroku run rails db:migrate`
* seed database on heroku: `heroku run rails db:seed`
* poke around the deployed app
* don't forget to also push to your github repo: `git push`

## Previous Teams
### Team Cluck - CSCE 431 2023A
* [Harshitha Dhulipala](mailto:hdhulipala02@tamu.edu)
* [Neha Manuel](mailto:nehaam02@tamu.edu)
* [Ethan Novicio](mailto:ethannovicio@tamu.edu)
* [Caleb Oliphant](mailto:oliphcal000@tamu.edu)

### Shockwave Kickers - CSCE 606 2022C
* [Jacob Kelly](mailto:jrkelly08@tamu.edu)
* [Stuart Nelson](mailto:s.s.nelson@tamu.edu)
* [Rahul Shah](mailto:rahulshah521@tamu.edu)
* [Colton Simpson](mailto:csimpson2018@tamu.edu)
* [Kunal Vudathu](mailto:kvudathu@tamu.edu)


## User Documentation

[CSCE 431 2023A](https://docs.google.com/document/d/13YEn9vxi73LRq51pw2A23WnFRuGfTe4LMNbsMm7367E/edit#)

[CSCE 606 2022C](https://docs.google.com/document/d/1ATG78_72BFUqlMq_9StImvI8vVKKumL87lb0Caz3JoQ/edit?usp=sharing)

This document should include startup guide for both heroku and local setup (windows and mac user). This also contains other instructions to store s3 and send confirmation emails when running locally

Doc version also exists under documentation folder.
