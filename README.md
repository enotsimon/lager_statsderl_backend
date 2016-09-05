# lager_statsderl_backend

## overview

backend for erlang basho lager (https://github.com/basho/lager) that sends count of lager events to StatsD using statsderl

useful for monitoring count of warnings and errors


## install using rebar

add

`{lager_statsderl_backend, ".*", {git, "https://github.com/enotsimon/lager_statsderl_backend.git", {branch, "master"}}}`

to your `rebar.config` file in your erlang app


## usage

add to your app config files something like this

```
{lager, [
    {handlers, [
        {lager_statsderl_backend, [{level, warning}, {prefix, "my_apps.lager_events"}]}
    ]}
]}
```
