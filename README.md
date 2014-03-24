medusa
======

In Greek mythology Medusa was a monster, a Gorgon, generally described as having the face of a hideous human female with living venomous snakes in place of hair. Gazing directly upon her would turn onlookers to stone. Most sources describe her as the daughter of Phorcys and Ceto.

In modern software development, Medusa, a Gem, is generally described as the most beautiful parallel build system, evar. Running directly upon your servers will turn slow CI cycles to ash. Most sources describe her as the impossible daughter of Hydra, testbot, and test-queue (who says multiple inheritance is bad?).

Goals
=====

Phase 1 
- Clean up inner workings to provide streaming feedback and centralised result format from the master.
- Tidy the tests to the point that they run without any additional configuration.
 
Phase 2
- Separate changes made to work with rails into an easy-to-use setup/generator (bundle local, requiring environment, etc)
- Running medusa on a new project should be as easy as running rspec.

Goals
- Running medusa on CI should be as simple as one command.
- Medusa should come with integrations for common CI platforms.
- Ensure common build machines aren't flooded with too many runners.
- Works with all the popular testing platforms
