medusa
======

In Greek mythology Medusa was a monster, a Gorgon, generally described as having the face of a hideous human female with living venomous snakes in place of hair. Gazing directly upon her would turn onlookers to stone. Most sources describe her as the daughter of Phorcys and Ceto.

In modern software development, Medusa, a Gem, is generally described as the most beautiful parallel build system, evar. Running directly upon your servers will turn slow CI cycles to ash. Most sources describe her as the impossible daughter of Hydra, testbot, and test-queue (who says multiple inheritance is bad?).

Goals
=====

Phase 1
- Clean up inner workings to provide streaming feedback and centralised result format from the master.
- Tidy the tests to the point that they run without any additional configuration.
- Worker or Runner errors propogate to master. [done]

Phase 2
- Separate changes made to work with rails into an easy-to-use setup/generator (bundle local, requiring environment, etc)
- Running medusa on a new project should be as easy as running rspec. [done]
- Runner artifact propogation to master.
  - Capture log file output for each runner.
  - Capture process statistics for the spec's run.
  - Capture shared resource load (DB load, etc)
  - Cucumber screenshot failures, HTML, etc.

Goals
- Running medusa on CI should be as simple as one command.
- Integrations for common CI platforms - TeamCity, Bamboo, Buildbot, Jenkins, etc.
- Integrations for common ruby platforms - Rails, Sinatra, etc.
- Ensure shared build machines (i.e. CI nodes) aren't flooded with too many runners/workers.
- Works with all the popular testing platforms.

One day...
- Worker/Runners for Java, Go, etc.

Usage (planned)
===============

1. Add `gem "medusa"` to your Gemfile, and `bundle install`
2. Run `medusa setup`, or `medusa setup --rails`
3. Edit the `medusa/environment.rb` file to configure environment setup (databases, etc).
4. Edit the `medusa/config.yml` file to configure how to run specs (machines to use, etc).
5. Run `bundle exec medusa` to run a build.


Message Flow
============

Medusa operates around messaging, which is performed over TCP connections. Remote workers via SSH have their ports forwarded onto the local master for communication, and local workers also use TCP connections.

There are 3 phases of message passing: Initialization, Run, and Shutdown.

Initialization

This phase is started once the master begins setting up workers for execution. The initialization phase covers both pre and post `medusa worker` commands, such as `bundle install`, or reconnecting to a new activerecord database.

Pre initialization messages are not passed from the worker, instead are passed directly from the master's Initialization classes to the Reporters.

Post initialization messages ARE passed from the worker. See `Medusa::Initializers::Rails` for an example.

```
Master                          Worker

(connects to target)

(run initializer)
  initializer_start

  initializer_output

  initializer_result

  initializer_end

(starts medusa worker)

(wait for ping)

                          <-    Ping

                          <-    InitializerStart
                          <-    InitializerOutput
                          <-    InitializerResult
                          <-    InitializerEnd

                          <-    InitializerStart
                          <-    InitializerOutput
                          <-    InitializerResult
                          <-    InitializerEnd

                          <-    WorkerBegin

                                or

                          <-    WorkerStartupFailure
```

Run

Once the worker has been successfully initialized, the Runners are started up and start to request files once they're initialized. Runner initialization follows a similar flow to the Worker initialization, but there is no pre step as Runners are forked from the Worker process.


```

Master                          Worker                          Runner
                                                          <-    RequestFile
                          <-    RequestFile

RunFile ->
                                RunFile ->
                                                                RunFile

                                                          <-    Result
                          <-    Result
                                                          <-    Result
                          <-    Result
                                                          <-    Result
                          <-    Result
                                                          <-    Result
                          <-    Result
                                                          <-    FileComplete
                          <-    FileComplete
                                                          <-    RequestFile
                          <-    RequestFile
RunFile ->
                          ...
or

NoMoreWork ->
                                Shutdown ->

                                (closes idle runner connections)

                                                                (continues running if active)

                                                          <-    Result
                          <-    Result
                                                          <-    FileComplete
                          <-    FileComplete
                                                          <-    RequestFile
                          <-    RequestFile

(repeats until all workers dead)

                                (repeats until all runners dead)

                          <-    Died
```
