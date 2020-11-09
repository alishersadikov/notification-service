# notification-service
This is an API application that focuses on sending out text messages. It is hosted on https://balanced-notification-service.herokuapp.com.

Key components:
* Receives a notification request with `number` and `message` parameters
* Delegates the request to the external providers by balancing the loads
* Supports 1 to multiple providers
* Retries provider failures
* Recalibrates provider weights by analyzing the failures

# High-level flow chart

Here is a visual representation of the different components:

![Descriptive diagram](https://github.com/alishersadikov/notification-service/blob/main/flow_chart.png)

# README

## Ruby version

The Ruby version used in this project is 2.7.2. If you do not have it already, you should be able to install it by issuing this command:

  `$ rbenv install 2.7.2`

Then switch to that version:

  `$ rbenv global 2.7.2`

And confirm the version:

  `$ ruby -v`

Sometimes the newest Ruby version is not available without upgrading rbenv/ruby-build. If that is the case, this should help:

  `brew update && brew upgrade ruby-build`

Depending on the version of the software on the machines, they might need to be upgraded as well. I found these setup notes up-to-date and useful as of 11/9/2020: https://gorails.com/setup/osx/10.15-catalina

## System dependencies

### PostgreSQL

This is the only database used in the project. If you do not have it already, you can install PostgreSQL server and client from Homebrew:

`$ brew install postgresql`

Once this command is finished, it gives you a couple commands to run. Follow the instructions and run them:

To have launchd start postgresql at login:

`$ brew services start postgresql`

### Bundler

To bundle the gems/dependencies, run inside the app directory:

`$ bundle install`

## Database creation

To create the database (run inside the app directory):

`$ bundle exec rake db:create`

Then run the migrations:

`$ bundle exec rake db:migrate`

And the local database should be all set.


## Database initialization

For the app to function, the provider records have to exist. They can be seeded by running:

`$ bundle exec rake db:seed`

If needed, there is a rake task to simulate a notification request creation/queueing.

For a single notification:

`$ bundle exec rake notifications:generate`

For `N` notifications:

`$ bundle exec rake notifications:generate\[N\]`

## How to run the test suite

Pre-requisites: database creation steps above

Assuming that worked, the test suite can be simply run by issuing:

`$ bundle exec rspec`

## Services

This app is very light and does not use heavy services. It does use some of the popular libraries in the Ruby/Rails community:

### Development and test environments only

* gem 'database_cleaner-active_record' - used to clean test data
* gem 'dotenv-rails' - to manage environmental variables on the local  machine
* gem 'guard-rspec' - used to automatically run the tests while developing
* gem 'factory_bot_rails' - used for factories used in the test suite
* gem 'pry' - used for debugging in development/test environments
* gem 'rspec-rails' - the framework used for testing
* gem 'webmock' - used to mock external requests in tests

### Production environment as well
* gem 'faker' - to create random data
* gem 'httparty' - to make external HTTP requests
* gem 'jsonapi-serializer' - to serialize models
* gem 'ngrok-tunnel' - to expose localhost to the internet
* gem 'pagy' - to paginate the `notifications` resource

### Code formatting standards

The project relies on Rubocop to maintain code formatting. `.rubocop.yml` contains the configuration tailored for this code base. For more information on Rubocop, please see: https://docs.rubocop.org/rubocop/index.html.

## Development environment - how to use locally

### Ngrok and Rails server - Puma
Ngrok is a great tool to expose the localhost to the outside world. It can be installed and configured following the directions here: https://ngrok.com/download.

I always have better luck installing it with Homebrew though:

`brew cask install ngrok`

Once `ngrok` is installed on the machine, starting the server will take care of the necessary bindings by using the environmental variable `PORT=3000` which is already in the `.env` file. So:

`$ bin/rails server`

With a successful server start, the app will be listening on localhost port 3000 and should be ready to use!

Note: for free Ngrok accounts, the tunneling host changes with every server start. `config/puma.rb` records the new host and that host will be subsequently used for callbacks in the application. No manual steps are necessary, as long as it is remembered that the host changes with restarts.

## API endpoint documentation

Note: as it is implied with partial paths below, this documentation can be applied to both locally running server as well as the hosted Heroku app.

### post `/api/v1/notifications`

Purpose: to create/queue notifications.

Request: `number` and `message` parameters are accepted (both String).
```
{
  "number": "1231231324",
  "message": "Wonderful text message"
}
```

Response: returns attributes and relationships of the new notification record.

```
{
    "data": {
        "id": "3",
        "type": "notification",
        "attributes": {
            "number": "1231231324",
            "message": "Wonderful text message",
            "status": "queued",
            "external_id": "f958c19a-95a4-4d9b-8da9-a984543a8f4f",
            "provider_url": "https://jo3kcwlvke.execute-api.us-west-2.amazonaws.com/dev/provider1",
            "created_at": "2020-11-09T15:06:53.999Z",
            "updated_at": "2020-11-09T15:06:54.195Z",
            "notification_id": null
        },
        "relationships": {
            "provider": {
                "data": {
                    "id": "1",
                    "type": "provider"
                }
            }
        }
    }
}
```

### get `/api/v1/notifications`

Purpose: to expose notifications and their attributes and relationships

Request: `/api/v1/notifications?<filter>=<value>`

#### Pagination

A maximum of 50 records will be shown at a time. The page can be specified like this:

`/api/v1/notifications?page=2`


#### Querying

Notifications can be queried by `number, message, status, external_id`:

`/api/v1/notifications?number=1231231234`


Response: includes the data and meta fields. The meta filed has useful pagination information.
```
{
    "data": [
        {
            "id": "3",
            "type": "notification",
            "attributes": {
              ...
            },
            "relationships": {
              ...
            }
        },
        {
            "id": "4",
            "type": "notification",
            "attributes": {
              ...
            },
            "relationships": {
              ...
            }
        }
    ],
    "meta": {
        "pagination": {
            "scaffold_url": "/api/v1/notifications?page=__pagy_page__",
            "first_url": "/api/v1/notifications?page=1",
            "prev_url": "/api/v1/notifications?page=",
            "page_url": "/api/v1/notifications?page=1",
            "next_url": "/api/v1/notifications?page=",
            "last_url": "/api/v1/notifications?page=1",
            "count": 5,
            "page": 1,
            "items": 5,
            "vars": {
                "page": 1,
                "items": 50,
                "outset": 0,
                "size": [
                    1,
                    4,
                    4,
                    1
                ],
                "page_param": "page",
                "params": {},
                "anchor": "",
                "link_extra": "",
                "i18n_key": "pagy.item_name",
                "cycle": false,
                "metadata": [
                    "scaffold_url",
                    "first_url",
                    "prev_url",
                    "page_url",
                    "next_url",
                    "last_url",
                    "count",
                    "page",
                    "items",
                    "vars",
                    "pages",
                    "last",
                    "from",
                    "to",
                    "prev",
                    "next",
                    "series"
                ],
                "count": 5
            },
            "pages": 1,
            "last": 1,
            "from": 1,
            "to": 5,
            "prev": null,
            "next": null,
            "series": [
                "1"
            ]
        }
    }
}
```
### get `/api/v1/notifications/:id`

Purpose: to expose the attributes and relationships of a single notification record.

Request: `/api/v1/notifications/7`

Response:

```
{
    "data": {
        "id": "7",
        "type": "notification",
        "attributes": {
            "number": "1231231324",
            "message": "Wonderful text message",
            "status": "delivered",
            "external_id": "b23b9a4d-ea16-45fe-80c1-276d5d327907",
            "provider_url": "https://jo3kcwlvke.execute-api.us-west-2.amazonaws.com/dev/provider1",
            "created_at": "2020-11-09T15:07:27.994Z",
            "updated_at": "2020-11-09T15:07:28.294Z",
            "notification_id": null
        },
        "relationships": {
            "provider": {
                "data": {
                    "id": "1",
                    "type": "provider"
                }
            }
        }
    }
}
```
### post `/api/v1/providers`

Purpose: to create a provider

Request: only `url` (String) and `weight` (Float) parameters are accepted.
```
{
  "url": "https://my-awesome-url.com/provider1",
  "weight": 50.0
}
```

Response: returns attributes of the new provider record.

```
{
    "data": {
        "id": "3",
        "type": "provider",
        "attributes": {
            "url": "https://my-awesome-url.com/provider1",
            "weight": 50.0
        }
    }
}
```

Note: ideally this endpoint should be used for seeding or occasional provider updates.

### get `/api/v1/providers`

Purpose: to expose provider records

Request: `/api/v1/providers`

Response: returns the list of providers.

```
{
    "data": [
        {
            "id": "1",
            "type": "provider",
            "attributes": {
                "url": "https://jo3kcwlvke.execute-api.us-west-2.amazonaws.com/dev/provider1",
                "weight": 30.0
            }
        },
        {
            "id": "2",
            "type": "provider",
            "attributes": {
                "url": "https://jo3kcwlvke.execute-api.us-west-2.amazonaws.com/dev/provider2",
                "weight": 70.0
            }
        },
    ]
}
```

### get `/api/v1/providers/:id`

Purpose: to expose an individual provider record

Request: `/api/v1/providers/1`

Response: returns individual provider found by id.

```
{
    "data": {
        "id": "1",
        "type": "provider",
        "attributes": {
            "url": "https://jo3kcwlvke.execute-api.us-west-2.amazonaws.com/dev/provider1",
            "weight": 30.0
        }
    }
}
```
## Scheduled processes

As mentioned above, the app is hosted on Heroku at https://balanced-notification-service.herokuapp.com.

There are two processes that are running on recurring basis:

### Notification generation

This rake task runs every 10 minutes and generates 10 records at a time to simulate real traffic from external sources:

`$ bundle exec rake notifications:generate\[10\]`

### Provider weight recalibration

This rake task runs every 1 hour and queries the failed notification in the last hour. It tries to find the optimal load for the provider based on the failures and the old weights and changes the weights accordingly:

`$ bundle exec rake providers:recalibrate\[1\]`
