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

Medusa is best installed as a Gem separate from your Gemfile.

`gem install medusa`

**Simple Usage**

To get specs running in parallel immediately, you can simply run `medusa spec` or `medusa features` from your project's root path. This will run your specs using all cores of your machine.

**Using with a build cluster**

One of the main benefits of Medusa is being able to use a build cluster without a CI program. You build cluster can be dedicated machines, or your coworkers laptops, or both. Medusa sends work as nodes within the cluster become free, so it will always balance work across all machines according to their speed.

On a "build node", you need to run a Labyrinth. This carves out a space on the machine for Medusa to use when running tests.

To get a build node up and running:

1. `gem install medusa`
2. `medusa labyrinth <ip>:<port>`

Running `medusa labyrinth localhost:18000` will start a labyrinth with a single dungeon capable of running 3 things at once (a dungeon with 3 minions). You can setup a labyrinth on your local machine as well as any other machines. This is what Medusa does for you automatically when the simple usage is invoked.

Once your nodes are setup, you run medusa from your machine (or a CI build agent) specifying the labyrinth locations to use:

`medusa spec -c localhost:18000 -c build01:18000`

**Using with Bonjour** - in development.

Work is underway to use medusa without specifying labyrinth locations. The proposed usage will be:

`medusa labyrinth --aether` to announce a labyrinth on Bonjour.

`medusa spec --aether` to use Bonjour annouced labyrinths.

**Using with Rails** - in development.

Medusa should automatically detect a rails project and setup databases for each minion to work on for you. If you have other services which need to be created, you can specify additional setup classes in the `.medusa` located in your project root.

`medusa new init` will create this file for you, and `medusa new initializer <ClassName>` will generate another initializer class and add it to the `.medusa` config.


Design
======

![Modelling](https://github.com/envato/medusa/raw/master/medusa.jpg)

**Overlords**
The central intelligence within the Medusa system, the Overlord commands Keepers to run tests and collates results for any attached listeners.

**Keeper**
A Keeper claims a dungeon (which is provided by the Overlord). Keepers run on the same machine as the Overlord, and interface with the minion's union situated on a remote machine to run tests.

**Minion**
A minion runs around a Dungeon, doing any work required.

**Union**
The Union manages the Minion's workload, ensuring the nasty Keepers can't overload them with work. The Keeper - Union pair represents the communication between the controlling machine and a testing node, with the Union running on the machine remote to the Keeper's machine.

**UnionApprovedWorkspace**
Gives minions a forked process in which they can run their tasks, so they don't stomp on each others toes. The workspace is setup by the Union when being told to represent a Minion.

**Dungeon**
An area on a testing node dedicated to running tests. A dungeon is claimed by a Keeper and cannot run tests for any other Keeper while claimed. When a dungeon is created, it has a size which dictates how many minions can be run, and returns a Union instance to the Keeper for work allocation. The keepers never talk directly to their minions.

**Labyrinth**
The labyrinth provides access to any number of dungeons running on a machine. The Overlord - Labyrinth pair is responsible for the initial discovery of any available testing nodes (with the help of DungeonDiscovery).

Interactions:

On the testing node (optional):

1. Labyrinth is created on a specific port.
2. Dungeons are added to the labyrinth, which can be claimed by a keeper.

On the developers or CI agent's machine:

1. An overlord is created and seeded with the files to run.
2. Keepers are added to the overlord, which indicate how many parellel processes should be run.
3. The overlord then instructs keepers to claim dungeons at a list of labyrinth addresses.
4. As dungeons are claimed, they are built according to the Overlord's project.
5. Once a dungeon is built, it fills itself to capacity with minions, and creates a Union which is returned to the keeper.
6. The overlord then sends work to keepers as each dungeon union permits.
7. As a minion completes their work file (assisted by the relevant Drivers), work progress is reported back through the Union, Keeper and Overlord, which then is forwarded to any listeners attached to the Overlord.
8. Once testing is complete, the Keepers abandon their dungeon, causing the collapse of the Union and the inevitable death of the minions represented.

